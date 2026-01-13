import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/orders_provider.dart';
import '../../providers/items_provider.dart';
import '../../providers/driver_provider.dart';
import '../../config/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _driverEligibility;
  Map<String, dynamic>? _driverApplication;

  @override
  void initState() {
    super.initState();
    // Defer data loading until after build phase to avoid setState during build error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isLoggedIn) {
      await authProvider.initialize();

      if (!mounted) return;

      final ordersProvider = context.read<OrdersProvider>();
      ordersProvider.loadAllOrders();

      final itemsProvider = context.read<ItemsProvider>();
      itemsProvider.loadMyListings();

      // Load driver application data
      final driverProvider = context.read<DriverProvider>();
      await driverProvider.loadMyApplication();
      if (mounted) {
        setState(() {
          _driverApplication = driverProvider.applicationData;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final isLoggedIn = authProvider.isLoggedIn;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(context, user, isLoggedIn),
                const SizedBox(height: 24),
                if (isLoggedIn) ...[
                  _buildStatisticsGrid(context),
                  const SizedBox(height: 24),
                  // ✅ NEW: Role-based dashboard buttons
                  if (user != null) _buildRoleDashboards(context, user),
                  _buildSettingsMenu(context),
                  const SizedBox(height: 24),
                  _buildLogoutButton(context, authProvider),
                ] else ...[
                  _buildLoginPrompt(context),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic user, bool isLoggedIn) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.primaryColor, AppTheme.primaryDark],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (isLoggedIn)
                  IconButton(
                    onPressed: () => context.push('/profile/edit'),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(51),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(51),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: isLoggedIn && user != null
                  ? CircleAvatar(
                      radius: 46,
                      backgroundColor: AppTheme.secondaryColor,
                      child: Text(
                        _getInitials(user.name ?? 'U'),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : const CircleAvatar(
                      radius: 46,
                      backgroundColor: Color(0xFFE0E0E0),
                      child: Icon(
                        Icons.person,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              isLoggedIn && user != null ? user.name ?? 'User' : 'Guest',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            if (isLoggedIn && user != null)
              Text(
                user.email ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withAlpha(217),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final words = name.trim().split(' ');
    if (words.isEmpty) return 'U';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  Widget _buildStatisticsGrid(BuildContext context) {
    final ordersProvider = context.watch<OrdersProvider>();
    final itemsProvider = context.watch<ItemsProvider>();

    // ✅ FIX: Changed from allOrders to buyerOrders
    final totalOrders = ordersProvider.buyerOrders.length;
    final totalListings = itemsProvider.myListings.length;
    final activeListings = itemsProvider.myListings
        .where((item) => item.status == 'available')
        .length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(
              icon: Icons.shopping_cart_outlined,
              value: totalOrders.toString(),
              label: 'Orders',
              color: const Color(0xFF2196F3),
            ),
            _buildDivider(),
            _buildStatItem(
              icon: Icons.inventory_2_outlined,
              value: activeListings.toString(),
              label: 'Active',
              color: const Color(0xFF4CAF50),
            ),
            _buildDivider(),
            _buildStatItem(
              icon: Icons.sell_outlined,
              value: totalListings.toString(),
              label: 'Listings',
              color: const Color(0xFFFF9800),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 50,
      width: 1,
      color: const Color(0xFFE0E0E0),
    );
  }

  // ✅ NEW: Role-based dashboard buttons
  Widget _buildRoleDashboards(BuildContext context, dynamic user) {
    final bool isVerifiedDriver = user.isDriver == true && user.driverVerified == true;
    // Backend sends isCharity as boolean field
    final bool isCharity = user.isCharity == true;
    // Check if user is admin
    final bool isAdmin = user.isAdmin == true;

    print('🔍 _buildRoleDashboards: isVerifiedDriver=$isVerifiedDriver, isCharity=$isCharity, isAdmin=$isAdmin');
    print('   user.isDriver=${user.isDriver}, user.isCharity=${user.isCharity}, user.isAdmin=${user.isAdmin}');

    // Don't show anything if user is neither driver nor charity nor admin
    if (!isVerifiedDriver && !isCharity && !isAdmin) {
      print('   ❌ No dashboard access - hiding buttons');
      return const SizedBox.shrink();
    }

    print('   ✅ Showing dashboard buttons');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Admin Dashboard Button
            if (isAdmin) ...[
              _buildMenuItem(
                icon: Icons.admin_panel_settings,
                title: 'Admin Dashboard',
                subtitle: 'Manage driver applications',
                onTap: () => context.push('/admin/driver-applications'),
                color: const Color(0xFF9C27B0),
              ),
              if (isVerifiedDriver || isCharity) _buildMenuDivider(),
            ],
            // Driver Dashboard Button
            if (isVerifiedDriver) ...[
              _buildMenuItem(
                icon: Icons.local_shipping,
                title: 'Driver Dashboard',
                subtitle: 'Manage deliveries and earnings',
                onTap: () => context.push('/driver/dashboard'),
                color: const Color(0xFF2196F3),
              ),
              if (isCharity) _buildMenuDivider(),
            ],

            // Charity Dashboard Button
            if (isCharity) ...[
              _buildMenuItem(
                icon: Icons.volunteer_activism,
                title: 'Charity Dashboard',
                subtitle: 'Manage donations and impact',
                onTap: () => context.push('/charity/home'),
                color: const Color(0xFF4CAF50),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsMenu(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    // Check if user is a regular user (not verified driver, not charity, not admin)
    final bool isRegularUser = user != null &&
        !user.isVerifiedDriver &&
        !user.isCharity &&
        !user.isAdmin;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Apply as Driver - only for regular users
            if (isRegularUser) ...[
              _buildDriverApplicationMenuItem(context, user),
              _buildMenuDivider(),
            ],
            _buildMenuItem(
              icon: Icons.shopping_bag_outlined,
              title: 'My Listings',
              subtitle: 'Manage your items for sale',
              onTap: () => context.push('/selling'),
            ),
            _buildMenuDivider(),
            _buildMenuItem(
              icon: Icons.favorite_outline,
              title: 'Favorites',
              subtitle: 'Items you saved',
              onTap: () => context.push('/favorites'),
            ),
            _buildMenuDivider(),
            _buildMenuItem(
              icon: Icons.location_on_outlined,
              title: 'Addresses',
              subtitle: 'Manage delivery addresses',
              onTap: () => context.push('/addresses'),
            ),
            _buildMenuDivider(),
            _buildMenuItem(
              icon: Icons.shield_outlined,
              title: 'Privacy & Security',
              subtitle: 'Password and account settings',
              onTap: () => context.push('/profile/change-password'),
            ),
            _buildMenuDivider(),
            _buildMenuItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'Get help with the app',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Help & Support coming soon')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (color ?? AppTheme.primaryColor).withAlpha(26),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color ?? AppTheme.primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.grey[200],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton(
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Logout'),
                content: const Text('Are you sure you want to logout?'),
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
                    child: const Text('Logout'),
                  ),
                ],
              ),
            );

            if (confirmed == true) {
              await authProvider.logout();
              if (context.mounted) {
                context.go('/login');
              }
            }
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.red.shade300),
            foregroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Logout',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.person_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Not Logged In',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please login to access your profile and orders',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => context.push('/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Login',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.push('/register'),
            child: const Text(
              'Don\'t have an account? Register',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverApplicationMenuItem(BuildContext context, dynamic user) {
    // Check if user has a pending application
    final hasPendingApplication = _driverApplication != null;
    final applicationStatus = _driverApplication?['status'];

    String title = 'Apply as Driver';
    String subtitle = 'Become a delivery driver and earn';
    IconData icon = Icons.local_shipping_outlined;
    Color color = const Color(0xFF2196F3);

    if (hasPendingApplication) {
      title = 'Driver Application';
      icon = Icons.pending_outlined;
      color = const Color(0xFFFF9800);

      if (applicationStatus == 'pending') {
        subtitle = 'Application under review';
      } else if (applicationStatus == 'approved') {
        subtitle = 'Application approved!';
        icon = Icons.check_circle_outline;
        color = const Color(0xFF4CAF50);
      } else if (applicationStatus == 'rejected') {
        subtitle = 'Application was rejected';
        icon = Icons.cancel_outlined;
        color = const Color(0xFFF44336);
      }
    }

    return _buildMenuItem(
      icon: icon,
      title: title,
      subtitle: subtitle,
      onTap: () async {
        if (hasPendingApplication) {
          // Show application status
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Application status: $applicationStatus'),
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          // Check eligibility before navigating
          final driverProvider = context.read<DriverProvider>();
          final eligibility = await driverProvider.checkEligibility();

          if (eligibility != null && eligibility['can_apply'] == true) {
            if (context.mounted) {
              context.push('/driver-application');
            }
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(eligibility?['reason'] ?? 'You cannot apply at this time'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      },
      color: color,
    );
  }
}