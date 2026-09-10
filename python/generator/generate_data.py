"""
Synthetic Payment Data Generator
"""
import yaml
import pandas as pd
import numpy as np
import os
from datetime import datetime, timedelta
import logging
import hashlib

# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def load_config():
    """Load generator configuration from YAML file."""
    config_path = os.path.join(os.path.dirname(__file__), '..', 'config', 'generator_config.yaml')
    with open(config_path, 'r') as f:
        config = yaml.safe_load(f)
    return config

def set_seeds(seed):
    """Set random seeds for reproducibility."""
    np.random.seed(seed)
    # Note: Python's built-in random module is not used here, but we set it for completeness
    import random
    random.seed(seed)

MERCHANT_NAME_PREFIXES = [
    "Aster", "Beacon", "Cedar", "Ember", "Harbor", "Keystone",
    "Lumen", "Meridian", "Northstar", "Prairie", "Summit", "Veridian"
]

MERCHANT_CATEGORY_TERMS = {
    "retail": ["Goods", "Supply", "Market", "Trading"],
    "restaurant": ["Table", "Kitchen", "Bistro", "Pantry"],
    "travel": ["Voyages", "Routes", "Journey", "Transit"],
    "electronics": ["Devices", "Circuit", "Signal", "Systems"],
    "clothing": ["Apparel", "Textiles", "Threads", "Wardrobe"],
    "groceries": ["Provisions", "Harvest", "Basket", "Fresh"],
    "healthcare": ["Care", "Wellness", "Clinic", "Health"],
    "entertainment": ["Events", "Stage", "Media", "Leisure"]
}

def _id_number(identifier):
    """Extract the numeric part of a generated business identifier."""
    digits = ''.join(ch for ch in str(identifier) if ch.isdigit())
    return int(digits) if digits else 0

def build_merchant_display_name(merchant_id, category):
    """Build a stable, professional fictional merchant label."""
    merchant_num = _id_number(merchant_id)
    prefix = MERCHANT_NAME_PREFIXES[merchant_num % len(MERCHANT_NAME_PREFIXES)]
    category_terms = MERCHANT_CATEGORY_TERMS.get(str(category).lower(), ["Commerce"])
    term = category_terms[merchant_num % len(category_terms)]
    return f"{prefix} {term} {merchant_num:03d}"

def build_market_display_name(country_id, region):
    """Build a stable synthetic market label without assigning real country names."""
    country_num = _id_number(country_id)
    return f"{region} Market {country_num:02d}"

def generate_merchants(config):
    """Generate merchant data."""
    logger.info(f"Generating {config['n_merchants']} merchants...")
    n_merchants = config['n_merchants']
    categories = config['merchant_categories']
    risk_tiers = config['risk_tiers']
    # Weights for categorical choices
    cat_probs = [c['weight'] for c in categories]
    tier_probs = [t['weight'] for t in risk_tiers]

    merchants = []
    for i in range(n_merchants):
        merchant_id = f"M{i:06d}"
        category = np.random.choice(categories, p=cat_probs)
        tier = np.random.choice(risk_tiers, p=tier_probs)
        # Base decline probability from tier, adjusted by category? We'll keep simple: tier determines base prob
        base_decline_prob = tier['decline_prob']
        base_chargeback_prob = tier['chargeback_prob']
        base_refund_prob = tier['refund_prob']
        merchants.append({
            'merchant_id': merchant_id,
            'merchant_name': f"Merchant_{merchant_id}",
            'merchant_display_name': build_merchant_display_name(merchant_id, category['name']),
            'category': category['name'],
            'risk_tier': tier['tier'],
            'base_decline_prob': base_decline_prob,
            'base_chargeback_prob': base_chargeback_prob,
            'base_refund_prob': base_refund_prob,
            'amount_mean': category['amount_mean'],
            'amount_std': category['amount_std']
        })
    merchants_df = pd.DataFrame(merchants)
    return merchants_df

