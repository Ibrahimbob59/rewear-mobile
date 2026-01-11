import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/delivery_provider.dart';
import '../../services/image_upload_service.dart';
import '../../widgets/delivery/delivery_status_stepper.dart';
import '../../widgets/delivery/delivery_map_widget.dart';
import '../../models/delivery_model.dart';

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

    if (!mounted) return; // ✅ FIXED

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
    if (delivery.codAmount != null && delivery.codAmount! > 0) { // ✅ FIXED
      if (!mounted) return; // ✅ FIXED
      codCollected = await _showCODDialog(delivery.codAmount!); // ✅ FIXED
      if (codCollected == null) return;
    }

    if (!mounted) return; // ✅ FIXED

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Delivery completed!'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/driver-dashboard');
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

  Future<void> _showCancelDialog(Delivery delivery) async { // ✅ FIXED - added type
    String? selectedReason;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Cancel Delivery'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Why are you cancelling this delivery?',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                ),
                value: selectedReason,
                items: const [
                  DropdownMenuItem(
                    value: 'Seller not available',
                    child: Text('Seller not available'),
                  ),
                  DropdownMenuItem(
                    value: 'Wrong pickup address',
                    child: Text('Wrong pickup address'),
                  ),
                  DropdownMenuItem(
                    value: 'Vehicle breakdown',
                    child: Text('Vehicle breakdown'),
                  ),
                  DropdownMenuItem(
                    value: 'Personal emergency',
                    child: Text('Personal emergency'),
                  ),
                  DropdownMenuItem(
                    value: 'Other',
                    child: Text('Other'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedReason = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'A new delivery will be created for another driver',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep Delivery'),
            ),
            TextButton(
              onPressed: () {
                if (selectedReason == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a reason')),
                  );
                  return;
                }
                Navigator.pop(context, true);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Cancel Delivery'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && selectedReason != null && mounted) {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final success = await context.read<DeliveryProvider>().cancelDelivery(
        deliveryId: delivery.id,
        reason: selectedReason!,
      );

      if (!mounted) return;

      // Close loading
      Navigator.pop(context);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery cancelled successfully. A new delivery has been created for reassignment.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        context.go('/driver-dashboard');
      } else {
        final error = context.read<DeliveryProvider>().error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to cancel delivery'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<double?> _showCODDialog(double expectedAmount) async {
    final controller = TextEditingController(text: expectedAmount.toString());

    return showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cash on Delivery'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Expected amount: \$${expectedAmount.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount Collected',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
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

  void _callPhone(String phone) async {
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open phone dialer')),
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
          if (deliveryProvider.isLoading && deliveryProvider.selectedDelivery == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final delivery = deliveryProvider.selectedDelivery;
          if (delivery == null) {
            return const Center(child: Text('Delivery not found'));
          }

          final order = delivery.order;
          final isBeforePickup = delivery.pickedUpAt == null;
          
          // ✅ FIXED - Use pickup/delivery address from main delivery object
          final currentLocation = isBeforePickup 
              ? delivery.pickupAddress ?? 'Pickup address not available'
              : delivery.deliveryAddress ?? 'Delivery address not available';
          
          final currentContact = isBeforePickup 
              ? order?.sellerName ?? 'Seller'
              : order?.buyerName ?? 'Buyer';
          
          final currentPhone = isBeforePickup 
              ? order?.sellerPhone 
              : order?.buyerPhone;

          return Column(
            children: [
              // Map
              if (delivery.pickupLatitude != null && delivery.pickupLongitude != null)
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

                      // Current Destination
                      _buildInfoCard(
                        title: isBeforePickup ? 'PICKUP FROM' : 'DELIVER TO',
                        icon: isBeforePickup ? Icons.store : Icons.home,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentContact,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentLocation,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: currentPhone != null 
                                        ? () => _callPhone(currentPhone) 
                                        : null,
                                    icon: const Icon(Icons.phone, size: 18),
                                    label: const Text('Call'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      final lat = isBeforePickup 
                                          ? delivery.pickupLatitude 
                                          : delivery.deliveryLatitude;
                                      final lng = isBeforePickup 
                                          ? delivery.pickupLongitude 
                                          : delivery.deliveryLongitude;
                                      if (lat != null && lng != null) {
                                        _openNavigation(lat, lng);
                                      }
                                    },
                                    icon: const Icon(Icons.navigation, size: 18),
                                    label: const Text('Navigate'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Order Details
                      _buildInfoCard(
                        title: 'ORDER DETAILS',
                        icon: Icons.shopping_bag,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order?.itemTitle ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Delivery Fee:',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                Text(
                                  delivery.deliveryFeeDisplay,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Your Earning:',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                Text(
                                  delivery.driverEarningDisplay,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Notes Field
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
                  color: Colors.black.withValues(alpha: 0.05), // ✅ FIXED deprecation
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Cancel Button (only before pickup)
                  if (deliveryProvider.canCancelDelivery(delivery)) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: deliveryProvider.isLoading 
                            ? null 
                            : () => _showCancelDialog(delivery),
                        icon: const Icon(Icons.cancel, size: 20),
                        label: const Text('Cancel Delivery'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Main Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: deliveryProvider.isLoading
                          ? null
                          : delivery.pickedUpAt != null
                              ? _confirmDelivery
                              : _confirmPickup,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: deliveryProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              delivery.pickedUpAt != null
                                  ? 'Mark as Delivered'
                                  : 'Mark as Picked Up',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), // ✅ FIXED deprecation
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}