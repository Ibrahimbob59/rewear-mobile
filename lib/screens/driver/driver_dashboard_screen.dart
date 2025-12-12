import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/driver_provider.dart';
import '../../providers/delivery_provider.dart';
import '../../widgets/driver/driver_stats_card.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriverProvider>().loadDriverProfile();
      context.read<DriverProvider>().loadStats();
      context.read<DeliveryProvider>().loadActiveDeliveries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Driver Dashboard'),
        actions: [
          // Availability Toggle
          Consumer<DriverProvider>(
            builder: (context, driverProvider, child) {
              if (!driverProvider.isApproved) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(
                  children: [
                    Text(
                      driverProvider.isAvailable ? 'Online' : 'Offline',
                      style: TextStyle(
                        fontSize: 13,
                        color: driverProvider.isAvailable 
                            ? Colors.green 
                            : Colors.grey[600],
                      ),
                    ),
                    Switch(
                      value: driverProvider.isAvailable,
                      onChanged: (value) {
                        driverProvider.toggleAvailability();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<DriverProvider>(
        builder: (context, driverProvider, child) {
          if (driverProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!driverProvider.isDriver) {
            return _buildNotDriverView(context);
          }

          if (driverProvider.isPending) {
            return _buildPendingView(context);
          }

          if (driverProvider.isRejected) {
            return _buildRejectedView(context);
          }

          // Approved driver dashboard
          return RefreshIndicator(
            onRefresh: () async {
              await driverProvider.loadDriverProfile();
              await driverProvider.loadStats();
              await context.read<DeliveryProvider>().loadActiveDeliveries();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Driver Info Card
                  _buildDriverInfoCard(driverProvider),

                  const SizedBox(height: 16),

                  // Stats Cards
                  DriverStatsCard(stats: driverProvider.stats),

                  const SizedBox(height: 24),

                  // Active Deliveries
                  Consumer<DeliveryProvider>(
                    builder: (context, deliveryProvider, child) {
                      if (deliveryProvider.hasActiveDelivery) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Active Delivery',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...deliveryProvider.activeDeliveries.map(
                              (delivery) => Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: const Icon(Icons.local_shipping),
                                  title: Text(delivery.order?.itemTitle ?? 'Delivery'),
                                  subtitle: Text(delivery.status),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                  onTap: () {
                                    context.push('/active-delivery/${delivery.id}');
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  const SizedBox(height: 16),

                  // Quick Actions
                  _buildQuickActions(context, driverProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDriverInfoCard(DriverProvider driverProvider) {
    final driver = driverProvider.driver!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Text(
              driver.name[0].toUpperCase(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      driver.ratingDisplay,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${driver.totalDeliveries} deliveries',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, DriverProvider driverProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildActionCard(
              icon: Icons.local_shipping_outlined,
              title: 'Available Deliveries',
              color: Colors.blue,
              onTap: () => context.push('/available-deliveries'),
            ),
            _buildActionCard(
              icon: Icons.history,
              title: 'Delivery History',
              color: Colors.purple,
              onTap: () => context.push('/delivery-history'),
            ),
            _buildActionCard(
              icon: Icons.account_balance_wallet,
              title: 'Earnings',
              color: Colors.green,
              onTap: () => context.push('/driver-earnings'),
            ),
            _buildActionCard(
              icon: Icons.person,
              title: 'Profile',
              color: Colors.orange,
              onTap: () => context.push('/profile'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              title,
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

  Widget _buildNotDriverView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_shipping, size: 100, color: Colors.grey[300]),
            const SizedBox(height: 24),
            const Text(
              'Become a Driver',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Join our delivery team and start earning money by delivering items!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.push('/driver-application');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Apply Now'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pending, size: 100, color: Colors.orange[300]),
            const SizedBox(height: 24),
            const Text(
              'Application Pending',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your driver application is under review. We will notify you once it has been processed.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectedView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cancel, size: 100, color: Colors.red[300]),
            const SizedBox(height: 24),
            const Text(
              'Application Rejected',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Unfortunately, your driver application was not approved. Please contact support for more information.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}