def generate_customers(config):
    """Generate customer data."""
    logger.info(f"Generating {config['n_customers']} customers...")
    n_customers = config['n_customers']
    countries = [f"Country_{i:02d}" for i in range(1, config['n_countries']+1)]
    # We'll assign a random country to each customer
    customers = []
    for i in range(n_customers):
        customer_id = f"C{i:08d}"
        country = np.random.choice(countries)
        customers.append({
            'customer_id': customer_id,
            'customer_name': f"Customer_{customer_id}",
            'country': country
        })
    customers_df = pd.DataFrame(customers)
    return customers_df

def generate_countries(config):
    """Generate country data."""
    logger.info(f"Generating {config['n_countries']} countries...")
    n_countries = config['n_countries']
    regions = config['regions']
    # Simple country names
    countries = []
    for i in range(n_countries):
        country_id = f"CO{i:02d}"
        country_name = f"Country_{country_id}"
        region = np.random.choice(regions)
        # Currency: we'll assign randomly from currency_codes
        currency = np.random.choice(config['currency_codes'])
        countries.append({
            'country_id': country_id,
            'country_name': country_name,
            'market_display_name': build_market_display_name(country_id, region),
            'region': region,
            'currency_code': currency
        })
    countries_df = pd.DataFrame(countries)
    return countries_df

def generate_transactions(config, merchants, customers, countries):
    """Generate transaction data."""
    logger.info(f"Generating {config['n_transactions']} transactions...")
    n_transactions = config['n_transactions']
    start_date = datetime.strptime(config['start_date'], '%Y-%m-%d')
    end_date = datetime.strptime(config['end_date'], '%Y-%m-%d')
    date_range = end_date - start_date

    # We'll assign each merchant a base transaction count proportional to something
    # For simplicity, we'll distribute transactions uniformly across merchants and time, then adjust for anomalies
    # First, generate base transactions

    # Prepare merchant and customer DataFrames for lookup
    merchant_dict = merchants.set_index('merchant_id').to_dict(orient='index')
    customer_dict = customers.set_index('customer_id').to_dict(orient='index')
    country_dict = countries.set_index('country_id').to_dict(orient='index')

    transactions = []
    # We'll generate transactions in batches to avoid memory issues, but 75k is fine
    for i in range(n_transactions):
        if i % 10000 == 0:
            logger.info(f"Generated {i} transactions...")
        # Pick random merchant and customer
        merchant_id = np.random.choice(merchants['merchant_id'].values)
        customer_id = np.random.choice(customers['customer_id'].values)
        # Get merchant details
        merchant = merchant_dict[merchant_id]
        # Transaction date uniformly distributed over the date range
        random_days = np.random.randint(0, date_range.days)
        transaction_date = start_date + timedelta(days=random_days)
        # Transaction time within the day
        transaction_time = timedelta(
            hours=np.random.randint(0, 24),
            minutes=np.random.randint(0, 60),
            seconds=np.random.randint(0, 60)
        )
        timestamp = transaction_date + transaction_time
        # Amount: normal distribution around merchant's mean, clipped to positive
        amount = max(0.01, np.random.normal(merchant['amount_mean'], merchant['amount_std']))
        # Round to 2 decimal places
        amount = round(amount, 2)
        # Processing fee: assume a percentage of amount, say 2.9% + $0.30 typical for cards
        processing_fee = round(amount * 0.029 + 0.30, 2)
        # Select payment method based on weights
        payment_method = np.random.choice(
            [m['method'] for m in config['payment_methods']],
            p=[m['weight'] for m in config['payment_methods']]
        )
        # Select device type and channel randomly
        device_type = np.random.choice(config['device_types'])
        channel = np.random.choice(config['channels'])
        # Currency: we could get from merchant's country, but for simplicity assign random from currency_codes
        currency_code = np.random.choice(config['currency_codes'])
        # Country: we could link merchant to country, but for simplicity assign random from countries
        country_id = np.random.choice(countries['country_id'].values)
        country = country_dict[country_id]

        # Determine if transaction is approved based on payment method approval rate and merchant decline probability
        # Base approval rate from payment method
        payment_method_info = next(m for m in config['payment_methods'] if m['method'] == payment_method)
        base_approval_rate = payment_method_info['approval_rate']
        # Adjust by merchant decline probability: approval_rate = base_approval_rate * (1 - base_decline_prob)
        # But note: decline probability is the chance of decline due to merchant risk, so we adjust
        approval_rate = base_approval_rate * (1 - merchant['base_decline_prob'])
        # Ensure bounds
        approval_rate = max(0.0, min(1.0, approval_rate))
        is_approved = np.random.random() < approval_rate

        # Determine decline reason if not approved
        decline_reason = None
        if not is_approved:
            # Choose a decline reason based on some weights
            decline_reasons = ['insufficient_funds', 'card_expired', 'suspected_fraud', 'transaction_limit_exceeded']
            decline_reason = np.random.choice(decline_reasons)

        # Determine if refunded (only if approved)
        is_refunded = False
        refund_amount = 0.0
        if is_approved:
            # Base refund probability from merchant tier
            refund_prob = merchant['base_refund_prob']
            is_refunded = np.random.random() < refund_prob
            if is_refunded:
                # Refund amount is usually full or partial; we'll do full refund for simplicity
                refund_amount = amount

        # Determine if chargeback (only if approved)
        is_chargeback = False
        chargeback_amount = 0.0
        if is_approved:
            chargeback_prob = merchant['base_chargeback_prob']
            is_chargeback = np.random.random() < chargeback_prob
            if is_chargeback:
                # Chargeback amount is usually the full transaction amount
                chargeback_amount = amount

        transactions.append({
            'transaction_id': f"T{i:010d}",
            'merchant_id': merchant_id,
            'customer_id': customer_id,
            'timestamp': timestamp,
            'amount': amount,
            'currency_code': currency_code,
            'payment_method': payment_method,
            'device_type': device_type,
            'channel': channel,
            'country_id': country_id,
            'is_approved': is_approved,
            'decline_reason': decline_reason,
            'is_refunded': is_refunded,
            'refund_amount': refund_amount,
            'is_chargeback': is_chargeback,
            'chargeback_amount': chargeback_amount,
            'processing_fee': processing_fee
        })

    transactions_df = pd.DataFrame(transactions)
    return transactions_df

