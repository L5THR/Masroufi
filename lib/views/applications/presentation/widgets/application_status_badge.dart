// lib/views/applications/presentation/widgets/application_status_badge.dart

import 'package:flutter/material.dart';
import '../../data/models/application_status.dart';

class ApplicationStatusBadge extends StatelessWidget {
  final ApplicationStatus status;
  final bool small;

  const ApplicationStatusBadge({
    super.key,
    required this.status,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(status.colorValue);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 12,
        vertical: small ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: color,
          fontSize: small ? 10 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
