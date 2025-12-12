import 'package:flutter/material.dart';

enum DriverStatus {
  pending('pending', 'Pending', 'Application under review', Colors.orange),
  approved('approved', 'Approved', 'Ready to accept deliveries', Colors.green),
  rejected('rejected', 'Rejected', 'Application rejected', Colors.red),
  suspended('suspended', 'Suspended', 'Account suspended', Colors.grey),
  active('active', 'Active', 'Currently delivering', Colors.blue);

  final String value;
  final String displayName;
  final String description;
  final Color color;

  const DriverStatus(this.value, this.displayName, this.description, this.color);

  static DriverStatus fromValue(String value) {
    return DriverStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => DriverStatus.pending,
    );
  }

  static List<DriverStatus> get all => DriverStatus.values;
}