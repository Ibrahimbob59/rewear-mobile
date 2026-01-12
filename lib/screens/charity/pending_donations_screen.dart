import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/charity_provider.dart';

class PendingDonationsScreen extends StatefulWidget {
  const PendingDonationsScreen({super.key});

  @override
  State<PendingDonationsScreen> createState() => _PendingDonationsScreenState();
}

class _PendingDonationsScreenState extends State<PendingDonationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CharityProvider>().loadAvailableDonations();
    });
  }

  Future<void> _handleAcceptDonation(Map<String, dynamic> donation) async {
    final provider = context.read<CharityProvider>();
    
    // Show dialog to get distribution plan and beneficiaries count
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _AcceptDonationDialog(),
    );
    
    if (result != null) {
      final success = await provider.acceptDonation(
        donation['id'],
        result['distributionPlan'],
        result['beneficiariesCount'],
      );
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Donation claimed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        provider.loadAvailableDonations();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to claim donation'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Donations'),
      ),
      body: Consumer<CharityProvider>(
        builder: (context, charityProvider, child) {
          if (charityProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (charityProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(charityProvider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      charityProvider.loadAvailableDonations();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final donations = charityProvider.availableDonations;

          if (donations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.card_giftcard_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No donations available',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Available donations will appear here',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await charityProvider.loadAvailableDonations();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: donations.length,
              itemBuilder: (context, index) {
                final donation = donations[index];
                return _buildDonationCard(donation);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDonationCard(Map<String, dynamic> donation) {
    // Extract data with null safety
    final title = donation['title'] ?? 'Unknown Item';
    final description = donation['description'] ?? '';
    final condition = donation['condition'] ?? 'unknown';
    final size = donation['size'] ?? '';
    final category = donation['category'] ?? '';
    final images = donation['images'] as List?;
    final createdAt = donation['created_at'] ?? '';
    
    // Get seller info (donor)
    final seller = donation['seller'] as Map<String, dynamic>?;
    final donorName = seller?['name'] ?? 'Anonymous';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          if (images != null && images.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                images.first,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, size: 60, color: Colors.grey),
                ),
              ),
            )
          else
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Center(
                child: Icon(Icons.card_giftcard, size: 60, color: Colors.grey),
              ),
            ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Description
                if (description.isNotEmpty) ...[
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                ],

                // Details Row
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (category.isNotEmpty)
                      _buildInfoChip(Icons.category, category),
                    if (size.isNotEmpty)
                      _buildInfoChip(Icons.straighten, size),
                    _buildInfoChip(
                      Icons.check_circle_outline,
                      _formatCondition(condition),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Donor Info
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Donated by: $donorName',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _handleAcceptDonation(donation),
                        icon: const Icon(Icons.volunteer_activism),
                        label: const Text('Claim Donation'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
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

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCondition(String condition) {
    switch (condition.toLowerCase()) {
      case 'new':
        return 'New';
      case 'like_new':
        return 'Like New';
      case 'good':
        return 'Good';
      case 'fair':
        return 'Fair';
      default:
        return condition;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateStr;
    }
  }
}

// Dialog for accepting donation
class _AcceptDonationDialog extends StatefulWidget {
  @override
  State<_AcceptDonationDialog> createState() => _AcceptDonationDialogState();
}

class _AcceptDonationDialogState extends State<_AcceptDonationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _distributionPlanController = TextEditingController();
  final _beneficiariesController = TextEditingController();

  @override
  void dispose() {
    _distributionPlanController.dispose();
    _beneficiariesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Claim Donation'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _distributionPlanController,
              decoration: const InputDecoration(
                labelText: 'Distribution Plan',
                hintText: 'How will you distribute this donation?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a distribution plan';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _beneficiariesController,
              decoration: const InputDecoration(
                labelText: 'Number of Beneficiaries',
                hintText: 'How many people will benefit?',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter number of beneficiaries';
                }
                final number = int.tryParse(value);
                if (number == null || number <= 0) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'distributionPlan': _distributionPlanController.text.trim(),
                'beneficiariesCount': int.parse(_beneficiariesController.text),
              });
            }
          },
          child: const Text('Claim'),
        ),
      ],
    );
  }
}