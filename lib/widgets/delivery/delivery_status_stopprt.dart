import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/delivery_model.dart';

class DeliveryStatusStepper extends StatelessWidget {
  final Delivery delivery;

  const DeliveryStatusStepper({
    super.key,
    required this.delivery,
  });

  int get _currentStep {
    switch (delivery.status) {
      case 'pending':
      case 'assigned':
        return 0;
      case 'picked_up':
        return 1;
      case 'in_transit':
        return 2;
      case 'delivered':
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatusItem(
            step: 0,
            title: 'Order Assigned',
            subtitle: 'Driver assigned to delivery',
            icon: Icons.assignment,
            isCompleted: _currentStep >= 0,
            isActive: _currentStep == 0,
          ),
          _buildStatusItem(
            step: 1,
            title: 'Picked Up',
            subtitle: delivery.pickupTime != null
                ? DateFormat('MMM dd, hh:mm a').format(delivery.pickupTime!)
                : 'Pending pickup',
            icon: Icons.store,
            isCompleted: _currentStep >= 1,
            isActive: _currentStep == 1,
          ),
          _buildStatusItem(
            step: 2,
            title: 'In Transit',
            subtitle: 'On the way to delivery',
            icon: Icons.local_shipping,
            isCompleted: _currentStep >= 2,
            isActive: _currentStep == 2,
          ),
          _buildStatusItem(
            step: 3,
            title: 'Delivered',
            subtitle: delivery.deliveryTime != null
                ? DateFormat('MMM dd, hh:mm a').format(delivery.deliveryTime!)
                : 'Pending delivery',
            icon: Icons.check_circle,
            isCompleted: _currentStep >= 3,
            isActive: _currentStep == 3,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem({
    required int step,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isCompleted,
    required bool isActive,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green
                      : isActive
                          ? Colors.blue
                          : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCompleted ? Icons.check : icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: isCompleted ? Colors.green : Colors.grey[300],
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isCompleted || isActive
                          ? Colors.black
                          : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}