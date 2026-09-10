"""
Validation script for synthetic payment data.
"""
import pandas as pd
import os
import logging
from datetime import datetime, timedelta

# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def load_data(data_dir):
    """Load the CSV files from the data directory."""
    merchants_df = pd.read_csv(os.path.join(data_dir, 'merchants.csv'))
    customers_df = pd.read_csv(os.path.join(data_dir, 'customers.csv'))
    countries_df = pd.read_csv(os.path.join(data_dir, 'countries.csv'))
    # Parse the timestamp column for transactions
    transactions_df = pd.read_csv(os.path.join(data_dir, 'transactions.csv'), parse_dates=['timestamp'])
    return merchants_df, customers_df, countries_df, transactions_df

def validate_transactions(transactions_df, merchants_df, customers_df, countries_df):
    """
    Validate the generated transactions against business rules.
    Returns a list of validation errors.
    """
    logger.info("Validating generated transactions...")
    errors = []

    # 1. Foreign key checks
    # merchant_id exists in merchants
    missing_merchants = set(transactions_df['merchant_id']) - set(merchants_df['merchant_id'])
    if missing_merchants:
        errors.append(f"Missing merchants: {missing_merchants}")
    # customer_id exists in customers
    missing_customers = set(transactions_df['customer_id']) - set(customers_df['customer_id'])
    if missing_customers:
        errors.append(f"Missing customers: {missing_customers}")
    # country_id exists in countries
    missing_countries = set(transactions_df['country_id']) - set(countries_df['country_id'])
    if missing_countries:
        errors.append(f"Missing countries: {missing_countries}")

    # 2. Refunds only on approved transactions
    refunded_not_approved = transactions_df[(transactions_df['is_refunded']) & (~transactions_df['is_approved'])]
    if not refunded_not_approved.empty:
        errors.append(f"Refunded transactions that are not approved: {len(refunded_not_approved)} rows")

    # 3. Chargebacks only on approved transactions
    chargebacked_not_approved = transactions_df[(transactions_df['is_chargeback']) & (~transactions_df['is_approved'])]
    if not chargebacked_not_approved.empty:
        errors.append(f"Chargebacked transactions that are not approved: {len(chargebacked_not_approved)} rows")

    # 4. Refund amount <= transaction amount
    refund_exceeds = transactions_df[(transactions_df['refund_amount'] > transactions_df['amount']) & (transactions_df['is_refunded'])]
    if not refund_exceeds.empty:
        errors.append(f"Refund amount exceeds transaction amount: {len(refund_exceeds)} rows")

    # 5. Chargeback amount <= transaction amount
    chargeback_exceeds = transactions_df[(transactions_df['chargeback_amount'] > transactions_df['amount']) & (transactions_df['is_chargeback'])]
    if not chargeback_exceeds.empty:
        errors.append(f"Chargeback amount exceeds transaction amount: {len(chargeback_exceeds)} rows")

    # 6. Approved transactions have no decline reason
    approved_with_decline_reason = transactions_df[(transactions_df['is_approved']) & (transactions_df['decline_reason'].notna())]
    if not approved_with_decline_reason.empty:
        errors.append(f"Approved transactions with decline reason: {len(approved_with_decline_reason)} rows")

    # 7. Declined transactions always have a decline reason
    declined_no_reason = transactions_df[(~transactions_df['is_approved']) & (transactions_df['decline_reason'].isna())]
    if not declined_no_reason.empty:
        errors.append(f"Declined transactions without decline reason: {len(declined_no_reason)} rows")

    return errors

