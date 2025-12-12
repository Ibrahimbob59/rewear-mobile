import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/delivery_provider.dart';
import '../../services/image_upload_service.dart';
import '../../widgets/delivery/delivery_status_stepper.dart';
import '../../widgets/delivery/delivery_map_widget.dart';

class ActiveDeliveryScreen extends StatefulWidget {
  final String deliveryId;

  const ActiveDeliveryScreen({
    super.key,
    required this.deliveryId,
  });

  @override
  State<ActiveDeliveryScreen> createState() => _ActiveDeliveryScreenState();
}

class _ActiveDeliveryScreenState extends State<ActiveDeliveryScreen> {
  final _imageUploadService = ImageUploadService();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DeliveryProvider>();
      provider.loadDelivery(int.parse(widget.deliveryId));
      provider.startLocationTracking(int.parse(widget.deliveryId));
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    context.read<DeliveryProvider>().stopLocationTracking();
    super.dispose();
  }

  Future<void> _confirmPickup() async {
    final image = await _imageUploadService.pickImage();
    if (image == null) return;

    final success = await context.read<DeliveryProvider>().confirmPickup(
      deliveryId: int.parse(widget.deliveryId),
      proofImage: image,
      notes: _notesController.text.trim().isEmpty 
          ? null 
          : _notesController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pickup confirmed!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final error = context.read<DeliveryProvider>().error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to confirm pickup'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmDelivery() async {
    final delivery = context.read<DeliveryProvider>().selectedDelivery;
    if (delivery == null) return;

    final image = await _imageUploadService.pickImage();
    if (image == null) return;

    // If COD, ask for amount
    double? codCollected;
    if (delivery.codAmount != null && delivery.codAmount! > 0) {
      codCollected = await _showCODDialog(delivery.codAmount!);
      if (codCollected == null) return;
    }

    final success = await context.read<DeliveryProvider>().confirmDelivery(
      deliveryId: int.parse(widget.deliveryId),
      proofImage: image,
      codCollected: codCollected,
      notes: _notesController.text.trim().isEmpty 
          ? null 
          : _notesController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 60),
          title: const Text('Delivery Completed!'),
          content: const Text(
            'Great job! The delivery has been completed successfully.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                context.go('/driver-dashboard');
              },
              child: const Text('Back to Dashboard'),
            ),
          ],
        ),
      );
    } else {
      final error = context.read<DeliveryProvider>().error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to confirm delivery'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<double?> _showCODDialog(double expectedAmount) async {
    final controller = TextEditingController(
      text: expectedAmount.toStringAsFixed(2),
    );

    return showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Collect Cash on Delivery'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Expected amount: \$${expectedAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Amount Collected',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              Navigator.pop(context, amount);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _openNavigation(double lat, double lng) async {
    final url = Uri.parse('google.navigation:q=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open navigation')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Delivery'),
      ),
      body: Consumer<DeliveryProvider>(
        builder: (context, deliveryProvider, child) {
          if (deliveryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final delivery = deliveryProvider.selectedDelivery;
          if (delivery == null) {
            return const Center(child: Text('Delivery not found'));
          }

          return Column(
            children: [
              // Map
              DeliveryMapWidget(
                delivery: delivery,
                currentPosition: deliveryProvider.currentPosition,
              ),

              // Delivery Info
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Stepper
                      DeliveryStatusStepper(delivery: delivery),

                      const SizedBox(height: 24),

                      // Order Info
                      _buildInfoCard(
                        title: 'Order Details',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              delivery.order?.itemTitle ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Delivery Fee: ${delivery.deliveryFeeDisplay}'),
                            if (delivery.codAmount != null)
                              Text('COD Amount: ${delivery.codAmountDisplay}'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Pickup Address
                      _buildInfoCard(
                        title: 'Pickup Address',
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(delivery.pickupAddress),
                            ),
                            IconButton(
                              icon: const Icon(Icons.navigation),
                              onPressed: () => _openNavigation(
                                delivery.pickupLatitude,
                                delivery.pickupLongitude,
                              ),
                              color: Theme.of(context).primaryColor,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Delivery Address
                      _buildInfoCard(
                        title: 'Delivery Address',
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(delivery.deliveryAddress),
                            ),
                            IconButton(
                              icon: const Icon(Icons.navigation),
                              onPressed: () => _openNavigation(
                                delivery.deliveryLatitude,
                                delivery.deliveryLongitude,
                              ),
                              color: Theme.of(context).primaryColor,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Notes
                      TextField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes (Optional)',
                          hintText: 'Add any notes about the delivery...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Consumer<DeliveryProvider>(
        builder: (context, deliveryProvider, child) {
          final delivery = deliveryProvider.selectedDelivery;
          if (delivery == null) return const SizedBox.shrink();

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: deliveryProvider.isLoading
                      ? null
                      : delivery.isPickedUp
                          ? _confirmDelivery
                          : _confirmPickup,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    delivery.isPickedUp 
                        ? 'Confirm Delivery' 
                        : 'Confirm Pickup',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({required String title, required Widget child}) {
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
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}