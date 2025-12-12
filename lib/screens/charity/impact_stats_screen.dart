import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/charity_provider.dart';

class ImpactStatsScreen extends StatefulWidget {
  const ImpactStatsScreen({super.key});

  @override
  State<ImpactStatsScreen> createState() => _ImpactStatsScreenState();
}

class _ImpactStatsScreenState extends State<ImpactStatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CharityProvider>().loadImpactStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Impact Statistics'),
      ),
      body: Consumer<CharityProvider>(
        builder: (context, charityProvider, child) {
          if (charityProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final impactStats = charityProvider.impactStats;
          if (impactStats == null) {
            return const Center(child: Text('No impact data available'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview Cards
                const Text(
                  'Total Impact',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildImpactCard(
                  icon: Icons.inventory_2,
                  title: 'Total Donations',
                  value: '${impactStats['total_items'] ?? 0}',
                  subtitle: 'Items received',
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
                
                _buildImpactCard(
                  icon: Icons.people,
                  title: 'People Helped',
                  value: '${impactStats['people_helped'] ?? 0}',
                  subtitle: 'Lives impacted',
                  color: Colors.orange,
                ),
                const SizedBox(height: 12),
                
                _buildImpactCard(
                  icon: Icons.eco,
                  title: 'Environmental Impact',
                  value: '${impactStats['co2_saved'] ?? 0} kg',
                  subtitle: 'CO2 emissions saved',
                  color: Colors.green,
                ),
                const SizedBox(height: 12),
                
                _buildImpactCard(
                  icon: Icons.attach_money,
                  title: 'Estimated Value',
                  value: '\$${(impactStats['estimated_value'] ?? 0).toStringAsFixed(2)}',
                  subtitle: 'Market value of donations',
                  color: Colors.purple,
                ),

                const SizedBox(height: 24),

                // Category Breakdown
                const Text(
                  'Donations by Category',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                if (impactStats['by_category'] != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: (impactStats['by_category'] as List).map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(item['category'] ?? 'Unknown'),
                              ),
                              Expanded(
                                flex: 2,
                                child: LinearProgressIndicator(
                                  value: (item['count'] ?? 0) / 
                                      (impactStats['total_items'] ?? 1),
                                  backgroundColor: Colors.grey[200],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${item['count']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                const SizedBox(height: 24),

                // Monthly Trend
                const Text(
                  'Monthly Donations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                if (impactStats['monthly_trend'] != null)
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _buildChartSpots(impactStats['monthly_trend']),
                            isCurved: true,
                            color: Theme.of(context).primaryColor,
                            barWidth: 3,
                            dotData: FlDotData(show: true),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // Share Impact Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement share functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Share feature coming soon!')),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share Impact Report'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImpactCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
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
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _buildChartSpots(List<dynamic> data) {
    return List.generate(
      data.length,
      (index) => FlSpot(
        index.toDouble(),
        (data[index]['count'] ?? 0).toDouble(),
      ),
    );
  }
}