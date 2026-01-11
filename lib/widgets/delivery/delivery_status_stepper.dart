import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/delivery_model.dart';

class DeliveryStatusStepper extends StatelessWidget {
  final Delivery delivery;

  const DeliveryStatusStepper({
    super.key,
    required this.delivery,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildStep(
          context: context,
          title: 'Driver Assigned',
          subtitle: delivery.assignedAt != null
              ? DateFormat('MMM d, h:mm a').format(delivery.assignedAt!)
              : null,
          isCompleted: delivery.assignedAt != null,
          isActive: delivery.status == 'assigned',
          icon: Icons.person,
        ),
        _buildConnector(isCompleted: delivery.pickedUpAt != null),
        _buildStep(
          context: context,
          title: 'Item Picked Up',
          subtitle: delivery.pickedUpAt != null // ✅ FIXED - was pickupTime
              ? DateFormat('MMM d, h:mm a').format(delivery.pickedUpAt!) // ✅ FIXED
              : null,
          isCompleted: delivery.pickedUpAt != null,
          isActive: delivery.status == 'in_transit' && delivery.pickedUpAt != null,
          icon: Icons.inventory,
        ),
        _buildConnector(isCompleted: delivery.deliveredAt != null),
        _buildStep(
          context: context,
          title: delivery.isCancelled ? 'Cancelled' : 'Delivered',
          subtitle: delivery.deliveredAt != null // ✅ FIXED - was deliveryTime
              ? DateFormat('MMM d, h:mm a').format(delivery.deliveredAt!) // ✅ FIXED
              : delivery.isCancelled && delivery.failureReason != null
                  ? delivery.failureReason
                  : null,
          isCompleted: delivery.deliveredAt != null || delivery.isCancelled,
          isActive: false,
          icon: delivery.isCancelled ? Icons.cancel : Icons.check_circle,
          iconColor: delivery.isCancelled ? Colors.red : Colors.green,
        ),
      ],
    );
  }

  Widget _buildStep({
    required BuildContext context,
    required String title,
    String? subtitle,
    required bool isCompleted,
    required bool isActive,
    required IconData icon,
    Color? iconColor,
  }) {
    final color = isCompleted
        ? (iconColor ?? Colors.green)
        : isActive
            ? Colors.blue
            : Colors.grey;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1), // ✅ FIXED deprecation
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isCompleted || isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isCompleted || isActive ? Colors.black87 : Colors.grey[600],
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConnector({required bool isCompleted}) {
    return Padding(
      padding: const EdgeInsets.only(left: 19),
      child: Container(
        width: 2,
        height: 30,
        color: isCompleted ? Colors.green : Colors.grey[300],
      ),
    );
  }
}