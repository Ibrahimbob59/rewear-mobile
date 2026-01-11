import 'package:flutter/material.dart';

enum DeliveryStatus {
  pending('pending', 'Pending', 'Waiting for driver', Colors.orange),
  assigned('assigned', 'Assigned', 'Driver assigned', Colors.blue),
  inTransit('in_transit', 'In Transit', 'On the way', Colors.indigo),
  delivered('delivered', 'Delivered', 'Successfully delivered', Colors.green),
  cancelled('cancelled', 'Cancelled', 'Delivery cancelled', Colors.red);

  final String value;
  final String displayName;
  final String description;
  final Color color;

  const DeliveryStatus(this.value, this.displayName, this.description, this.color);

  static DeliveryStatus fromValue(String value) {
    return DeliveryStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => DeliveryStatus.pending,
    );
  }

  static List<DeliveryStatus> get all => DeliveryStatus.values;

  bool get isActive => 
      this == DeliveryStatus.assigned || 
      this == DeliveryStatus.inTransit;

  bool get isCompleted => 
      this == DeliveryStatus.delivered || 
      this == DeliveryStatus.cancelled;
      
  bool get canBeCancelled =>
      this == DeliveryStatus.pending ||
      this == DeliveryStatus.assigned;
}