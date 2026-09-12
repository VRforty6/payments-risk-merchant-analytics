"""
Pytest tests for synthetic payment data generation.
"""
import pandas as pd
import os
import pytest
import sys
from decimal import Decimal, ROUND_HALF_UP
from datetime import datetime, timedelta

pytestmark = pytest.mark.integration

# Path to the data directory
DATA_DIR = os.path.join(os.path.dirname(__file__), '..', '..', 'data', 'raw')
CONFIG_PATH = os.path.join(os.path.dirname(__file__), '..', '..', 'python', 'config', 'generator_config.yaml')

@pytest.fixture
def config():
    """Load the authoritative generator configuration."""
    import yaml
    with open(CONFIG_PATH, 'r') as f:
        return yaml.safe_load(f)

@pytest.fixture(scope='session')
def data_dir(tmp_path_factory):
    """Use committed local output or generate one temporary integration dataset."""
    required = ('merchants.csv', 'customers.csv', 'countries.csv', 'transactions.csv')
    if all(os.path.exists(os.path.join(DATA_DIR, name)) for name in required):
        return DATA_DIR

    python_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
    if python_dir not in sys.path:
        sys.path.insert(0, python_dir)
    from generator.generate_data import generate_data
    output_dir = str(tmp_path_factory.mktemp('generated-data'))
    generate_data(output_dir=output_dir)
    return output_dir

@pytest.fixture
def dataframes(data_dir):
    """Load the full generated-data integration fixture."""
    merchants_df = pd.read_csv(os.path.join(data_dir, 'merchants.csv'))
    customers_df = pd.read_csv(os.path.join(data_dir, 'customers.csv'))
    countries_df = pd.read_csv(os.path.join(data_dir, 'countries.csv'))
    # Parse the timestamp column for transactions
    transactions_df = pd.read_csv(os.path.join(data_dir, 'transactions.csv'), parse_dates=['timestamp'])
    return merchants_df, customers_df, countries_df, transactions_df

def test_row_counts(dataframes, config):
    """Test that the generated data has the expected number of rows."""
    merchants_df, customers_df, countries_df, transactions_df = dataframes
    assert len(merchants_df) == config['n_merchants']
    assert len(customers_df) == config['n_customers']
    assert len(countries_df) == config['n_countries']
    assert len(transactions_df) == config['n_transactions']

def test_foreign_keys(dataframes):
    """Test that foreign key constraints are satisfied."""
    merchants_df, customers_df, countries_df, transactions_df = dataframes
    # Check that all transaction merchant_ids exist in merchants
    assert set(transactions_df['merchant_id']).issubset(set(merchants_df['merchant_id'])), \
        "Some transaction merchant_ids are not present in merchants"
    # Check that all transaction customer_ids exist in customers
    assert set(transactions_df['customer_id']).issubset(set(customers_df['customer_id'])), \
        "Some transaction customer_ids are not present in customers"
    # Check that all transaction country_ids exist in countries
    assert set(transactions_df['country_id']).issubset(set(countries_df['country_id'])), \
        "Some transaction country_ids are not present in countries"

def test_refunds_only_on_approved(dataframes):
    """Test that refunds only occur on approved transactions."""
    _, _, _, transactions_df = dataframes
    refunded_not_approved = transactions_df[(transactions_df['is_refunded']) & (~transactions_df['is_approved'])]
    assert len(refunded_not_approved) == 0, \
        f"Found {len(refunded_not_approved)} refunded transactions that are not approved"

def test_chargebacks_only_on_approved(dataframes):
    """Test that chargebacks only occur on approved transactions."""
    _, _, _, transactions_df = dataframes
    chargebacked_not_approved = transactions_df[(transactions_df['is_chargeback']) & (~transactions_df['is_approved'])]
    assert len(chargebacked_not_approved) == 0, \
        f"Found {len(chargebacked_not_approved)} chargebacked transactions that are not approved"

