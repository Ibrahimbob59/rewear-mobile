import 'package:flutter/material.dart';

enum ItemStatus {
  available('available', 'Available', 'Ready for purchase', Colors.green),
  pending('pending', 'Pending', 'Order placed, awaiting delivery', Colors.orange),
  sold('sold', 'Sold', 'Item has been sold', Colors.grey),
  donated('donated', 'Donated', 'Item has been donated', Colors.blue),
  unavailable('unavailable', 'Unavailable', 'Temporarily unavailable', Colors.red);

  final String value;
  final String displayName;
  final String description;
  final Color color;

  const ItemStatus(this.value, this.displayName, this.description, this.color);

  static ItemStatus fromString(String value) {
    return ItemStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ItemStatus.unavailable,
    );
  }

  bool get canPurchase => this == ItemStatus.available;
  bool get canEdit => this == ItemStatus.available || this == ItemStatus.unavailable;

  static List<ItemStatus> get all => ItemStatus.values;
}