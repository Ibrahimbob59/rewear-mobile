import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/delivery_provider.dart';

class OrderTrackingScreen extends StatefulWidget {
  final int orderId;
  
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
      _loadDeliveryInfo();
    });
  }

  Future<void> _loadDeliveryInfo() async {
    // Try to load delivery info for this order
    // This is a placeholder - you'd need to get delivery ID from order
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Order'),
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
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadDeliveryInfo,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // FIXED: Changed from selectedDelivery to currentDelivery
          final delivery = deliveryProvider.currentDelivery;

          if (delivery == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_shipping_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No delivery information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Delivery tracking will appear here once assigned',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return _buildTrackingView(delivery);
        },
      ),
    );
  }

  Widget _buildTrackingView(Map<String, dynamic> delivery) {
    final status = delivery['status'] ?? 'pending';
    final driverName = delivery['driver']?['name'] ?? 'Not assigned';
    final driverPhone = delivery['driver']?['phone'] ?? '';
    final pickupAddress = delivery['pickup_address'] ?? '';
    final deliveryAddress = delivery['delivery_address'] ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _getStatusColors(status),
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  _getStatusIcon(status),
                  color: Colors.white,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  _formatStatus(status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getStatusMessage(status),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Driver Info (if assigned)
          if (status != 'pending') ...[
            const Text(
              'Driver Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                title: Text(driverName),
                subtitle: driverPhone.isNotEmpty 
                    ? Text(driverPhone)
                    : const Text('Contact info not available'),
                trailing: driverPhone.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.phone),
                        onPressed: () {
                          // Call driver
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Addresses
          const Text(
            'Delivery Route',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildAddressRow(
                    Icons.location_on_outlined,
                    'Pickup',
                    pickupAddress,
                    status == 'assigned' || status == 'pending',
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 2,
                    height: 40,
                    color: Colors.grey[300],
                    margin: const EdgeInsets.only(left: 10),
                  ),
                  const SizedBox(height: 16),
                  _buildAddressRow(
                    Icons.location_on,
                    'Delivery',
                    deliveryAddress,
                    status == 'delivered' || status == 'completed',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Refresh Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _loadDeliveryInfo,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Status'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressRow(
    IconData icon,
    String label,
    String address,
    bool isActive,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: isActive ? Colors.green : Colors.grey,
          size: 28,
        ),
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
                address.isNotEmpty ? address : 'Address not available',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isActive ? Colors.black : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Color> _getStatusColors(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return [Colors.orange[400]!, Colors.orange[600]!];
      case 'assigned':
        return [Colors.blue[400]!, Colors.blue[600]!];
      case 'in_transit':
      case 'picked_up':
        return [Colors.purple[400]!, Colors.purple[600]!];
      case 'delivered':
      case 'completed':
        return [Colors.green[400]!, Colors.green[600]!];
      default:
        return [Colors.grey[400]!, Colors.grey[600]!];
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending;
      case 'assigned':
        return Icons.assignment_ind;
      case 'in_transit':
      case 'picked_up':
        return Icons.local_shipping;
      case 'delivered':
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'assigned':
        return 'Driver Assigned';
      case 'in_transit':
        return 'In Transit';
      case 'picked_up':
        return 'Picked Up';
      case 'delivered':
        return 'Delivered';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }

  String _getStatusMessage(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Waiting for driver assignment';
      case 'assigned':
        return 'Driver has been assigned to your delivery';
      case 'in_transit':
        return 'Your package is on the way';
      case 'picked_up':
        return 'Driver has picked up your package';
      case 'delivered':
        return 'Your package has been delivered';
      case 'completed':
        return 'Delivery completed successfully';
      default:
        return 'Tracking your delivery';
    }
  }
}