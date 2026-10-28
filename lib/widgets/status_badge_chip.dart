import 'package:flutter/material.dart';

import '../models/visitor.dart';

/// Clean Status Badge displaying visitor status with an indicator dot.
class StatusBadgeChip extends StatelessWidget {
  const StatusBadgeChip({
    super.key,
    required this.status,
    this.compact = false,
  });

  final VisitorStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final Color color = status.color;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              color: color,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
