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

          return Column(
            children: [
              // Map
              if (delivery.driver != null)
                DeliveryMapWidget(
                  delivery: delivery,
                  currentPosition: null, // Driver's current position from backend
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

                      // Driver Info (if assigned)
                      if (delivery.driver != null) ...[
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
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Theme.of(context).primaryColor,
                                child: Text(
                                  delivery.driver!.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (delivery.driver!.vehicleType != null)
                                      Text(
                                        '${delivery.driver!.vehicleType} • ${delivery.driver!.vehicleNumber ?? ""}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    if (delivery.driver!.rating != null)
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            size: 14,
                                            color: Colors.amber,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            delivery.driver!.rating!.toStringAsFixed(1),
                                            style: const TextStyle(fontSize: 13),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => _callDriver(delivery.driver!.phone),
                                icon: const Icon(Icons.phone),
                                color: Theme.of(context).primaryColor,
                                style: IconButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Delivery Details
                      const Text(
                        'Delivery Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      _buildInfoCard(
                        title: 'Pickup Address',
                        content: delivery.pickupAddress,
                        icon: Icons.store,
                      ),
                      
                      const SizedBox(height: 12),
                      
                      _buildInfoCard(
                        title: 'Delivery Address',
                        content: delivery.deliveryAddress,
                        icon: Icons.home,
                      ),

                      const SizedBox(height: 12),

                      _buildInfoCard(
                        title: 'Delivery Fee',
                        content: delivery.deliveryFeeDisplay,
                        icon: Icons.local_shipping,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
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
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}