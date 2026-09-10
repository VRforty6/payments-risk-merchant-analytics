"""
Pytest tests for synthetic payment data generation.
"""
import pandas as pd
import os
import pytest
from datetime import datetime, timedelta

# Path to the data directory
DATA_DIR = os.path.join(os.path.dirname(__file__), '..', '..', 'data', 'raw')
CONFIG_PATH = os.path.join(os.path.dirname(__file__), '..', '..', 'python', 'config', 'generator_config.yaml')

@pytest.fixture
def dataframes():
    """Load the CSV files."""
    merchants_df = pd.read_csv(os.path.join(DATA_DIR, 'merchants.csv'))
    customers_df = pd.read_csv(os.path.join(DATA_DIR, 'customers.csv'))
    countries_df = pd.read_csv(os.path.join(DATA_DIR, 'countries.csv'))
    # Parse the timestamp column for transactions
    transactions_df = pd.read_csv(os.path.join(DATA_DIR, 'transactions.csv'), parse_dates=['timestamp'])
    return merchants_df, customers_df, countries_df, transactions_df

def test_row_counts(dataframes):
    """Test that the generated data has the expected number of rows."""
    merchants_df, customers_df, countries_df, transactions_df = dataframes
    assert len(merchants_df) == 100, f"Expected 100 merchants, got {len(merchants_df)}"
    assert len(customers_df) == 20000, f"Expected 20000 customers, got {len(customers_df)}"
    assert len(countries_df) == 15, f"Expected 15 countries, got {len(countries_df)}"
    assert len(transactions_df) == 75000, f"Expected 75000 transactions, got {len(transactions_df)}"

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

def test_approval_rate_decline_anomaly(dataframes):
    """Test that M000015 has a significant approval rate decline in the final 60 days."""
    merchants_df, _, _, transactions_df = dataframes
    # Load config to get the end_date
    import yaml
    with open(CONFIG_PATH, 'r') as f:
        config = yaml.safe_load(f)
    end_date = datetime.strptime(config['end_date'], '%Y-%m-%d')
    spike_start = end_date - timedelta(days=60)

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

    # The decline should be at least 15 percentage points (0.15)
    decline = baseline_approval_rate - spike_approval_rate
    assert decline >= 0.15, f"Approval rate decline is {decline:.2%}, expected at least 15 percentage points"

def test_unusual_volume_increase_anomaly(dataframes):
    """Test that M000095 has a volume increase of at least 2.5 times in the final 30 days."""
    merchants_df, _, _, transactions_df = dataframes
    # Load config to get the end_date and start_date
    import yaml
    with open(CONFIG_PATH, 'r') as f:
        config = yaml.safe_load(f)
    end_date = datetime.strptime(config['end_date'], '%Y-%m-%d')
    start_date = datetime.strptime(config['start_date'], '%Y-%m-%d')
    spike_start = end_date - timedelta(days=30)

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

    spike_days = 30
    spike_avg_daily = len(spike_txns) / spike_days

    volume_multiplier = spike_avg_daily / baseline_avg_daily
    assert volume_multiplier >= 2.5, f"Volume multiplier is {volume_multiplier:.2f}, expected at least 2.5"

def test_chargeback_spike_anomaly(dataframes):
    """Test that M000032 has a chargeback rate at least 5 times the portfolio rate."""
    merchants_df, _, _, transactions_df = dataframes
    # Get transactions for merchant M000032
    merchant_txns = transactions_df[transactions_df['merchant_id'] == 'M000032'].copy()
    assert not merchant_txns.empty, "Merchant M000032 not found in transactions"

    merchant_chargeback_rate = merchant_txns['is_chargeback'].mean()
    portfolio_chargeback_rate = transactions_df['is_chargeback'].mean()

    rate_multiplier = merchant_chargeback_rate / portfolio_chargeback_rate
    assert rate_multiplier >= 5, f"Chargeback rate multiplier is {rate_multiplier:.2f}, expected at least 5"

def test_refund_spike_anomaly(dataframes):
    """Test that M000046 has a refund rate at least 3 times the portfolio rate."""
    merchants_df, _, _, transactions_df = dataframes
    # Get transactions for merchant M000046
    merchant_txns = transactions_df[transactions_df['merchant_id'] == 'M000046'].copy()
    assert not merchant_txns.empty, "Merchant M000046 not found in transactions"

    merchant_refund_rate = merchant_txns['is_refunded'].mean()
    portfolio_refund_rate = transactions_df['is_refunded'].mean()

    rate_multiplier = merchant_refund_rate / portfolio_refund_rate
    assert rate_multiplier >= 3, f"Refund rate multiplier is {rate_multiplier:.2f}, expected at least 3"

def test_anomalous_merchants_exist(dataframes):
    """Test that there are exactly 4 anomalous merchants."""
    merchants_df, _, _, _ = dataframes
    anomalous = merchants_df[merchants_df['anomaly_type'] != 'normal']
    assert len(anomalous) == 4, f"Expected 4 anomalous merchants, got {len(anomalous)}"

def test_anomalous_merchants_have_correct_types(dataframes):
    """Test that the anomalous merchants have the four expected anomaly types."""
    merchants_df, _, _, _ = dataframes
    anomalous_types = set(merchants_df[merchants_df['anomaly_type'] != 'normal']['anomaly_type'])
    expected_types = {'approval_rate_decline', 'chargeback_spike', 'refund_spike', 'unusual_volume_increase'}
    assert anomalous_types == expected_types, f"Expected anomaly types {expected_types}, got {anomalous_types}"