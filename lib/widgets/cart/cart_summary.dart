import 'package:flutter/material.dart';

class CartSummary extends StatelessWidget {
  final double subtotal;
  final double deliveryFees;
  final double total;

  const CartSummary({
    super.key,
    required this.subtotal,
    required this.deliveryFees,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildRow('Subtotal', subtotal, false),
          const SizedBox(height: 12),
          _buildRow('Delivery Fees', deliveryFees, false),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          _buildRow('Total', total, true),
        ],
      ),
    );
  }

  Widget _buildRow(String label, double amount, bool isBold) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 18 : 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? Colors.black : Colors.grey[700],
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isBold ? 20 : 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold ? Colors.green : Colors.grey[800],
          ),
        ),
      ],
    );
  }
}