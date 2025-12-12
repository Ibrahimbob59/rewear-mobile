import 'package:flutter/material.dart';

enum DeliveryStatus {
  pending('pending', 'Pending', 'Waiting for driver', Colors.orange),
  assigned('assigned', 'Assigned', 'Driver assigned', Colors.blue),
  pickedUp('picked_up', 'Picked Up', 'Item picked up', Colors.purple),
  inTransit('in_transit', 'In Transit', 'On the way', Colors.indigo),
  delivered('delivered', 'Delivered', 'Successfully delivered', Colors.green),
  failed('failed', 'Failed', 'Delivery failed', Colors.red),
  cancelled('cancelled', 'Cancelled', 'Delivery cancelled', Colors.grey);

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
      this == DeliveryStatus.pickedUp || 
      this == DeliveryStatus.inTransit;

  bool get isCompleted => 
      this == DeliveryStatus.delivered || 
      this == DeliveryStatus.failed || 
      this == DeliveryStatus.cancelled;
}