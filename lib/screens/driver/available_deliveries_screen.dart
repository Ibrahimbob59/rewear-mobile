import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/delivery_provider.dart';
import '../../widgets/driver/delivery_card.dart';
import '../../widgets/items/empty_state.dart';

class AvailableDeliveriesScreen extends StatefulWidget {
  const AvailableDeliveriesScreen({super.key});

  @override
  State<AvailableDeliveriesScreen> createState() => _AvailableDeliveriesScreenState();
}

class _AvailableDeliveriesScreenState extends State<AvailableDeliveriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeliveryProvider>().loadAvailableDeliveries();
    });
  }

  Future<void> _onRefresh() async {
    await context.read<DeliveryProvider>().loadAvailableDeliveries();
  }

  Future<void> _acceptDelivery(int deliveryId) async {
    final success = await context.read<DeliveryProvider>().acceptDelivery(deliveryId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Delivery accepted!'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/driver-dashboard');
    } else {
      final error = context.read<DeliveryProvider>().error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to accept delivery'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Available Deliveries'),
      ),
      body: Consumer<DeliveryProvider>(
        builder: (context, deliveryProvider, child) {
          if (deliveryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (deliveryProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(deliveryProvider.error!),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _onRefresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (deliveryProvider.availableDeliveries.isEmpty) {
            return EmptyState(
              icon: Icons.inbox_outlined,
              title: 'No deliveries available',
              message: 'Check back later for new delivery opportunities',
              actionLabel: 'Refresh',
              onAction: _onRefresh,
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: deliveryProvider.availableDeliveries.length,
              itemBuilder: (context, index) {
                final delivery = deliveryProvider.availableDeliveries[index];
                return DeliveryCard(
                  delivery: delivery,
                  onAccept: () => _acceptDelivery(delivery.id),
                  showAcceptButton: true,
                );
              },
            ),
          );
        },
      ),
    );
  }
}