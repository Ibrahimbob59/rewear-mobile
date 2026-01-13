import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/admin_driver_service.dart';
import '../../services/api_service.dart';

class AdminDriverApplicationDetailScreen extends StatefulWidget {
  final String applicationId;
  final Map<String, dynamic>? application;

  const AdminDriverApplicationDetailScreen({
    super.key,
    required this.applicationId,
    this.application,
  });

  @override
  State<AdminDriverApplicationDetailScreen> createState() => _AdminDriverApplicationDetailScreenState();
}

class _AdminDriverApplicationDetailScreenState extends State<AdminDriverApplicationDetailScreen> {
  final AdminDriverService _adminDriverService = AdminDriverService(ApiService().dio);

  Map<String, dynamic>? _application;
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.application != null) {
      _application = widget.application;
      _isLoading = false;
    } else {
      _loadApplication();
    }
  }

  Future<void> _loadApplication() async {
    final applicationId = int.tryParse(widget.applicationId);

    if (applicationId == null) {
      if (mounted) context.pop();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final application = await _adminDriverService.getDriverApplicationDetails(applicationId);
      if (mounted) {
        setState(() {
          _application = application;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _approveApplication() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Application'),
        content: const Text('Are you sure you want to approve this driver application?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed != true || _application == null) return;

    setState(() => _isProcessing = true);

    try {
      final success = await _adminDriverService.approveDriverApplication(_application!['id']);

      if (mounted) {
        setState(() => _isProcessing = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Application approved successfully'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to approve application'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectApplication() async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => _RejectReasonDialog(),
    );

    if (reason == null || reason.isEmpty || _application == null) return;

    setState(() => _isProcessing = true);

    try {
      final success = await _adminDriverService.rejectDriverApplication(
        _application!['id'],
        reason,
      );

      if (mounted) {
        setState(() => _isProcessing = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Application rejected'),
              backgroundColor: Colors.orange,
            ),
          );
          context.pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to reject application'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Application Details'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_application == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Application Details'),
        ),
        body: const Center(child: Text('Application not found')),
      );
    }

    final status = _application!['status'] ?? 'pending';
    final user = _application!['user'] ?? {};
    final canModify = status == 'pending' || status == 'under_review';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Details'),
        actions: [
          if (canModify) ...[
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _isProcessing ? null : _approveApplication,
              tooltip: 'Approve',
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _isProcessing ? null : _rejectApplication,
              tooltip: 'Reject',
            ),
          ],
        ],
      ),
      body: _isProcessing
          ? const Stack(
              children: [
                _ApplicationDetailsContent(),
                ModalBarrier(dismissible: false),
                Center(child: CircularProgressIndicator()),
              ],
            )
          : const _ApplicationDetailsContent(),
    );
  }
}

class _ApplicationDetailsContent extends StatelessWidget {
  const _ApplicationDetailsContent();

  @override
  Widget build(BuildContext context) {
    final application = context
        .findAncestorStateOfType<_AdminDriverApplicationDetailScreenState>()?._application;

    if (application == null) return const SizedBox.shrink();

    final status = application['status'] ?? 'pending';
    final user = application['user'] ?? {};
    final statusColor = _getStatusColor(status);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(color: statusColor.withOpacity(0.3)),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(status),
                  color: statusColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Status: ${status.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Applicant Information
                _buildSectionTitle('Applicant Information'),
                const SizedBox(height: 12),
                _buildInfoCard([
                  _buildInfoRow('Name', user['name'] ?? 'N/A', Icons.person),
                  _buildInfoRow('Email', user['email'] ?? 'N/A', Icons.email),
                  _buildInfoRow('Phone', user['phone'] ?? 'N/A', Icons.phone),
                  _buildInfoRow('Address', application['address'] ?? 'N/A', Icons.location_on),
                  _buildInfoRow('City', application['city'] ?? 'N/A', Icons.location_city),
                ]),

                const SizedBox(height: 24),

                // Vehicle Information
                _buildSectionTitle('Vehicle Information'),
                const SizedBox(height: 12),
                _buildInfoCard([
                  _buildInfoRow(
                    'Vehicle Type',
                    (application['vehicle_type'] ?? 'N/A').toString().toUpperCase(),
                    Icons.directions_car,
                  ),
                  if (application['vehicle_plate'] != null)
                    _buildInfoRow('Plate Number', application['vehicle_plate'], Icons.credit_card),
                  if (application['license_number'] != null)
                    _buildInfoRow(
                      'License Number',
                      application['license_number'],
                      Icons.badge,
                    ),
                  if (application['license_expiry'] != null)
                    _buildInfoRow(
                      'License Expiry',
                      application['license_expiry'],
                      Icons.event,
                    ),
                ]),

                const SizedBox(height: 24),

                // Documents
                if (application['id_document_url'] != null ||
                    application['driving_license_url'] != null ||
                    application['vehicle_registration_url'] != null)
                  _buildSectionTitle('Documents'),
                const SizedBox(height: 12),
                _buildInfoCard([
                  if (application['id_document_url'] != null)
                    _buildDocumentLink('ID Document', application['id_document_url']),
                  if (application['driving_license_url'] != null)
                    _buildDocumentLink('Driving License', application['driving_license_url']),
                  if (application['vehicle_registration_url'] != null)
                    _buildDocumentLink(
                      'Vehicle Registration',
                      application['vehicle_registration_url'],
                    ),
                ]),

                const SizedBox(height: 24),

                // Application Details
                _buildSectionTitle('Application Details'),
                const SizedBox(height: 12),
                _buildInfoCard([
                  _buildInfoRow(
                    'Submitted',
                    application['created_at'] ?? 'N/A',
                    Icons.access_time,
                  ),
                  if (application['updated_at'] != null)
                    _buildInfoRow(
                      'Last Updated',
                      application['updated_at'],
                      Icons.update,
                    ),
                  if (application['rejection_reason'] != null)
                    _buildInfoRow(
                      'Rejection Reason',
                      application['rejection_reason'],
                      Icons.cancel,
                      color: Colors.red,
                    ),
                ]),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
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
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? AppTheme.primaryColor),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color ?? AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentLink(String label, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () {
          // TODO: Open document viewer
        },
        child: Row(
          children: [
            const Icon(Icons.description, size: 20, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.open_in_new,
              size: 18,
              color: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'under_review':
        return Colors.blue;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'under_review':
        return Icons.search;
      case 'pending':
      default:
        return Icons.pending;
    }
  }
}

class _RejectReasonDialog extends StatefulWidget {
  @override
  State<_RejectReasonDialog> createState() => _RejectReasonDialogState();
}

class _RejectReasonDialogState extends State<_RejectReasonDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reject Application'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Please provide a reason for rejection:'),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 3,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter reason...',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              Navigator.pop(context, _controller.text);
            }
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Reject'),
        ),
      ],
    );
  }
}
