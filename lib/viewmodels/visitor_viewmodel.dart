import 'package:flutter/material.dart';

import '../models/visitor.dart';
import '../services/visitor_service.dart';

/// Central ViewModel for the Visitor Management Application.
/// Implements MVVM with [ChangeNotifier] and handles all business logic,
/// REST API communication, search, filtering, and live state updates.
class VisitorViewModel extends ChangeNotifier {
  VisitorViewModel({VisitorApiService? apiService})
      : _apiService = apiService ?? VisitorApiService() {
    loadVisitors();
  }

  final VisitorApiService _apiService;

  List<Visitor> _visitors = <Visitor>[];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  String _searchQuery = '';
  VisitorStatus? _statusFilter;

  // Getters
  List<Visitor> get visitors => List<Visitor>.unmodifiable(_visitors);
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  VisitorStatus? get statusFilter => _statusFilter;

  // Dashboard Statistics
  int get totalVisitorsToday {
    final DateTime now = DateTime.now();
    return _visitors.where((Visitor v) => _isSameDay(v.createdAt, now)).length;
  }

  int get checkedInNow => _visitors
      .where((Visitor v) => v.status == VisitorStatus.checkedIn)
      .length;

  int get checkedOutToday {
    final DateTime now = DateTime.now();
    return _visitors.where((Visitor v) {
      final DateTime? out = v.checkOutTime;
      return out != null && _isSameDay(out, now);
    }).length;
  }

  int countForStatus(VisitorStatus status) {
    return _visitors.where((Visitor v) => v.status == status).length;
  }

  List<Visitor> get recentVisitors => _visitors.take(4).toList();

  String get greeting {
    final int hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  // Filtered list based on Search & Status Filter
  List<Visitor> get filteredVisitors {
    final String query = _searchQuery.trim().toLowerCase();
    return _visitors.where((Visitor v) {
      final bool statusMatches =
          _statusFilter == null || v.status == _statusFilter;
      if (!statusMatches) return false;
      if (query.isEmpty) return true;
      return v.name.toLowerCase().contains(query) || v.mobile.contains(query);
    }).toList();
  }

  // API & State Actions
  Future<void> loadVisitors() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _visitors = await _apiService.getAllVisitors();
    } catch (e) {
      _errorMessage = 'Failed to load visitors: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Visitor? getVisitorById(String id) {
    String clean = id.trim();
    if (clean.toUpperCase().startsWith('VMS:')) {
      final List<String> parts = clean.split(':');
      if (parts.length >= 2) {
        clean = parts[1].trim();
      }
    }
    for (final Visitor v in _visitors) {
      if (v.id.toLowerCase() == clean.toLowerCase()) {
        return v;
      }
    }
    return null;
  }

  Future<Visitor?> registerVisitor({
    required String name,
    required String mobile,
    required String email,
    required String type,
    required String project,
    required String purpose,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Visitor created = await _apiService.createVisitor(<String, dynamic>{
        'name': name.trim(),
        'mobile': mobile.trim(),
        'email': email.trim(),
        'visitor_type': type,
        'project': project,
        'purpose': purpose.trim(),
      });
      _visitors.insert(0, created);
      return created;
    } catch (e) {
      _errorMessage = 'Failed to register visitor: $e';
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateVisitor({
    required String id,
    required String name,
    required String mobile,
    required String email,
    required String type,
    required String project,
    required String purpose,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Visitor updated = await _apiService.updateVisitor(
        id,
        <String, dynamic>{
          'name': name.trim(),
          'mobile': mobile.trim(),
          'email': email.trim(),
          'visitor_type': type,
          'project': project,
          'purpose': purpose.trim(),
        },
      );
      final int index = _visitors.indexWhere((Visitor v) => v.id == id);
      if (index != -1) {
        _visitors[index] = updated;
      }
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update visitor: $e';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> checkIn(String id) async {
    final Visitor? visitor = getVisitorById(id);
    if (visitor == null || visitor.status != VisitorStatus.registered) {
      return false;
    }

    try {
      final DateTime now = DateTime.now();
      final Visitor updated = await _apiService.updateStatus(
        id,
        status: VisitorStatus.checkedIn,
        timestamp: now,
      );
      final int index = _visitors.indexWhere((Visitor v) => v.id == id);
      if (index != -1) {
        _visitors[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Check-in failed: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> checkOut(String id) async {
    final Visitor? visitor = getVisitorById(id);
    if (visitor == null || visitor.status != VisitorStatus.checkedIn) {
      return false;
    }

    try {
      final DateTime now = DateTime.now();
      final Visitor updated = await _apiService.updateStatus(
        id,
        status: VisitorStatus.checkedOut,
        timestamp: now,
      );
      final int index = _visitors.indexWhere((Visitor v) => v.id == id);
      if (index != -1) {
        _visitors[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Check-out failed: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteVisitor(String id) async {
    try {
      final bool deleted = await _apiService.deleteVisitor(id);
      if (deleted) {
        _visitors.removeWhere((Visitor v) => v.id == id);
        notifyListeners();
      }
      return deleted;
    } catch (e) {
      _errorMessage = 'Delete failed: $e';
      notifyListeners();
      return false;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(VisitorStatus? status) {
    if (_statusFilter != status) {
      _statusFilter = status;
      notifyListeners();
    }
  }

  void clearFilters() {
    _searchQuery = '';
    _statusFilter = null;
    notifyListeners();
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
