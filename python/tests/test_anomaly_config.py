"""Self-contained checks for the authoritative anomaly configuration."""
import os

import yaml


CONFIG_PATH = os.path.join(
    os.path.dirname(__file__), '..', 'config', 'generator_config.yaml'
)


def test_anomaly_configuration_matches_current_effective_behavior():
    with open(CONFIG_PATH, 'r') as f:
        config = yaml.safe_load(f)

    anomalies = config['anomalies']
    assert anomalies['anomaly_count'] == 4
    assert anomalies['anomaly_types'] == [
        'approval_rate_decline',
        'chargeback_spike',
        'refund_spike',
        'unusual_volume_increase',
    ]
    assert anomalies['approval_rate_decline'] == {
        'window_days': 60,
        'minimum_approval_rate_drop': 0.15,
    }
    assert anomalies['unusual_volume_increase'] == {
        'window_days': 30,
        'minimum_volume_multiplier': 2.5,
    }
    assert anomalies['chargeback_spike']['approved_transaction_flip_fraction'] == 0.10
    assert anomalies['refund_spike']['approved_transaction_flip_fraction'] == 0.10