def print_anomaly_evidence(transactions_df, merchants_df, config_path):
    """
    Print the evidence for each anomaly as required.
    """
    logger.info("=== Anomaly Evidence ===")

    # Load config to get the end_date and start_date
    import yaml
    with open(config_path, 'r') as f:
        config = yaml.safe_load(f)

    # Get the anomaly assignments from merchants_df
    anomaly_assignment = merchants_df.set_index('merchant_id')['anomaly_type'].to_dict()

    # M000015: approval_rate_decline
    if 'M000015' in merchants_df['merchant_id'].values:
        merchant_id = 'M000015'
        anomaly_type = anomaly_assignment.get(merchant_id, 'normal')
        if anomaly_type == 'approval_rate_decline':
            logger.info(f"Anomalous merchant {merchant_id}: {anomaly_type}")
            # Get transactions for this merchant
            merchant_txns = transactions_df[transactions_df['merchant_id'] == merchant_id]
            # Define baseline and spike periods (last 60 days)
            end_date = datetime.strptime(config['end_date'], '%Y-%m-%d')
            spike_start = end_date - timedelta(days=60)
            baseline_mask = merchant_txns['timestamp'] < spike_start
            spike_mask = merchant_txns['timestamp'] >= spike_start

            baseline_txns = merchant_txns[baseline_mask]
            spike_txns = merchant_txns[spike_mask]

            baseline_count = len(baseline_txns)
            baseline_approved = baseline_txns['is_approved'].sum()
            baseline_approval_rate = baseline_approved / baseline_count if baseline_count > 0 else 0

            spike_count = len(spike_txns)
            spike_approved = spike_txns['is_approved'].sum()
            spike_approval_rate = spike_approved / spike_count if spike_count > 0 else 0

            approval_rate_decline = baseline_approval_rate - spike_approval_rate

            logger.info(f"  Baseline transaction count: {baseline_count}")
            logger.info(f"  Baseline approval rate: {baseline_approval_rate:.2%}")
            logger.info(f"  Final 60-day transaction count: {spike_count}")
            logger.info(f"  Final 60-day approval rate: {spike_approval_rate:.2%}")
            logger.info(f"  Approval-rate percentage-point decline: {approval_rate_decline:.2%}")
        else:
            logger.info(f"Merchant M000015 is not assigned to approval_rate_decline (got {anomaly_type}).")

    # M000095: unusual_volume_increase
    if 'M000095' in merchants_df['merchant_id'].values:
        merchant_id = 'M000095'
        anomaly_type = anomaly_assignment.get(merchant_id, 'normal')
        if anomaly_type == 'unusual_volume_increase':
            logger.info(f"Anomalous merchant {merchant_id}: {anomaly_type}")
            merchant_txns = transactions_df[transactions_df['merchant_id'] == merchant_id]
            # Define baseline and spike periods (last 30 days)
            end_date = datetime.strptime(config['end_date'], '%Y-%m-%d')
            spike_start = end_date - timedelta(days=30)
            baseline_mask = merchant_txns['timestamp'] < spike_start
            spike_mask = merchant_txns['timestamp'] >= spike_start

            baseline_txns = merchant_txns[baseline_mask]
            spike_txns = merchant_txns[spike_mask]

            baseline_count = len(baseline_txns)
            baseline_days = (spike_start - datetime.strptime(config['start_date'], '%Y-%m-%d')).days
            if baseline_days <= 0:
                baseline_days = 1
            baseline_avg_daily = baseline_count / baseline_days

            spike_count = len(spike_txns)
            spike_days = 30
            spike_avg_daily = spike_count / spike_days

            volume_multiplier = spike_avg_daily / baseline_avg_daily if baseline_avg_daily > 0 else 0

            logger.info(f"  Baseline average daily transaction count: {baseline_avg_daily:.2f}")
            logger.info(f"  Final 30-day average daily transaction count: {spike_avg_daily:.2f}")
            logger.info(f"  Volume multiplier: {volume_multiplier:.2f}")
        else:
            logger.info(f"Merchant M000095 is not assigned to unusual_volume_increase (got {anomaly_type}).")

    # M000032: chargeback spike
    if 'M000032' in merchants_df['merchant_id'].values:
        merchant_id = 'M000032'
        anomaly_type = anomaly_assignment.get(merchant_id, 'normal')
        if anomaly_type == 'chargeback_spike':
            logger.info(f"Anomalous merchant {merchant_id}: {anomaly_type}")
            merchant_txns = transactions_df[transactions_df['merchant_id'] == merchant_id]
            # Chargeback rate for this merchant
            merchant_chargeback_rate = merchant_txns['is_chargeback'].mean()
            # Portfolio chargeback rate
            portfolio_chargeback_rate = transactions_df['is_chargeback'].mean()
            rate_multiplier = merchant_chargeback_rate / portfolio_chargeback_rate if portfolio_chargeback_rate > 0 else 0

            logger.info(f"  Merchant chargeback rate: {merchant_chargeback_rate:.2%}")
            logger.info(f"  Portfolio chargeback rate: {portfolio_chargeback_rate:.2%}")
            logger.info(f"  Rate multiplier: {rate_multiplier:.2f}")
        else:
            logger.info(f"Merchant M000032 is not assigned to chargeback_spike (got {anomaly_type}).")

    # M000046: refund spike
    if 'M000046' in merchants_df['merchant_id'].values:
        merchant_id = 'M000046'
        anomaly_type = anomaly_assignment.get(merchant_id, 'normal')
        if anomaly_type == 'refund_spike':
            logger.info(f"Anomalous merchant {merchant_id}: {anomaly_type}")
            merchant_txns = transactions_df[transactions_df['merchant_id'] == merchant_id]
            # Refund rate for this merchant
            merchant_refund_rate = merchant_txns['is_refunded'].mean()
            # Portfolio refund rate
            portfolio_refund_rate = transactions_df['is_refunded'].mean()
            rate_multiplier = merchant_refund_rate / portfolio_refund_rate if portfolio_refund_rate > 0 else 0

            logger.info(f"  Merchant refund rate: {merchant_refund_rate:.2%}")
            logger.info(f"  Portfolio refund rate: {portfolio_refund_rate:.2%}")
            logger.info(f"  Rate multiplier: {rate_multiplier:.2f}")
        else:
            logger.info(f"Merchant M000046 is not assigned to refund_spike (got {anomaly_type}).")

    logger.info("========================")

