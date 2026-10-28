import 'package:flutter_test/flutter_test.dart';
import 'package:visitor_management/models/visitor.dart';
import 'package:visitor_management/services/visitor_service.dart';
import 'package:visitor_management/viewmodels/visitor_viewmodel.dart';

void main() {
  group('VisitorApiService & VisitorViewModel MVVM Test Suite', () {
    late VisitorApiService apiService;
    late VisitorViewModel viewModel;

    setUp(() async {
      apiService = VisitorApiService();
      viewModel = VisitorViewModel(apiService: apiService);
      // Wait for initial load
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });

    test('Initial API seed and dashboard statistics', () {
      expect(viewModel.visitors.isNotEmpty, isTrue);
      expect(viewModel.totalVisitorsToday, greaterThanOrEqualTo(0));
      expect(viewModel.checkedInNow, greaterThanOrEqualTo(0));
      expect(viewModel.checkedOutToday, greaterThanOrEqualTo(0));
      expect(viewModel.greeting.isNotEmpty, isTrue);
    });

    test('Register, Edit, Status Workflow, and Delete via ViewModel', () async {
      // 1. Register new visitor
      final Visitor? created = await viewModel.registerVisitor(
        name: 'Interview Candidate',
        mobile: '9876543210',
        email: 'candidate@example.com',
        type: 'Customer',
        project: 'Project A',
        purpose: 'Technical Interview',
      );

      expect(created, isNotNull);
      expect(created!.status, VisitorStatus.registered);
      expect(viewModel.getVisitorById(created.id), isNotNull);

      // 2. Edit visitor
      final bool updated = await viewModel.updateVisitor(
        id: created.id,
        name: 'Updated Candidate',
        mobile: '9876543210',
        email: 'candidate@example.com',
        type: 'Customer',
        project: 'Project B',
        purpose: 'Technical Interview & Onboarding',
      );
      expect(updated, isTrue);
      expect(
        viewModel.getVisitorById(created.id)?.name,
        'Updated Candidate',
      );

      // 3. Check-In
      final bool checkedIn = await viewModel.checkIn(created.id);
      expect(checkedIn, isTrue);
      expect(
        viewModel.getVisitorById(created.id)?.status,
        VisitorStatus.checkedIn,
      );

      // 4. Duplicate Check-In rejected
      final bool duplicateCheckIn = await viewModel.checkIn(created.id);
      expect(duplicateCheckIn, isFalse);

      // 5. Check-Out
      final bool checkedOut = await viewModel.checkOut(created.id);
      expect(checkedOut, isTrue);
      expect(
        viewModel.getVisitorById(created.id)?.status,
        VisitorStatus.checkedOut,
      );

      // 6. Cannot check in again after completed visit
      final bool reCheckIn = await viewModel.checkIn(created.id);
      expect(reCheckIn, isFalse);

      // 7. Delete visitor
      final bool deleted = await viewModel.deleteVisitor(created.id);
      expect(deleted, isTrue);
      expect(viewModel.getVisitorById(created.id), isNull);
    });

    test('Search and Status filter in VisitorViewModel', () {
      expect(viewModel.filteredVisitors.length, viewModel.visitors.length);

      viewModel.setSearchQuery('Neha');
      expect(viewModel.filteredVisitors.isNotEmpty, isTrue);
      expect(
        viewModel.filteredVisitors.every(
          (Visitor v) => v.name.toLowerCase().contains('neha'),
        ),
        isTrue,
      );

      viewModel.clearFilters();
      expect(viewModel.searchQuery.isEmpty, isTrue);
      expect(viewModel.statusFilter, isNull);

      viewModel.setStatusFilter(VisitorStatus.checkedIn);
      expect(viewModel.filteredVisitors.isNotEmpty, isTrue);
      expect(
        viewModel.filteredVisitors
            .every((Visitor v) => v.status == VisitorStatus.checkedIn),
        isTrue,
      );
    });
  });
}
