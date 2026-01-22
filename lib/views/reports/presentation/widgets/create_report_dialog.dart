// lib/views/reports/presentation/widgets/create_report_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_alinfo9/core/app_theme.dart';
import '../../logic/report_cubit.dart';
import '../../logic/report_state.dart';
import '../../data/repositories/report_repository.dart';
import '../../data/models/report.dart';

/// Dialog for creating a report for a job or user
class CreateReportDialog extends StatefulWidget {
  final int targetId;
  final ReportTargetType targetType;
  final String targetName;

  const CreateReportDialog({
    Key? key,
    required this.targetId,
    required this.targetType,
    required this.targetName,
  }) : super(key: key);

  @override
  State<CreateReportDialog> createState() => _CreateReportDialogState();
}

class _CreateReportDialogState extends State<CreateReportDialog> {
  final _reasonController = TextEditingController();
  String? _selectedReason;

  final List<String> _commonReasons = [
    'Inappropriate content',
    'Spam or misleading',
    'Fraud or scam',
    'Harassment',
    'False information',
    'Other',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isJob = widget.targetType == ReportTargetType.JOB;

    return BlocProvider(
      create: (context) => ReportCubit(ReportRepository()),
      child: BlocConsumer<ReportCubit, ReportState>(
        listener: (context, state) {
          if (state is ReportCreated) {
            Navigator.pop(context, state.report);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Report submitted successfully. We will review it shortly.'),
                backgroundColor: AppTheme.accentGreen,
                duration: Duration(seconds: 3),
              ),
            );
          } else if (state is ReportFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: AppTheme.errorRed,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ReportCreating;

          return AlertDialog(
            backgroundColor: isDark
                ? AppTheme.secondaryBlack
                : AppTheme.secondaryWhite,
            title: Text(
              'Report ${isJob ? "Job" : "User"}',
              style: TextStyle(
                color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Target Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.primaryBlack
                          : AppTheme.lightGrey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isJob ? Icons.work_outline : Icons.person_outline,
                          color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.targetName,
                            style: TextStyle(
                              color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Reason Selection
                  Text(
                    'Reason for Report',
                    style: TextStyle(
                      color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Common Reasons
                  ...widget.targetType == ReportTargetType.JOB
                      ? _commonReasons.map((reason) {
                          final isSelected = _selectedReason == reason;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: InkWell(
                              onTap: isLoading
                                  ? null
                                  : () {
                                      setState(() {
                                        _selectedReason = reason;
                                        if (reason != 'Other') {
                                          _reasonController.text = reason;
                                        } else {
                                          _reasonController.clear();
                                        }
                                      });
                                    },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.accentBlue.withValues(alpha: 0.1)
                                      : (isDark
                                          ? AppTheme.primaryBlack
                                          : Colors.white),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.accentBlue
                                        : (isDark
                                            ? AppTheme.tertiaryGrey
                                            : AppTheme.lightGrey),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSelected
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_unchecked,
                                      color: isSelected
                                          ? AppTheme.accentBlue
                                          : (isDark
                                              ? AppTheme.textGrey
                                              : AppTheme.textDarkGrey),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      reason,
                                      style: TextStyle(
                                        color: isDark
                                            ? AppTheme.textWhite
                                            : AppTheme.textBlack,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList()
                      : [],

                  // Custom Reason Text Field
                  if (_selectedReason == 'Other' ||
                      widget.targetType == ReportTargetType.USER) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Please describe the issue',
                      style: TextStyle(
                        color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _reasonController,
                      enabled: !isLoading,
                      maxLines: 4,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText: 'Provide details about why you are reporting this ${isJob ? "job" : "user"}...',
                        hintStyle: TextStyle(
                          color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? AppTheme.primaryBlack
                            : Colors.white,
                      ),
                      style: TextStyle(
                        color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: isLoading || _reasonController.text.trim().isEmpty
                    ? null
                    : () {
                        context.read<ReportCubit>().createReport(
                              targetId: widget.targetId,
                              targetType: widget.targetType,
                              reason: _reasonController.text.trim(),
                            );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorRed,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppTheme.textGrey,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Submit Report'),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Helper function to show the report dialog
Future<void> showCreateReportDialog({
  required BuildContext context,
  required int targetId,
  required ReportTargetType targetType,
  required String targetName,
}) async {
  return showDialog(
    context: context,
    builder: (context) => CreateReportDialog(
      targetId: targetId,
      targetType: targetType,
      targetName: targetName,
    ),
  );
}
