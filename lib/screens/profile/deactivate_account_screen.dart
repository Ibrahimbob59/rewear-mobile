import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';

class DeactivateAccountScreen extends StatefulWidget {
  const DeactivateAccountScreen({super.key});

  @override
  State<DeactivateAccountScreen> createState() => _DeactivateAccountScreenState();
}

class _DeactivateAccountScreenState extends State<DeactivateAccountScreen> {
  bool _isLoading = false;
  bool _confirmChecked = false;

  Future<void> _deactivateAccount() async {
    if (!_confirmChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please confirm you understand the consequences'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show final confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Final Confirmation'),
        content: const Text(
          'Are you absolutely sure you want to deactivate your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Yes, Deactivate'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.deactivateAccount();

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account deactivated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Logout and go to login
      await authProvider.logout();
      if (mounted) {
        context.go('/login');
      }
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Failed to deactivate account'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deactivate Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red[700], size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Warning',
                          style: TextStyle(
                            color: Colors.red[900],
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This action is permanent and cannot be undone.',
                          style: TextStyle(
                            color: Colors.red[900],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Consequences
            const Text(
              'What happens when you deactivate your account:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            const _ConsequenceItem(
              icon: Icons.delete_forever,
              text: 'All your listings will be permanently deleted',
            ),
            const SizedBox(height: 12),
            const _ConsequenceItem(
              icon: Icons.shopping_bag_outlined,
              text: 'Active orders will be cancelled',
            ),
            const SizedBox(height: 12),
            const _ConsequenceItem(
              icon: Icons.favorite_border,
              text: 'All your favorites will be lost',
            ),
            const SizedBox(height: 12),
            const _ConsequenceItem(
              icon: Icons.person_off,
              text: 'Your account data will be permanently removed',
            ),
            const SizedBox(height: 12),
            const _ConsequenceItem(
              icon: Icons.block,
              text: 'You won\'t be able to use this email again',
            ),
            const SizedBox(height: 32),

            // Confirmation Checkbox
            CheckboxListTile(
              value: _confirmChecked,
              onChanged: (value) {
                setState(() => _confirmChecked = value ?? false);
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'I understand that this action is permanent and cannot be undone',
                style: TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 32),

            // Deactivate Button
            CustomButton(
              onPressed: _deactivateAccount,
              text: 'Deactivate Account',
              isLoading: _isLoading,
              backgroundColor: Colors.red,
            ),
            const SizedBox(height: 16),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsequenceItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ConsequenceItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.red[700], size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}