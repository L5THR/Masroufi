import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_alinfo9/core/app_theme.dart';
import 'package:flutter_alinfo9/views/auth/logic/cubit/auth_cubit.dart';
import 'package:flutter_alinfo9/views/auth/logic/cubit/auth_state.dart';

class AuthGuard {
  /// Check if user is authenticated. If not, show login prompt dialog.
  /// Returns true if authenticated, false otherwise.
  static bool requireAuth(
    BuildContext context, {
    String? title,
    String? message,
  }) {
    final authState = context.read<AuthCubit>().state;

    if (authState.isAuthenticated) {
      return true;
    }

    // User is not authenticated - show login prompt
    _showLoginPrompt(
      context,
      title: title ?? 'Login Required',
      message: message ??
          'You need to be logged in to perform this action.\n\nCreate an account or login to continue.',
    );

    return false;
  }

  /// Show a dialog prompting the user to login
  static void _showLoginPrompt(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? AppTheme.secondaryBlack : AppTheme.primaryWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                color: AppTheme.textWhite,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
            fontSize: 16,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Maybe Later',
              style: TextStyle(
                color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to role selection/login
              Navigator.of(context).pushNamed('/role-selection');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentBlue,
              foregroundColor: AppTheme.textWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Login / Sign Up'),
          ),
        ],
      ),
    );
  }

  /// Check if user has a specific role. If not, show permission denied dialog.
  /// Returns true if user has the role, false otherwise.
  static bool requireRole(
    BuildContext context,
    String requiredRole, {
    String? message,
  }) {
    final authState = context.read<AuthCubit>().state;

    if (!authState.isAuthenticated) {
      requireAuth(context);
      return false;
    }

    final userRole = authState.userRole?.toUpperCase();
    if (userRole == requiredRole.toUpperCase()) {
      return true;
    }

    // User doesn't have required role
    _showPermissionDenied(
      context,
      message: message ??
          'You need to be a ${requiredRole.toLowerCase()} to perform this action.',
    );

    return false;
  }

  static void _showPermissionDenied(BuildContext context,
      {required String message}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? AppTheme.secondaryBlack : AppTheme.primaryWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade700,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppTheme.textWhite,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Permission Denied',
                style: TextStyle(
                  color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
            fontSize: 16,
            height: 1.5,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentBlue,
              foregroundColor: AppTheme.textWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
