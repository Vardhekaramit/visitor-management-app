import 'dart:async';

import '../models/visitor.dart';

/// Service responsible for REST API operations (GET, POST, PUT, DELETE, PATCH).
/// Uses asynchronous JSON serialization/deserialization with configurable baseUrl.
class VisitorApiService {
  VisitorApiService({String? baseUrl})
      : baseUrl = baseUrl ?? 'https://api.mockvisitor.internal/v1';

  final String baseUrl;

  int _nextId = 1001;

  // In-memory mock database representing persistent backend store
  final List<Map<String, dynamic>> _mockDatabase = <Map<String, dynamic>>[];

  bool _isSeeded = false;

  void _ensureSeeded() {
    if (_isSeeded) return;
    _isSeeded = true;
    final DateTime now = DateTime.now();

    _mockDatabase.addAll(<Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'VIS-${_nextId++}',
        'name': 'Neha Patel',
        'mobile': '9825012345',
        'email': 'neha.patel@example.com',
        'visitor_type': 'Vendor',
        'project': 'Project C',
        'purpose': 'Delivery of office supplies and invoice handover.',
        'status': 'Registered',
        'created_at': now.subtract(const Duration(minutes: 20)).toIso8601String(),
        'check_in_time': null,
        'check_out_time': null,
      },
      <String, dynamic>{
        'id': 'VIS-${_nextId++}',
        'name': 'Imran Shaikh',
        'mobile': '9898123456',
        'email': 'imran.shaikh@example.com',
        'visitor_type': 'Customer',
        'project': 'Project A',
        'purpose': 'Product demo and requirement discussion.',
        'status': 'Checked In',
        'created_at': now.subtract(const Duration(hours: 1)).toIso8601String(),
        'check_in_time':
            now.subtract(const Duration(minutes: 50)).toIso8601String(),
        'check_out_time': null,
      },
      <String, dynamic>{
        'id': 'VIS-${_nextId++}',
        'name': 'Sneha Kulkarni',
        'mobile': '9712345678',
        'email': '',
        'visitor_type': 'Other',
        'project': 'Project B',
        'purpose': 'Interview for the design team opening.',
        'status': 'Checked Out',
        'created_at': now.subtract(const Duration(hours: 3)).toIso8601String(),
        'check_in_time': now
            .subtract(const Duration(hours: 2, minutes: 50))
            .toIso8601String(),
        'check_out_time': now
            .subtract(const Duration(hours: 1, minutes: 30))
            .toIso8601String(),
      },
      <String, dynamic>{
        'id': 'VIS-${_nextId++}',
        'name': 'Rohan Desai',
        'mobile': '9879012345',
        'email': 'rohan.desai@example.com',
        'visitor_type': 'Vendor',
        'project': 'Project A',
        'purpose': 'Network equipment maintenance visit.',
        'status': 'Checked In',
        'created_at': now.subtract(const Duration(hours: 4)).toIso8601String(),
        'check_in_time': now
            .subtract(const Duration(hours: 3, minutes: 45))
            .toIso8601String(),
        'check_out_time': null,
      },
      <String, dynamic>{
        'id': 'VIS-${_nextId++}',
        'name': 'Priya Nair',
        'mobile': '9099887766',
        'email': 'priya.nair@example.com',
        'visitor_type': 'Customer',
        'project': 'Project B',
        'purpose': 'Contract review meeting with the account manager.',
        'status': 'Registered',
        'created_at': now
            .subtract(const Duration(hours: 4, minutes: 30))
            .toIso8601String(),
        'check_in_time': null,
        'check_out_time': null,
      },
      <String, dynamic>{
        'id': 'VIS-${_nextId++}',
        'name': 'Aarav Mehta',
        'mobile': '9925566778',
        'email': 'aarav.mehta@example.com',
        'visitor_type': 'Customer',
        'project': 'Project C',
        'purpose': 'Quarterly project status review.',
        'status': 'Checked Out',
        'created_at': now.subtract(const Duration(hours: 5)).toIso8601String(),
        'check_in_time': now
            .subtract(const Duration(hours: 4, minutes: 50))
            .toIso8601String(),
        'check_out_time': now
            .subtract(const Duration(hours: 3, minutes: 20))
            .toIso8601String(),
      },
    ]);
  }

  /// GET /visitors
  Future<List<Visitor>> getAllVisitors() async {
    _ensureSeeded();
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _mockDatabase.map((Map<String, dynamic> item) {
      return Visitor.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }

  /// GET /visitors/:id
  Future<Visitor?> getVisitorById(String id) async {
    _ensureSeeded();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final int index = _mockDatabase
        .indexWhere((Map<String, dynamic> item) => item['id'] == id);
    if (index == -1) return null;
    return Visitor.fromJson(Map<String, dynamic>.from(_mockDatabase[index]));
  }

  /// POST /visitors
  Future<Visitor> createVisitor(Map<String, dynamic> jsonPayload) async {
    _ensureSeeded();
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final String newId = 'VIS-${_nextId++}';
    final Map<String, dynamic> record = Map<String, dynamic>.from(jsonPayload);
    record['id'] = newId;
    record['status'] = record['status'] ?? 'Registered';
    record['created_at'] = DateTime.now().toIso8601String();
    record['check_in_time'] = null;
    record['check_out_time'] = null;

    _mockDatabase.insert(0, record);
    return Visitor.fromJson(record);
  }

  /// PUT /visitors/:id
  Future<Visitor> updateVisitor(
      String id, Map<String, dynamic> jsonPayload) async {
    _ensureSeeded();
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final int index = _mockDatabase
        .indexWhere((Map<String, dynamic> item) => item['id'] == id);
    if (index == -1) {
      throw Exception('Visitor with ID $id not found.');
    }

    final Map<String, dynamic> existing =
        Map<String, dynamic>.from(_mockDatabase[index]);
    existing['name'] = jsonPayload['name'] ?? existing['name'];
    existing['mobile'] = jsonPayload['mobile'] ?? existing['mobile'];
    existing['email'] = jsonPayload['email'] ?? existing['email'];
    existing['visitor_type'] =
        jsonPayload['visitor_type'] ?? existing['visitor_type'];
    existing['project'] = jsonPayload['project'] ?? existing['project'];
    existing['purpose'] = jsonPayload['purpose'] ?? existing['purpose'];

    _mockDatabase[index] = existing;
    return Visitor.fromJson(existing);
  }

  /// PATCH /visitors/:id
  Future<Visitor> updateStatus(
    String id, {
    required VisitorStatus status,
    required DateTime timestamp,
  }) async {
    _ensureSeeded();
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final int index = _mockDatabase
        .indexWhere((Map<String, dynamic> item) => item['id'] == id);
    if (index == -1) {
      throw Exception('Visitor with ID $id not found.');
    }

    final Map<String, dynamic> existing =
        Map<String, dynamic>.from(_mockDatabase[index]);
    existing['status'] = status.label;
    if (status == VisitorStatus.checkedIn) {
      existing['check_in_time'] = timestamp.toIso8601String();
    } else if (status == VisitorStatus.checkedOut) {
      existing['check_out_time'] = timestamp.toIso8601String();
    }

    _mockDatabase[index] = existing;
    return Visitor.fromJson(existing);
  }

  /// DELETE /visitors/:id
  Future<bool> deleteVisitor(String id) async {
    _ensureSeeded();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final int before = _mockDatabase.length;
    _mockDatabase
        .removeWhere((Map<String, dynamic> item) => item['id'] == id);
    return _mockDatabase.length < before;
  }
}
