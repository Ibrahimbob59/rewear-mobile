import 'package:flutter/material.dart';

enum OrderStatus {
  pending('pending', 'Pending', 'Waiting for seller confirmation', Colors.orange),
  confirmed('confirmed', 'Confirmed', 'Seller confirmed, awaiting driver', Colors.blue),
  inDelivery('in_delivery', 'In Delivery', 'Driver is delivering', Colors.purple),
  delivered('delivered', 'Delivered', 'Package delivered', Colors.green),
  completed('completed', 'Completed', 'Order completed successfully', Colors.teal),
  cancelled('cancelled', 'Cancelled', 'Order was cancelled', Colors.red);

  final String value;
  final String displayName;
  final String description;
  final Color color;

  const OrderStatus(this.value, this.displayName, this.description, this.color);

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => OrderStatus.pending,
    );
  }

  bool get canCancel => this == OrderStatus.pending || this == OrderStatus.confirmed;
  
  bool get isActive => 
      this != OrderStatus.delivered && 
      this != OrderStatus.completed && 
      this != OrderStatus.cancelled;

  static List<OrderStatus> get all => OrderStatus.values;
}