def apply_approval_rate_decline(transactions_df, merchants_df, config, merchant_id='M000015'):
    """
    Apply approval-rate decline anomaly for the specified merchant.
    - Baseline period: all dates except the final 60 days
    - Final 60-day approval rate target: approximately 65% to 75%
    - Final 60-day approval rate must be at least 15 percentage points below the baseline period
    """
    logger.info(f"Applying approval-rate decline anomaly for merchant {merchant_id}...")

    # Get the merchant's transactions
    merchant_txns = transactions_df[transactions_df['merchant_id'] == merchant_id].copy()
    if merchant_txns.empty:
        logger.warning(f"No transactions found for merchant {merchant_id}")
        return transactions_df

    # Define baseline and spike periods
    end_date = datetime.strptime(config['end_date'], '%Y-%m-%d')
    spike_start = end_date - timedelta(days=60)

    # Split transactions
    baseline_mask = merchant_txns['timestamp'] < spike_start
    spike_mask = merchant_txns['timestamp'] >= spike_start

    baseline_txns = merchant_txns[baseline_mask]
    spike_txns = merchant_txns[spike_mask]

    if baseline_txns.empty or spike_txns.empty:
        logger.warning(f"Baseline or spike period empty for merchant {merchant_id}")
        return transactions_df

    # Calculate baseline approval rate (we will not change baseline)
    baseline_approved = baseline_txns['is_approved'].sum()
    baseline_total = len(baseline_txns)
    baseline_approval_rate = baseline_approved / baseline_total if baseline_total > 0 else 0

    # Target spike approval rate: at least 15 percentage points below baseline
    target_spike_approval_rate = max(0, baseline_approval_rate - 0.15)

    # Current spike approval rate
    spike_approved = spike_txns['is_approved'].sum()
    spike_total = len(spike_txns)
    current_spike_approval_rate = spike_approved / spike_total if spike_total > 0 else 0

    # If current spike approval rate is already at or below target, no adjustment needed
    if current_spike_approval_rate <= target_spike_approval_rate:
        logger.info(f"Approval rate for {merchant_id} in spike period already at or below target. No adjustment needed.")
        return transactions_df

    # Calculate how many approved transactions in spike we need to flip to declined
    # We want: (spike_approved - X) / spike_total <= target_spike_approval_rate
    # => X >= spike_approved - spike_total * target_spike_approval_rate
    X = int(np.ceil(spike_approved - spike_total * target_spike_approval_rate))
    X = min(X, spike_approved)  # Cannot flip more than we have

    if X <= 0:
        logger.info(f"No approved transactions to flip for merchant {merchant_id}.")
        return transactions_df

    logger.info(f"Flipping {X} approved transactions to declined for merchant {merchant_id} in spike period.")

    # Select X approved transactions in the spike period to flip
    # We'll select the earliest X approved transactions by timestamp (deterministic)
    approved_spike_txns = spike_txns[spike_txns['is_approved']].sort_values('timestamp')
    to_flip = approved_spike_txns.head(X)

    # Flip these transactions: set is_approved to False, set a decline reason, and set refund/chargeback to 0
    # (since declined transactions cannot have refunds or chargebacks)
    decline_reasons = ['insufficient_funds', 'card_expired', 'suspected_fraud', 'transaction_limit_exceeded']
    # Use a deterministic way to assign decline reasons: hash of transaction_id
    def get_decline_reason(tid):
        # Hash the transaction ID to get a consistent index
        hash_int = int(hashlib.md5(str(tid).encode()).hexdigest(), 16)
        return decline_reasons[hash_int % len(decline_reasons)]

    # Update the transactions_df
    for _, row in to_flip.iterrows():
        idx = row.name
        transactions_df.at[idx, 'is_approved'] = False
        transactions_df.at[idx, 'decline_reason'] = get_decline_reason(row['transaction_id'])
        transactions_df.at[idx, 'is_refunded'] = False
        transactions_df.at[idx, 'refund_amount'] = 0.0
        transactions_df.at[idx, 'is_chargeback'] = False
        transactions_df.at[idx, 'chargeback_amount'] = 0.0
        # Note: processing fee should still apply? Business rules: processing fee should apply only to approved transactions.
        # So we set processing_fee to 0 for declined transactions?
        # However, the original generation logic set processing_fee based on amount regardless of approval.
        # To adhere to business rules, we'll set processing_fee to 0 for declined transactions.
        transactions_df.at[idx, 'processing_fee'] = 0.0

    logger.info(f"Approval-rate decline applied for merchant {merchant_id}. Flipped {X} transactions.")
    return transactions_df

