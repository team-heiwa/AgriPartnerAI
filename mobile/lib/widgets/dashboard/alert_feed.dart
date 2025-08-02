import 'package:flutter/material.dart';

class AlertFeed extends StatelessWidget {
  const AlertFeed({super.key});

  @override
  Widget build(BuildContext context) {
    final alerts = [
      Alert(
        id: '1',
        type: AlertType.pest,
        title: 'Pest activity detected',
        description: 'High pest activity in Field A - Section 3',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        severity: AlertSeverity.high,
      ),
      Alert(
        id: '2',
        type: AlertType.weather,
        title: 'Weather warning',
        description: 'Heavy rain expected in 2 hours',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        severity: AlertSeverity.medium,
      ),
      Alert(
        id: '3',
        type: AlertType.irrigation,
        title: 'Irrigation system',
        description: 'Scheduled irrigation completed in Field B',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        severity: AlertSeverity.low,
      ),
      Alert(
        id: '4',
        type: AlertType.drone,
        title: 'Drone inspection complete',
        description: 'Field C inspection completed successfully',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        severity: AlertSeverity.info,
      ),
    ];

    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Alerts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: alerts.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final alert = alerts[index];
                return _buildAlertItem(alert);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(Alert alert) {
    Color iconColor;
    IconData icon;

    switch (alert.type) {
      case AlertType.pest:
        icon = Icons.bug_report;
        iconColor = Colors.red;
        break;
      case AlertType.weather:
        icon = Icons.cloud;
        iconColor = Colors.blue;
        break;
      case AlertType.irrigation:
        icon = Icons.water_drop;
        iconColor = Colors.cyan;
        break;
      case AlertType.drone:
        icon = Icons.flight;
        iconColor = Colors.purple;
        break;
    }

    Color severityColor;
    switch (alert.severity) {
      case AlertSeverity.high:
        severityColor = Colors.red;
        break;
      case AlertSeverity.medium:
        severityColor = Colors.orange;
        break;
      case AlertSeverity.low:
        severityColor = Colors.green;
        break;
      case AlertSeverity.info:
        severityColor = Colors.blue;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        alert.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: severityColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  alert.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTimestamp(alert.timestamp),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class Alert {
  final String id;
  final AlertType type;
  final String title;
  final String description;
  final DateTime timestamp;
  final AlertSeverity severity;

  Alert({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.severity,
  });
}

enum AlertType { pest, weather, irrigation, drone }
enum AlertSeverity { high, medium, low, info }