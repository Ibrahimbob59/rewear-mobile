import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/custom_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 60,
              backgroundColor: AppTheme.primaryColor,
              child: Text(
                user?.name.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Name
            Text(
              user?.name ?? 'User',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            
            const SizedBox(height: 8),
            
            // Email
            Text(
              user?.email ?? '',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoRow('Phone', user?.phone ?? 'Not set'),
                    const Divider(),
                    _buildInfoRow('City', user?.city ?? 'Not set'),
                    const Divider(),
                    _buildInfoRow('User Type', user?.userType ?? 'user'),
                    const Divider(),
                    _buildInfoRow(
                      'Member Since',
                      user?.createdAt != null ? Helpers.formatDate(user!.createdAt!) : '-',
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Logout Button
            CustomButton(
              text: 'Logout',
              onPressed: () async {
                await authProvider.logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              isOutlined: true,
              icon: Icons.logout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}