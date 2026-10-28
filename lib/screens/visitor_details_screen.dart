import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/visitor.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../utils/navigation.dart';
import '../utils/responsive.dart';
import '../viewmodels/visitor_viewmodel.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/status_badge_chip.dart';
import '../widgets/visitor_card.dart';

/// Clean and understandable Visitor Details & Pass Screen.
class VisitorDetailsScreen extends StatelessWidget {
  const VisitorDetailsScreen({super.key, required this.visitorId});

  final String visitorId;

  @override
  Widget build(BuildContext context) {
    final VisitorViewModel vm = context.watch<VisitorViewModel>();
    final Visitor? visitor = vm.getVisitorById(visitorId);
    final bool isTablet = Responsive.isTabletOrLarger(context);
    final double hPadding = Responsive.horizontalPadding(context);

    if (visitor == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Visitor Pass')),
        body: Center(
          child: EmptyStateWidget(
            icon: Icons.person_off_outlined,
            title: 'Visitor not found',
            subtitle: 'This record may have been removed.',
            actionLabel: 'Go Back',
            actionIcon: Icons.arrow_back,
            onAction: () => Navigator.of(context).pop(),
          ),
        ),
      );
    }

    final Widget passCard = _buildPassCard(context, visitor);
    final Widget detailsColumn = _buildDetailsColumn(context, vm, visitor);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitor Details'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Edit Details',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => openVisitorForm(context, visitor: visitor),
          ),
          IconButton(
            tooltip: 'Delete Visitor',
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () async {
              final bool confirmed =
                  await showDeleteVisitorDialog(context, visitor);
              if (confirmed && context.mounted) {
                await vm.deleteVisitor(visitor.id);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Responsive.constrainedContainer(
          context: context,
          maxWidth: 900,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 16),
            child: isTablet
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(flex: 5, child: passCard),
                      const SizedBox(width: 24),
                      Expanded(flex: 6, child: detailsColumn),
                    ],
                  )
                : Column(
                    children: <Widget>[
                      passCard,
                      const SizedBox(height: 18),
                      detailsColumn,
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  /// Digital QR Pass Card
  Widget _buildPassCard(BuildContext context, Visitor visitor) {
    final String qrData = 'VMS:${visitor.id}:${visitor.mobile}';

    return Card(
      elevation: 0,
      color: AppColors.card(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.border(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            // Pass Header with Pass ID and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'DIGITAL PASS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: AppColors.slate,
                      ),
                    ),
                    Text(
                      visitor.id,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                StatusBadgeChip(status: visitor.status),
              ],
            ),
            const SizedBox(height: 16),

            // QR Code Container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 180,
                backgroundColor: AppColors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Visitor Name & Type
            Text(
              visitor.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${visitor.type} • ${visitor.project}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.slate,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Visitor Details and Action Column
  Widget _buildDetailsColumn(
    BuildContext context,
    VisitorViewModel vm,
    Visitor visitor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Status Action Button
        _buildActionButton(context, vm, visitor),
        const SizedBox(height: 18),

        // Timeline Step Pipeline
        Card(
          elevation: 0,
          color: AppColors.card(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.border(context)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Visit Progress',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 12),
                _buildTimelineTile(
                  context,
                  title: 'Pre-Registered',
                  time: AppFormat.dateTime.format(visitor.createdAt),
                  isCompleted: true,
                  color: AppColors.registered,
                ),
                _buildTimelineTile(
                  context,
                  title: 'Checked In',
                  time: visitor.checkInTime != null
                      ? AppFormat.dateTime.format(visitor.checkInTime!)
                      : 'Pending arrival',
                  isCompleted: visitor.checkInTime != null,
                  color: AppColors.checkedIn,
                ),
                _buildTimelineTile(
                  context,
                  title: 'Checked Out',
                  time: visitor.checkOutTime != null
                      ? AppFormat.dateTime.format(visitor.checkOutTime!)
                      : 'Not checked out yet',
                  isCompleted: visitor.checkOutTime != null,
                  color: AppColors.checkedOut,
                  isLast: true,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Contact & Visit Information
        Card(
          elevation: 0,
          color: AppColors.card(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.border(context)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                _buildInfoRow(
                  context,
                  icon: Icons.phone_outlined,
                  label: 'Mobile',
                  value: visitor.mobile,
                ),
                const Divider(height: 16),
                _buildInfoRow(
                  context,
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: visitor.email,
                ),
                const Divider(height: 16),
                _buildInfoRow(
                  context,
                  icon: Icons.apartment_outlined,
                  label: 'Location',
                  value: visitor.project,
                ),
                const Divider(height: 16),
                _buildInfoRow(
                  context,
                  icon: Icons.info_outline,
                  label: 'Purpose',
                  value: visitor.purpose,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    VisitorViewModel vm,
    Visitor visitor,
  ) {
    if (visitor.status == VisitorStatus.registered) {
      return FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.checkedIn,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: () async {
          final bool success = await vm.checkIn(visitor.id);
          if (context.mounted && success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${visitor.name} has checked in.')),
            );
          }
        },
        icon: const Icon(Icons.login),
        label: const Text('Check In Visitor', style: TextStyle(fontSize: 16)),
      );
    } else if (visitor.status == VisitorStatus.checkedIn) {
      return FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.warning,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: () async {
          final bool success = await vm.checkOut(visitor.id);
          if (context.mounted && success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${visitor.name} has checked out.')),
            );
          }
        },
        icon: const Icon(Icons.logout),
        label: const Text('Check Out Visitor', style: TextStyle(fontSize: 16)),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.slate.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.check_circle, color: AppColors.checkedIn, size: 20),
          SizedBox(width: 8),
          Text(
            'Visit Completed',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.checkedIn,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineTile(
    BuildContext context, {
    required String title,
    required String time,
    required bool isCompleted,
    required Color color,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          children: <Widget>[
            CircleAvatar(
              radius: 9,
              backgroundColor: isCompleted ? color : AppColors.border(context),
              child: isCompleted
                  ? const Icon(Icons.check, size: 11, color: AppColors.white)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 28,
                color: isCompleted ? color : AppColors.border(context),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context),
                ),
              ),
              Text(
                time,
                style: const TextStyle(fontSize: 11.5, color: AppColors.slate),
              ),
              if (!isLast) const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: AppColors.slate),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.slate),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(context),
          ),
        ),
      ],
    );
  }
}
