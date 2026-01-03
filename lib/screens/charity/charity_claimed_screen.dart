import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/items/empty_state.dart';

class CharityClaimedScreen extends StatelessWidget {
  const CharityClaimedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Claimed Donations'),
      ),
      body: EmptyState(
        icon: Icons.check_circle_outline,
        title: 'No claimed donations yet',
        message: 'Donations you claim will appear here',
        actionLabel: 'Browse Donations',
        onAction: () => context.push('/charity/donations'),
      ),
    );
  }
}