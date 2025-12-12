import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/charity_provider.dart';

class CharityDashboardScreen extends StatefulWidget {
  const CharityDashboardScreen({super.key});

  @override
  State<CharityDashboardScreen> createState() => _CharityDashboardScreenState();
}

class _CharityDashboardScreenState extends State<CharityDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CharityProvider>();
      provider.loadCharityProfile();
      provider.loadImpactStats();
      provider.loadPendingDonations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Charity Dashboard'),
      ),
      body: Consumer<CharityProvider>(
        builder: (context, charityProvider, child) {
          if (charityProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!charityProvider.isCharity) {
            return _buildNotCharityView(context);
          }

          final charity = charityProvider.charity!;
          final impactStats = charityProvider.impactStats;

          return RefreshIndicator(
            onRefresh: () async {
              await charityProvider.loadCharityProfile();
              await charityProvider.loadImpactStats();
              await charityProvider.loadPendingDonations();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Charity Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green[600]!, Colors.green[400]!],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.green,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                charity.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  if (charity.isVerified)
                                    const Icon(
                                      Icons.verified,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Verified Charity',
                                    style: TextStyle(
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
                  ),

                  const SizedBox(height: 16),

                  // Impact Stats
                  if (impactStats != null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.inventory_2,
                            title: 'Items Received',
                            value: '${impactStats['total_items'] ?? 0}',
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.people,
                            title: 'People Helped',
                            value: '${impactStats['people_helped'] ?? 0}',
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.eco,
                            title: 'CO2 Saved',
                            value: '${impactStats['co2_saved'] ?? 0} kg',
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.pending,
                            title: 'Pending',
                            value: '${charityProvider.pendingCount}',
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Quick Actions
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    icon: Icons.pending_actions,
                    title: 'Pending Donations',
                    subtitle: '${charityProvider.pendingCount} items waiting',
                    color: Colors.orange,
                    onTap: () => context.push('/pending-donations'),
                  ),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    icon: Icons.check_circle,
                    title: 'Accepted Donations',
                    subtitle: '${charityProvider.acceptedCount} items accepted',
                    color: Colors.green,
                    onTap: () => context.push('/accepted-donations'),
                  ),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    icon: Icons.analytics,
                    title: 'Impact Statistics',
                    subtitle: 'View your impact report',
                    color: Colors.blue,
                    onTap: () => context.push('/impact-stats'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
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
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildNotCharityView(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 100, color: Colors.grey),
            SizedBox(height: 24),
            Text(
              'Charity Access Only',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'This section is only available for registered charity organizations.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}