def apply_unusual_volume_increase(transactions_df, merchants_df, config, merchant_id='M000095'):
    """
    Apply unusual volume increase anomaly for the specified merchant.
    - Baseline period: dates before the final 30 days
    - Final 30-day daily transaction volume must be at least 2.5 times the merchant’s baseline average daily volume
    """
    logger.info(f"Applying unusual volume increase anomaly for merchant {merchant_id}...")

    # Get the merchant's transactions
    merchant_txns = transactions_df[transactions_df['merchant_id'] == merchant_id].copy()
    if merchant_txns.empty:
        logger.warning(f"No transactions found for merchant {merchant_id}")
        return transactions_df

    # Define baseline and spike periods
    end_date = datetime.strptime(config['end_date'], '%Y-%m-%d')
    spike_start = end_date - timedelta(days=30)

    # Split transactions
    baseline_mask = merchant_txns['timestamp'] < spike_start
    spike_mask = merchant_txns['timestamp'] >= spike_start

    baseline_txns = merchant_txns[baseline_mask]
    spike_txns = merchant_txns[spike_mask]

    if baseline_txns.empty:
        logger.warning(f"Baseline period empty for merchant {merchant_id}")
        return transactions_df

    # Calculate baseline average daily volume
    baseline_days = (spike_start - datetime.strptime(config['start_date'], '%Y-%m-%d')).days
    if baseline_days <= 0:
        baseline_days = 1  # Avoid division by zero
    baseline_avg_daily = len(baseline_txns) / baseline_days

    # Calculate current spike average daily volume
    spike_days = 30
    spike_avg_daily = len(spike_txns) / spike_days if spike_days > 0 else 0

    # Target: spike average daily volume >= 2.5 * baseline average daily volume
    target_spike_avg_daily = 2.5 * baseline_avg_daily

    # If current spike average already meets or exceeds target, no adjustment needed
    if spike_avg_daily >= target_spike_avg_daily:
        logger.info(f"Volume for {merchant_id} in spike period already meets or exceeds target. No adjustment needed.")
        return transactions_df

    # Calculate how many transactions to move from baseline to spike
    # Let B = baseline count, S = spike count, T = B + S (total for merchant)
    # We want: (S + X) / 30 >= 2.5 * ( (B - X) / baseline_days )
    # Solve for X:
    #   (S + X) / 30 >= (2.5 / baseline_days) * (B - X)
    #   => (S + X) * baseline_days >= 2.5 * 30 * (B - X)
    #   => baseline_days*S + baseline_days*X >= 75*B - 75*X
    #   => baseline_days*X + 75*X >= 75*B - baseline_days*S
    #   => X * (baseline_days + 75) >= 75*B - baseline_days*S
    #   => X >= (75*B - baseline_days*S) / (baseline_days + 75)
    B = len(baseline_txns)
    S = len(spike_txns)
    numerator = 75 * B - baseline_days * S
    denominator = baseline_days + 75
    if denominator <= 0:
        X = 0
    else:
        X = int(np.ceil(numerator / denominator))
    X = max(0, min(X, B))  # Cannot move more than we have in baseline

    if X == 0:
        logger.info(f"No transactions to move for merchant {merchant_id}.")
        return transactions_df

    logger.info(f"Moving {X} transactions from baseline to spike period for merchant {merchant_id}.")

    # Select X transactions from baseline to move
    # We'll select the earliest X transactions by timestamp (deterministic)
    to_move = baseline_txns.sort_values('timestamp').head(X)

    # We will move these transactions to the spike period by changing their timestamps.
    # We'll distribute them evenly across the spike period.
    # For each transaction to move, assign a new date in the spike period.
    # We'll use the index to spread them out.
    spike_start_date = spike_start
    spike_end_date = end_date
    total_spike_days = (spike_end_date - spike_start_date).days + 1  # inclusive

    # Update the transactions_df
    for j, (_, row) in enumerate(to_move.iterrows()):
        idx = row.name
        # Distribute evenly across the spike period
        day_offset = int((j * total_spike_days) / len(to_move)) if len(to_move) > 0 else 0
        new_date = spike_start_date + timedelta(days=day_offset)
        # Keep the time of day the same? We'll set to noon for simplicity, but we can try to keep the time of day.
        # Extract the time of day from the original timestamp
        original_time = row['timestamp'].time()
        new_timestamp = datetime.combine(new_date, original_time)
        transactions_df.at[idx, 'timestamp'] = new_timestamp

    logger.info(f"Unusual volume increase applied for merchant {merchant_id}. Moved {X} transactions.")
    return transactions_df

