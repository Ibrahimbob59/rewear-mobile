import 'package:flutter/material.dart';
import '../../models/condition_enum.dart';

class ConditionBadge extends StatelessWidget {
  final Condition condition;

  const ConditionBadge({
    super.key,
    required this.condition,
  });

  Color get _backgroundColor {
    switch (condition) {
      case Condition.brandNew:
        return Colors.green;
      case Condition.likeNew:
        return Colors.blue;
      case Condition.good:
        return Colors.orange;
      case Condition.fair:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        condition.displayName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}