def test_refund_amount_not_exceed_transaction_amount(dataframes):
    """Test that refund amount does not exceed transaction amount."""
    _, _, _, transactions_df = dataframes
    refund_exceeds = transactions_df[(transactions_df['refund_amount'] > transactions_df['amount']) & (transactions_df['is_refunded'])]
    assert len(refund_exceeds) == 0, \
        f"Found {len(refund_exceeds)} transactions where refund amount exceeds transaction amount"

def test_chargeback_amount_not_exceed_transaction_amount(dataframes):
    """Test that chargeback amount does not exceed transaction amount."""
    _, _, _, transactions_df = dataframes
    chargeback_exceeds = transactions_df[(transactions_df['chargeback_amount'] > transactions_df['amount']) & (transactions_df['is_chargeback'])]
    assert len(chargeback_exceeds) == 0, \
        f"Found {len(chargeback_exceeds)} transactions where chargeback amount exceeds transaction amount"

def test_approved_transactions_have_no_decline_reason(dataframes):
    """Test that approved transactions have no decline reason."""
    _, _, _, transactions_df = dataframes
    approved_with_decline_reason = transactions_df[(transactions_df['is_approved']) & (transactions_df['decline_reason'].notna())]
    assert len(approved_with_decline_reason) == 0, \
        f"Found {len(approved_with_decline_reason)} approved transactions with a decline reason"

def test_declined_transactions_have_decline_reason(dataframes):
    """Test that declined transactions always have a decline reason."""
    _, _, _, transactions_df = dataframes
    declined_no_reason = transactions_df[(~transactions_df['is_approved']) & (transactions_df['decline_reason'].isna())]
    assert len(declined_no_reason) == 0, \
        f"Found {len(declined_no_reason)} declined transactions without a decline reason"

def test_processing_fee_rule(dataframes):
    """Test exact-cent approved-only processing fees, including declined anomalies."""
    _, _, _, transactions_df = dataframes
    for _, row in transactions_df.iterrows():
        if not row['is_approved']:
            expected = Decimal('0.00')
        else:
            expected = Decimal(f"{round(float(row['amount']) * 0.029 + 0.30, 2):.2f}")
        actual = Decimal(str(row['processing_fee'])).quantize(Decimal('0.01'), rounding=ROUND_HALF_UP)
        assert actual == expected, f"Fee mismatch for {row['transaction_id']}: {actual} != {expected}"

def test_approval_rate_decline_anomaly(dataframes, config):
    """Test the configured approval-rate decline for the deterministic merchant."""
    merchants_df, _, _, transactions_df = dataframes
    end_date = datetime.strptime(config['end_date'], '%Y-%m-%d')
    spike_start = end_date - timedelta(days=config['anomalies']['approval_rate_decline']['window_days'])

    # Get transactions for merchant M000015
    merchant_txns = transactions_df[transactions_df['merchant_id'] == 'M000015'].copy()
    assert not merchant_txns.empty, "Merchant M000015 not found in transactions"

    baseline_mask = merchant_txns['timestamp'] < spike_start
    spike_mask = merchant_txns['timestamp'] >= spike_start

    baseline_txns = merchant_txns[baseline_mask]
    spike_txns = merchant_txns[spike_mask]

    assert not baseline_txns.empty, "No baseline transactions for M000015"
    assert not spike_txns.empty, "No spike transactions for M000015"

    baseline_approved = baseline_txns['is_approved'].sum()
    baseline_total = len(baseline_txns)
    baseline_approval_rate = baseline_approved / baseline_total

    spike_approved = spike_txns['is_approved'].sum()
    spike_total = len(spike_txns)
    spike_approval_rate = spike_approved / spike_total

    threshold = config['anomalies']['approval_rate_decline']['minimum_approval_rate_drop']
    decline = baseline_approval_rate - spike_approval_rate
    assert decline >= threshold, \
        f"Approval rate decline is {decline:.2%}, expected at least {threshold:.2%}"

