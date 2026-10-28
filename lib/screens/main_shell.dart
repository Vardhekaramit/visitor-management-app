import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import 'dashboard_screen.dart';
import 'qr_scanner_screen.dart';
import 'visitor_list_screen.dart';

/// Adaptive Navigation Shell:
/// - Bottom [NavigationBar] on Mobile (<640dp)
/// - Lateral [NavigationRail] on Tablet (>=640dp)
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _select(int index) {
    if (index == _index) return;
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = Responsive.isTabletOrLarger(context);

    final Widget bodyContent = IndexedStack(
      index: _index,
      children: <Widget>[
        DashboardScreen(
          onViewAll: () => _select(1),
          onScanQr: () => _select(2),
        ),
        const VisitorListScreen(),
        QrScannerScreen(isActive: _index == 2),
      ],
    );

    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) _select(0);
      },
      child: Scaffold(
        body: isTablet
            ? Row(
                children: <Widget>[
                  NavigationRail(
                    selectedIndex: _index,
                    onDestinationSelected: _select,
                    labelType: NavigationRailLabelType.all,
                    backgroundColor: AppColors.surface(context),
                    indicatorColor: AppColors.primary.withValues(alpha: 0.15),
                    leading: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.security, color: AppColors.white, size: 20),
                      ),
                    ),
                    destinations: const <NavigationRailDestination>[
                      NavigationRailDestination(
                        icon: Icon(Icons.dashboard_outlined),
                        selectedIcon: Icon(Icons.dashboard, color: AppColors.primary),
                        label: Text('Console'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.people_outline),
                        selectedIcon: Icon(Icons.people, color: AppColors.primary),
                        label: Text('Visitors'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.qr_code_scanner_outlined),
                        selectedIcon: Icon(Icons.qr_code_scanner, color: AppColors.primary),
                        label: Text('Scan Pass'),
                      ),
                    ],
                  ),
                  const VerticalDivider(width: 1, thickness: 1),
                  Expanded(child: bodyContent),
                ],
              )
            : bodyContent,
        bottomNavigationBar: isTablet
            ? null
            : NavigationBar(
                selectedIndex: _index,
                onDestinationSelected: _select,
                destinations: const <NavigationDestination>[
                  NavigationDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard, color: AppColors.primary),
                    label: 'Console',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.people_outline),
                    selectedIcon: Icon(Icons.people, color: AppColors.primary),
                    label: 'Visitors',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.qr_code_scanner_outlined),
                    selectedIcon: Icon(Icons.qr_code_scanner, color: AppColors.primary),
                    label: 'Scan Pass',
                  ),
                ],
              ),
      ),
    );
  }
}