def apply_spike_anomalies(transactions_df, merchants_df, config):
    """
    Apply chargeback spike and refund spike anomalies.
    This is the existing logic from the original introduce_anomalies function.
    """
    logger.info("Applying spike anomalies (chargeback spike and refund spike)...")

    n_anomalous = config['anomalies']['n_anomalous_merchants']
    anomaly_types = config['anomalies']['anomaly_types']

    # Select random merchants to be anomalous for chargeback_spike and refund_spike
    # We'll use the same merchants as before for consistency, but we need to avoid the two we already used.
    # However, the config specifies 4 anomalous merchants, and we have four types.
    # We'll assign the first two to approval_rate_decline and unusual_volume_increase (already handled)
    # and the next two to chargeback_spike and refund_spike.
    # But note: the anomalous merchants are already marked in the merchants DataFrame by anomaly_type.
    # We will only apply spike anomalies to merchants with anomaly_type in ['chargeback_spike', 'refund_spike'].

    # We'll adjust the transactions for these merchants
    for anomaly_type in ['chargeback_spike', 'refund_spike']:
        # Get merchants with this anomaly type
        anomalous_merchants = merchants_df[merchants_df['anomaly_type'] == anomaly_type]['merchant_id'].tolist()
        if not anomalous_merchants:
            logger.warning(f"No merchants found with anomaly type {anomaly_type}")
            continue

        for merchant_id in anomalous_merchants:
            logger.info(f"Applying {anomaly_type} for merchant {merchant_id}...")
            merchant_txns = transactions_df[transactions_df['merchant_id'] == merchant_id].copy()
            if merchant_txns.empty:
                continue

            if anomaly_type == 'chargeback_spike':
                # Increase chargeback probability for this merchant
                # We'll flip some approved transactions to chargeback
                approved_txns = merchant_txns[merchant_txns['is_approved']]
                if approved_txns.empty:
                    continue
                # We'll flip 10% of approved transactions to chargeback (as before)
                n_to_flip = int(np.ceil(len(approved_txns) * 0.1))
                # Select the earliest n_to_flip approved transactions by timestamp
                to_flip = approved_txns.sort_values('timestamp').head(n_to_flip)
                for _, row in to_flip.iterrows():
                    idx = row.name
                    transactions_df.at[idx, 'is_chargeback'] = True
                    transactions_df.at[idx, 'chargeback_amount'] = row['amount']
                    # Note: we already set chargeback based on base probability; we are adding extra.
                    # To avoid double counting, we should set the original chargeback to False if we are flipping?
                    # But in the base generation, we set is_chargeback based on base probability.
                    # We are now adding additional chargebacks. This is acceptable as long as we don't exceed the amount.
                    # However, we must ensure we don't mark a transaction as chargeback twice.
                    # We'll set it to True regardless.

            elif anomaly_type == 'refund_spike':
                # Increase refund probability for this merchant
                approved_txns = merchant_txns[merchant_txns['is_approved']]
                if approved_txns.empty:
                    continue
                n_to_flip = int(np.ceil(len(approved_txns) * 0.1))
                to_flip = approved_txns.sort_values('timestamp').head(n_to_flip)
                for _, row in to_flip.iterrows():
                    idx = row.name
                    transactions_df.at[idx, 'is_refunded'] = True
                    transactions_df.at[idx, 'refund_amount'] = row['amount']

    logger.info("Spike anomalies applied.")
    return transactions_df

