import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../providers/charity_provider.dart';
import '../../widgets/items/empty_state.dart';

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
      context.read<CharityProvider>().loadPendingDonations();
    });
  }

  Future<void> _onRefresh() async {
    await context.read<CharityProvider>().loadPendingDonations();
  }

  Future<void> _acceptDonation(int donationId) async {
    final success = await context.read<CharityProvider>().acceptDonation(donationId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Donation accepted!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final error = context.read<CharityProvider>().error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to accept donation'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectDonation(int donationId) async {
    final reason = await _showRejectDialog();
    if (reason == null) return;

    final success = await context.read<CharityProvider>().rejectDonation(
      donationId,
      reason: reason.isEmpty ? null : reason,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Donation rejected'),
        ),
      );
    } else {
      final error = context.read<CharityProvider>().error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to reject donation'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String?> _showRejectDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Donation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to reject this donation?'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Reason (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text(
              'Reject',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Pending Donations'),
      ),
      body: Consumer<CharityProvider>(
        builder: (context, charityProvider, child) {
          if (charityProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (charityProvider.pendingDonations.isEmpty) {
            return EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'No pending donations',
              message: 'New donation requests will appear here',
              actionLabel: 'Refresh',
              onAction: _onRefresh,
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: charityProvider.pendingDonations.length,
              itemBuilder: (context, index) {
                final donation = charityProvider.pendingDonations[index];
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
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
                      // Item Info
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: donation.itemImage ?? '',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    donation.itemTitle,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'From ${donation.donorName}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('MMM dd, yyyy').format(donation.donatedAt),
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
                      ),

                      // Actions
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _rejectDonation(donation.id),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                ),
                                child: const Text('Reject'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _acceptDonation(donation.id),
                                child: const Text('Accept'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}