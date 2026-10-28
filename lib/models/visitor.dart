import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum VisitorStatus {
  registered('Registered', AppColors.registered),
  checkedIn('Checked In', AppColors.checkedIn),
  checkedOut('Checked Out', AppColors.checkedOut);

  const VisitorStatus(this.label, this.color);

  final String label;
  final Color color;

  static VisitorStatus fromString(String? value) {
    if (value == null) return VisitorStatus.registered;
    final String clean = value.trim().toLowerCase();
    if (clean == 'checked in' || clean == 'checkedin' || clean == 'checked_in') {
      return VisitorStatus.checkedIn;
    }
    if (clean == 'checked out' || clean == 'checkedout' || clean == 'checked_out') {
      return VisitorStatus.checkedOut;
    }
    return VisitorStatus.registered;
  }
}

class VisitorOptions {
  VisitorOptions._();

  static const List<String> types = <String>['Customer', 'Vendor', 'Other'];
  static const List<String> projects = <String>[
    'Project A',
    'Project B',
    'Project C',
  ];
}

Color visitorTypeColor(String type) {
  switch (type) {
    case 'Customer':
      return AppColors.customerBadge;
    case 'Vendor':
      return AppColors.vendorBadge;
    default:
      return AppColors.otherBadge;
  }
}

class Visitor {
  const Visitor({
    required this.id,
    required this.name,
    required this.mobile,
    required this.email,
    required this.type,
    required this.project,
    required this.purpose,
    required this.status,
    required this.createdAt,
    this.checkInTime,
    this.checkOutTime,
  });

  final String id;
  final String name;
  final String mobile;
  final String email;
  final String type;
  final String project;
  final String purpose;
  final VisitorStatus status;
  final DateTime createdAt;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;

  String get initials {
    final List<String> parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts[1].substring(0, 1))
        .toUpperCase();
  }

  Visitor copyWith({
    String? name,
    String? mobile,
    String? email,
    String? type,
    String? project,
    String? purpose,
    VisitorStatus? status,
    DateTime? checkInTime,
    DateTime? checkOutTime,
  }) {
    return Visitor(
      id: id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      type: type ?? this.type,
      project: project ?? this.project,
      purpose: purpose ?? this.purpose,
      status: status ?? this.status,
      createdAt: createdAt,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
    );
  }

  /// Deserialization from REST API JSON
  factory Visitor.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val is DateTime) return val;
      if (val is String && val.isNotEmpty) {
        return DateTime.tryParse(val) ?? DateTime.now();
      }
      return DateTime.now();
    }

    DateTime? parseNullableDate(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      if (val is String && val.isNotEmpty) {
        return DateTime.tryParse(val);
      }
      return null;
    }

    return Visitor(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      mobile: (json['mobile'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      type: (json['visitor_type'] ?? json['type'] ?? 'Customer').toString(),
      project: (json['project'] ?? 'Project A').toString(),
      purpose: (json['purpose'] ?? '').toString(),
      status: VisitorStatus.fromString(json['status']?.toString()),
      createdAt: parseDate(json['created_at'] ?? json['createdAt']),
      checkInTime: parseNullableDate(json['check_in_time'] ?? json['checkInTime']),
      checkOutTime: parseNullableDate(json['check_out_time'] ?? json['checkOutTime']),
    );
  }

  /// Serialization to REST API JSON
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'mobile': mobile,
      'email': email,
      'visitor_type': type,
      'project': project,
      'purpose': purpose,
      'status': status.label,
      'created_at': createdAt.toIso8601String(),
      'check_in_time': checkInTime?.toIso8601String(),
      'check_out_time': checkOutTime?.toIso8601String(),
    };
  }
}