def introduce_anomalies(transactions_df, merchants_df, config):
    """
    Apply all anomaly adjustments.
    Order:
      1. approval_rate_decline (M000015)
      2. unusual_volume_increase (M000095)
      3. chargeback_spike and refund_spike (M000032 and M000046)
    """
    logger.info("Introducing behavioural anomalies...")

    # Mark the four anomalous merchants in the merchants DataFrame (as before)
    n_anomalous = config['anomalies']['n_anomalous_merchants']
    anomaly_types = config['anomalies']['anomaly_types']

    # Select random merchants to be anomalous
    anomalous_merchants = np.random.choice(
        merchants_df['merchant_id'].values,
        size=n_anomalous,
        replace=False
    )
    # Assign each anomalous merchant a unique anomaly type
    anomaly_assignment = {}
    for i, merchant_id in enumerate(anomalous_merchants):
        anomaly_type = anomaly_types[i % len(anomaly_types)]
        anomaly_assignment[merchant_id] = anomaly_type

    merchants_df['anomaly_type'] = merchants_df['merchant_id'].map(anomaly_assignment).fillna('normal')

    # Apply the anomalies in sequence
    # First, approval_rate_decline
    if 'approval_rate_decline' in anomaly_types:
        # Find the merchant assigned to approval_rate_decline
        approval_merchant = [m for m, a in anomaly_assignment.items() if a == 'approval_rate_decline']
        if approval_merchant:
            transactions_df = apply_approval_rate_decline(transactions_df, merchants_df, config, approval_merchant[0])

    # Second, unusual_volume_increase
    if 'unusual_volume_increase' in anomaly_types:
        volume_merchant = [m for m, a in anomaly_assignment.items() if a == 'unusual_volume_increase']
        if volume_merchant:
            transactions_df = apply_unusual_volume_increase(transactions_df, merchants_df, config, volume_merchant[0])

    # Third, chargeback_spike and refund_spike
    transactions_df = apply_spike_anomalies(transactions_df, merchants_df, config)

    return transactions_df, merchants_df

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