def main():
    """Main function to validate the generated synthetic payment data."""
    logger.info("Starting validation of synthetic payment data...")

    # Define the data directory
    data_dir = os.path.join(os.path.dirname(__file__), '..', '..', 'data', 'raw')
    config_path = os.path.join(os.path.dirname(__file__), '..', '..', 'python', 'config', 'generator_config.yaml')

    # Load data
    merchants_df, customers_df, countries_df, transactions_df = load_data(data_dir)

    # Validate transactions
    validation_errors = validate_transactions(transactions_df, merchants_df, customers_df, countries_df)
    if validation_errors:
        logger.error("Validation errors found:")
        for error in validation_errors:
            logger.error(error)
        raise ValueError("Data validation failed. See errors above.")
    else:
        logger.info("Validation passed.")

    # Print summary statistics
    logger.info("=== Data Validation Summary ===")
    logger.info(f"Merchants: {len(merchants_df)}")
    logger.info(f"Customers: {len(customers_df)}")
    logger.info(f"Countries: {len(countries_df)}")
    logger.info(f"Transactions: {len(transactions_df)}")
    logger.info(f"Approval rate: {transactions_df['is_approved'].mean():.2%}")
    logger.info(f"Refund rate: {transactions_df['is_refunded'].mean():.2%}")
    logger.info(f"Chargeback rate: {transactions_df['is_chargeback'].mean():.2%}")

    # Print refund and chargeback amounts stats
    refunded_txns = transactions_df[transactions_df['is_refunded']]
    if not refunded_txns.empty:
        logger.info(f"Average refund amount: {refunded_txns['refund_amount'].mean():.2f}")
    chargedback_txns = transactions_df[transactions_df['is_chargeback']]
    if not chargedback_txns.empty:
        logger.info(f"Average chargeback amount: {chargedback_txns['chargeback_amount'].mean():.2f}")

    # Print transaction amount and processing fee stats
    logger.info(f"Transaction amount - mean: {transactions_df['amount'].mean():.2f}, std: {transactions_df['amount'].std():.2f}")
    logger.info(f"Processing fee - mean: {transactions_df['processing_fee'].mean():.2f}, std: {transactions_df['processing_fee'].std():.2f}")

    # Print anomaly evidence
    print_anomaly_evidence(transactions_df, merchants_df, config_path)

    logger.info("Validation completed successfully.")

if __name__ == "__main__":
    main()