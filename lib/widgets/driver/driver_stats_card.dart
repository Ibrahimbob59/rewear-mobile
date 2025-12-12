import 'package:flutter/material.dart';

class DriverStatsCard extends StatelessWidget {
  final Map<String, dynamic>? stats;

  const DriverStatsCard({
    super.key,
    this.stats,
  });

  @override
  Widget build(BuildContext context) {
    if (stats == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            icon: Icons.check_circle,
            title: 'Completed',
            value: '${stats!['completed'] ?? 0}',
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
            icon: Icons.local_shipping,
            title: 'Active',
            value: '${stats!['active'] ?? 0}',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
            icon: Icons.star,
            title: 'Rating',
            value: (stats!['rating'] ?? 0).toStringAsFixed(1),
            color: Colors.amber,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}