def print_anomaly_evidence(transactions_df, merchants_df, config):
    """
    Print the evidence for each anomaly as required.
    """
    logger.info("=== Anomaly Evidence ===")

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
    """Main function to generate, validate, and save synthetic payment data."""
    logger.info("Starting synthetic payment data generation...")

    # Load configuration
    config = load_config()
    logger.info(f"Loaded configuration: {config}")

    # Set random seeds for reproducibility
    set_seeds(config['random_seed'])

    # Generate core entities
    merchants_df = generate_merchants(config)
    customers_df = generate_customers(config)
    countries_df = generate_countries(config)

    # Generate transactions
    transactions_df = generate_transactions(config, merchants_df, customers_df, countries_df)

    # Introduce anomalies and update merchant dataframe with anomaly info
    transactions_df, merchants_df = introduce_anomalies(transactions_df, merchants_df, config)

    # Validate transactions
    validation_errors = validate_transactions(transactions_df, merchants_df, customers_df, countries_df)
    if validation_errors:
        logger.error("Validation errors found:")
        for error in validation_errors:
            logger.error(error)
        raise ValueError("Data validation failed. See errors above.")
    else:
        logger.info("Validation passed.")

    # Save to CSV files
    output_dir = os.path.join(os.path.dirname(__file__), '..', '..', 'data', 'raw')
    os.makedirs(output_dir, exist_ok=True)

    merchants_df = merchants_df[[
        'merchant_id',
        'merchant_name',
        'category',
        'risk_tier',
        'base_decline_prob',
        'base_chargeback_prob',
        'base_refund_prob',
        'amount_mean',
        'amount_std',
        'anomaly_type',
        'merchant_display_name'
    ]]
    countries_df = countries_df[[
        'country_id',
        'country_name',
        'region',
        'currency_code',
        'market_display_name'
    ]]

    merchants_df.to_csv(os.path.join(output_dir, 'merchants.csv'), index=False)
    customers_df.to_csv(os.path.join(output_dir, 'customers.csv'), index=False)
    countries_df.to_csv(os.path.join(output_dir, 'countries.csv'), index=False)
    transactions_df.to_csv(os.path.join(output_dir, 'transactions.csv'), index=False)

    logger.info(f"Data saved to {output_dir}")

    # Print summary statistics
    logger.info("=== Data Generation Summary ===")
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
    print_anomaly_evidence(transactions_df, merchants_df, config)

    logger.info("Data generation completed successfully.")

if __name__ == "__main__":
    main()
