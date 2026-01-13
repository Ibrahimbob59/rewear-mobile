import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/delivery_provider.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load active, available deliveries and history when dashboard initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🏠 Dashboard: initState - loading deliveries...');
      final provider = context.read<DeliveryProvider>();
      provider.loadActiveDeliveries();
      provider.loadAvailableDeliveries();
      provider.loadDeliveryHistory(); // Load history for stats calculation
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              print('🔄 Dashboard: Manual refresh triggered');
              final provider = context.read<DeliveryProvider>();
              provider.loadActiveDeliveries();
              provider.loadAvailableDeliveries();
              provider.loadDeliveryHistory(); // Also refresh history
            },
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withAlpha(200),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.local_shipping,
                      color: Theme.of(context).primaryColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(
                            color: Colors.white.withAlpha(230),
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          user?.name ?? 'Driver',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Today\'s Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Consumer<DeliveryProvider>(
              builder: (context, deliveryProvider, child) {
                print('📊 Dashboard: Building stats widget...');
                print('   Delivery history count: ${deliveryProvider.deliveryHistory.length}');

                // Calculate today's stats from delivery history
                final today = DateTime.now();
                print('   Today: ${today.year}-${today.month}-${today.day}');

                final todayDeliveries = deliveryProvider.deliveryHistory.where((d) {
                  // delivered_at is inside timeline object
                  final timeline = d['timeline'] as Map<String, dynamic>?;
                  final deliveredAt = timeline?['delivered_at'];
                  print('   Checking delivery #${d['id']}: delivered_at=$deliveredAt');

                  if (deliveredAt == null) return false;

                  try {
                    final deliveryDate = DateTime.parse(deliveredAt.toString());
                    final isToday = deliveryDate.year == today.year &&
                                    deliveryDate.month == today.month &&
                                    deliveryDate.day == today.day;

                    if (isToday) {
                      print('   ✓ Today delivery found! #${d['id']}, earning: ${d['driver_earning']}');
                    }

                    return isToday;
                  } catch (e) {
                    print('   ❌ Error parsing date: $e');
                    return false;
                  }
                }).toList();

                final todayCount = todayDeliveries.length;
                final todayEarnings = todayDeliveries.fold<double>(
                  0,
                  (sum, d) => sum + (double.tryParse(d['driver_earning']?.toString() ?? '0') ?? 0),
                );

                print('   📊 Today: $todayCount deliveries, \$$todayEarnings');

                return Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.delivery_dining,
                        label: 'Deliveries',
                        value: '$todayCount',
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.attach_money,
                        label: 'Earnings',
                        value: '\$${todayEarnings.toStringAsFixed(2)}',
                        color: Colors.green,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Consumer<DeliveryProvider>(
              builder: (context, deliveryProvider, child) {
                return Row(
                  children: [
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.list_alt,
                        label: 'Available Deliveries',
                        count: deliveryProvider.availableDeliveries.length,
                        onTap: () {
                          context.push('/driver/available-deliveries');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.account_balance_wallet,
                        label: 'Earnings',
                        onTap: () {
                          context.push('/driver/earnings');
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Consumer<DeliveryProvider>(
              builder: (context, deliveryProvider, child) {
                return Row(
                  children: [
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.history,
                        label: 'Delivery History',
                        onTap: () {
                          context.push('/driver/history');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.local_shipping,
                        label: 'My Deliveries',
                        count: deliveryProvider.activeDeliveries.length,
                        onTap: () {
                          context.push('/driver/history');
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            const Text(
              'Active Deliveries',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Consumer<DeliveryProvider>(
              builder: (context, deliveryProvider, child) {
                final activeDeliveries = deliveryProvider.activeDeliveries;

                if (deliveryProvider.isLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (activeDeliveries.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(
                            'No active deliveries',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: activeDeliveries.map((delivery) {
                    final deliveryId = delivery['id'] ?? 0;
                    final order = delivery['order'] as Map<String, dynamic>?;
                    final orderNumber = order?['order_number'] ?? 'N/A';
                    final item = order?['item'] as Map<String, dynamic>?;
                    final itemTitle = item?['title'] ?? 'Unknown Item';
                    final status = delivery['status'] ?? 'unknown';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(status),
                          child: const Icon(
                            Icons.local_shipping,
                            color: Colors.white,
                          ),
                        ),
                        title: Text('Delivery #$deliveryId'),
                        subtitle: Text('$orderNumber - $itemTitle'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          context.push('/driver/delivery/$deliveryId');
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'assigned':
        return Colors.blue;
      case 'in_transit':
      case 'picked_up':
        return Colors.orange;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(76)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int? count;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Icon(icon, size: 32, color: Theme.of(context).primaryColor),
                if (count != null && count! > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        count.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}