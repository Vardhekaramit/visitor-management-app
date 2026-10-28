import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/visitor.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../utils/navigation.dart';
import '../utils/responsive.dart';
import '../viewmodels/visitor_viewmodel.dart';
import '../widgets/dashboard_stat_card.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/visitor_card.dart';

/// Simple and clean Dashboard Screen for the Front Desk Console.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.onViewAll,
    required this.onScanQr,
  });

  final VoidCallback onViewAll;
  final VoidCallback onScanQr;

  @override
  Widget build(BuildContext context) {
    final VisitorViewModel vm = context.watch<VisitorViewModel>();
    final double hPadding = Responsive.horizontalPadding(context);
    final List<Visitor> recent = vm.recentVisitors;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: hPadding,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Front Desk Console',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            Text(
              'Gatekeeper Security System',
              style: TextStyle(fontSize: 12, color: AppColors.slate),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Responsive.constrainedContainer(
          context: context,
          maxWidth: 900,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 12),
            children: <Widget>[
              // Welcome Hero Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          AppFormat.longDate.format(DateTime.now()),
                          style: const TextStyle(
                            color: AppColors.primaryLight,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'ONLINE',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${vm.greeting}, Security Officer',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Manage visitor check-ins, issue digital QR passes, and maintain real-time entry logs.',
                      style: TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Activity Stats Section Header
              Text(
                'Today\'s Activity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 10),

              // 3 Stat Cards
              IntrinsicHeight(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: DashboardStatCard(
                        icon: Icons.how_to_reg_rounded,
                        label: 'Total Visitors Today',
                        count: vm.totalVisitorsToday,
                        color: AppColors.registered,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DashboardStatCard(
                        icon: Icons.login_rounded,
                        label: 'Currently Checked In',
                        count: vm.checkedInNow,
                        color: AppColors.checkedIn,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DashboardStatCard(
                        icon: Icons.logout_rounded,
                        label: 'Checked Out Today',
                        count: vm.checkedOutToday,
                        color: AppColors.checkedOut,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Quick Actions
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _QuickActionButton(
                      title: 'Register Visitor',
                      subtitle: 'Issue digital pass',
                      icon: Icons.person_add_alt_1_rounded,
                      color: AppColors.primary,
                      onTap: () => openVisitorForm(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionButton(
                      title: 'Scan QR Pass',
                      subtitle: 'Fast gate entry',
                      icon: Icons.qr_code_scanner_rounded,
                      color: AppColors.success,
                      onTap: onScanQr,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Visitors Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Recent Visitors',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  TextButton(
                    onPressed: onViewAll,
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Recent Visitors List
              if (recent.isEmpty)
                EmptyStateWidget(
                  icon: Icons.groups_2_outlined,
                  title: 'No visitors yet',
                  subtitle: 'Registered visitors will appear here once added.',
                  actionLabel: 'Register First Visitor',
                  onAction: () => openVisitorForm(context),
                )
              else
                ...recent.map(
                  (Visitor v) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: VisitorCard(
                      visitor: v,
                      onTap: () => openVisitorDetails(context, v.id),
                      onEdit: () => openVisitorForm(context, visitor: v),
                      onDelete: () => vm.deleteVisitor(v.id),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: color.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 18,
                backgroundColor: color,
                child: Icon(icon, color: AppColors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.slate,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