def test_unusual_volume_increase_anomaly(dataframes, config):
    """Test the configured volume multiplier for the deterministic merchant."""
    merchants_df, _, _, transactions_df = dataframes
    end_date = datetime.strptime(config['end_date'], '%Y-%m-%d')
    start_date = datetime.strptime(config['start_date'], '%Y-%m-%d')
    spike_days = config['anomalies']['unusual_volume_increase']['window_days']
    spike_start = end_date - timedelta(days=spike_days)

    # Get transactions for merchant M000095
    merchant_txns = transactions_df[transactions_df['merchant_id'] == 'M000095'].copy()
    assert not merchant_txns.empty, "Merchant M000095 not found in transactions"

    baseline_mask = merchant_txns['timestamp'] < spike_start
    spike_mask = merchant_txns['timestamp'] >= spike_start

    baseline_txns = merchant_txns[baseline_mask]
    spike_txns = merchant_txns[spike_mask]

    assert not baseline_txns.empty, "No baseline transactions for M000095"

    baseline_days = (spike_start - start_date).days
    if baseline_days <= 0:
        baseline_days = 1
    baseline_avg_daily = len(baseline_txns) / baseline_days

    spike_avg_daily = len(spike_txns) / spike_days

    threshold = config['anomalies']['unusual_volume_increase']['minimum_volume_multiplier']
    volume_multiplier = spike_avg_daily / baseline_avg_daily
    assert volume_multiplier >= threshold, \
        f"Volume multiplier is {volume_multiplier:.2f}, expected at least {threshold:.2f}"

def test_chargeback_spike_anomaly(dataframes, config):
    """Test the configured chargeback flip intensity."""
    merchants_df, _, _, transactions_df = dataframes
    # Get transactions for merchant M000032
    merchant_txns = transactions_df[transactions_df['merchant_id'] == 'M000032'].copy()
    assert not merchant_txns.empty, "Merchant M000032 not found in transactions"

    flip_fraction = config['anomalies']['chargeback_spike']['approved_transaction_flip_fraction']
    approved_count = merchant_txns['is_approved'].sum()
    expected_flips = int(__import__('math').ceil(approved_count * flip_fraction))
    assert merchant_txns['is_chargeback'].sum() >= expected_flips, \
        f"Chargeback flags are {merchant_txns['is_chargeback'].sum()}, expected at least {expected_flips}"

def test_refund_spike_anomaly(dataframes, config):
    """Test the configured refund flip intensity."""
    merchants_df, _, _, transactions_df = dataframes
    # Get transactions for merchant M000046
    merchant_txns = transactions_df[transactions_df['merchant_id'] == 'M000046'].copy()
    assert not merchant_txns.empty, "Merchant M000046 not found in transactions"

    flip_fraction = config['anomalies']['refund_spike']['approved_transaction_flip_fraction']
    approved_count = merchant_txns['is_approved'].sum()
    expected_flips = int(__import__('math').ceil(approved_count * flip_fraction))
    assert merchant_txns['is_refunded'].sum() >= expected_flips, \
        f"Refund flags are {merchant_txns['is_refunded'].sum()}, expected at least {expected_flips}"

def test_anomalous_merchants_exist(dataframes, config):
    """Test the configured anomalous merchant count."""
    merchants_df, _, _, _ = dataframes
    anomalous = merchants_df[merchants_df['anomaly_type'] != 'normal']
    expected_count = config['anomalies']['anomaly_count']
    assert len(anomalous) == expected_count, f"Expected {expected_count} anomalous merchants, got {len(anomalous)}"

def test_anomalous_merchants_have_correct_types(dataframes, config):
    """Test the configured anomaly types."""
    merchants_df, _, _, _ = dataframes
    anomalous_types = set(merchants_df[merchants_df['anomaly_type'] != 'normal']['anomaly_type'])
    expected_types = set(config['anomalies']['anomaly_types'])
    assert anomalous_types == expected_types, f"Expected anomaly types {expected_types}, got {anomalous_types}"
