import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/visitor.dart';
import '../theme/app_colors.dart';
import '../utils/navigation.dart';
import '../utils/responsive.dart';
import '../viewmodels/visitor_viewmodel.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/visitor_card.dart';

/// Clean, simple Visitor Directory with search, status filters, and pull-to-refresh.
class VisitorListScreen extends StatefulWidget {
  const VisitorListScreen({super.key});

  @override
  State<VisitorListScreen> createState() => _VisitorListScreenState();
}

class _VisitorListScreenState extends State<VisitorListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final String current = context.read<VisitorViewModel>().searchQuery;
    if (current.isNotEmpty) {
      _searchController.text = current;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: color.withValues(alpha: 0.15),
        checkmarkColor: color,
        labelStyle: TextStyle(
          color: isSelected ? color : AppColors.textSecondary(context),
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 12.5,
        ),
        side: BorderSide(
          color: isSelected ? color : AppColors.border(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final VisitorViewModel vm = context.watch<VisitorViewModel>();
    final List<Visitor> filtered = vm.filteredVisitors;
    final double hPadding = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: hPadding,
        title: const Text('Visitor Directory'),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: hPadding),
            child: Center(
              child: Text(
                '${vm.visitors.length} total',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openVisitorForm(context),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('New Visitor'),
      ),
      body: SafeArea(
        child: Responsive.constrainedContainer(
          context: context,
          maxWidth: 900,
          child: Column(
            children: <Widget>[
              // Search Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: vm.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search by name or phone...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              vm.setSearchQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.surface(context),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border(context)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border(context)),
                    ),
                  ),
                ),
              ),

              // Filter Chips Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 4),
                child: Row(
                  children: <Widget>[
                    _buildFilterChip(
                      label: 'All (${vm.visitors.length})',
                      isSelected: vm.statusFilter == null,
                      color: AppColors.primary,
                      onTap: () => vm.setStatusFilter(null),
                    ),
                    _buildFilterChip(
                      label: 'Registered (${vm.countForStatus(VisitorStatus.registered)})',
                      isSelected: vm.statusFilter == VisitorStatus.registered,
                      color: AppColors.registered,
                      onTap: () => vm.setStatusFilter(VisitorStatus.registered),
                    ),
                    _buildFilterChip(
                      label: 'Checked In (${vm.countForStatus(VisitorStatus.checkedIn)})',
                      isSelected: vm.statusFilter == VisitorStatus.checkedIn,
                      color: AppColors.checkedIn,
                      onTap: () => vm.setStatusFilter(VisitorStatus.checkedIn),
                    ),
                    _buildFilterChip(
                      label: 'Checked Out (${vm.countForStatus(VisitorStatus.checkedOut)})',
                      isSelected: vm.statusFilter == VisitorStatus.checkedOut,
                      color: AppColors.checkedOut,
                      onTap: () => vm.setStatusFilter(VisitorStatus.checkedOut),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // Visitor List with Pull to Refresh
              Expanded(
                child: RefreshIndicator(
                  onRefresh: vm.loadVisitors,
                  child: filtered.isEmpty
                      ? ListView(
                          children: <Widget>[
                            EmptyStateWidget(
                              icon: Icons.search_off_rounded,
                              title: 'No visitors found',
                              subtitle: vm.searchQuery.isNotEmpty
                                  ? 'No matching results for "${vm.searchQuery}".'
                                  : 'No visitors in this status category.',
                              actionLabel: 'Clear Filters',
                              actionIcon: Icons.refresh,
                              onAction: () {
                                _searchController.clear();
                                vm.clearFilters();
                              },
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: hPadding,
                            vertical: 8,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (BuildContext context, int index) {
                            final Visitor visitor = filtered[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Dismissible(
                                key: Key(visitor.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  decoration: BoxDecoration(
                                    color: AppColors.error,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(Icons.delete, color: AppColors.white),
                                ),
                                confirmDismiss: (_) =>
                                    showDeleteVisitorDialog(context, visitor),
                                onDismissed: (_) {
                                  vm.deleteVisitor(visitor.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${visitor.name} deleted')),
                                  );
                                },
                                child: VisitorCard(
                                  visitor: visitor,
                                  onTap: () =>
                                      openVisitorDetails(context, visitor.id),
                                  onEdit: () => openVisitorForm(
                                    context,
                                    visitor: visitor,
                                  ),
                                  onDelete: () => vm.deleteVisitor(visitor.id),
                                ),
                              ),
                            );
                          },
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
