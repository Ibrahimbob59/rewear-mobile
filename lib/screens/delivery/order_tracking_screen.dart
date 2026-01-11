import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/delivery_provider.dart';
import '../../widgets/delivery/delivery_status_stepper.dart';
import '../../widgets/delivery/delivery_map_widget.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeliveryProvider>().trackDelivery(int.parse(widget.orderId));
    });
  }

  void _callDriver(String phone) async {
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
        title: const Text('Track Delivery'),
      ),
      body: Consumer<DeliveryProvider>(
        builder: (context, deliveryProvider, child) {
          if (deliveryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final delivery = deliveryProvider.selectedDelivery;
          if (delivery == null) {
            return const Center(child: Text('Delivery information not available'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Map
                if (delivery.driver != null && 
                    delivery.pickupLatitude != null && 
                    delivery.pickupLongitude != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: DeliveryMapWidget(
                      delivery: delivery,
                      currentPosition: null,
                    ),
                  ),

                // Status Stepper
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
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
                    child: DeliveryStatusStepper(delivery: delivery),
                  ),
                ),

                // Driver Info (if assigned)
                if (delivery.driver != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Driver',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
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
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.blue[100],
                                backgroundImage: delivery.driver!.profilePicture != null
                                    ? NetworkImage(delivery.driver!.profilePicture!)
                                    : null,
                                child: delivery.driver!.profilePicture == null
                                    ? const Icon(Icons.person, size: 30)
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      delivery.driver!.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (delivery.driver!.vehicleType != null)
                                      Text(
                                        delivery.driver!.vehicleType!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    if (delivery.driver!.rating != null)
                                      Row(
                                        children: [
                                          const Icon(Icons.star, size: 16, color: Colors.amber),
                                          const SizedBox(width: 4),
                                          Text(
                                            delivery.driver!.rating!.toStringAsFixed(1),
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                              if (delivery.driver!.phone != null)
                                IconButton(
                                  onPressed: () => _callDriver(delivery.driver!.phone!), // ✅ FIXED
                                  icon: const Icon(Icons.phone),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.green[50],
                                    foregroundColor: Colors.green[700],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Delivery Info
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
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
                        const Text(
                          'Delivery Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          icon: Icons.location_on,
                          label: 'Pickup',
                          value: delivery.pickupAddress ?? 'N/A', // ✅ FIXED
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          icon: Icons.home,
                          label: 'Delivery',
                          value: delivery.deliveryAddress ?? 'N/A', // ✅ FIXED
                        ),
                        if (delivery.distanceKm != null) ...[
                          const Divider(height: 24),
                          _buildInfoRow(
                            icon: Icons.straighten,
                            label: 'Distance',
                            value: '${delivery.distanceKm!.toStringAsFixed(1)} km',
                          ),
                        ],
                        const Divider(height: 24),
                        _buildInfoRow(
                          icon: Icons.attach_money,
                          label: 'Delivery Fee',
                          value: delivery.deliveryFeeDisplay,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}