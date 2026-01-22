// ignore_for_file: constant_identifier_names

enum ApplicationStatus {
  PENDING,
  VIEWED,
  REJECTED,
  ACCEPTED,
  IN_PROGRESS,
  PENDING_COMPLETION,
  HIRED,
  COMPLETED,
  CANCELLED;

  // Convert from API string to enum
  static ApplicationStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return ApplicationStatus.PENDING;
      case 'VIEWED':
        return ApplicationStatus.VIEWED;
      case 'REJECTED':
        return ApplicationStatus.REJECTED;
      case 'ACCEPTED':
        return ApplicationStatus.ACCEPTED;
      case 'IN_PROGRESS':
        return ApplicationStatus.IN_PROGRESS;
      case 'PENDING_COMPLETION':
        return ApplicationStatus.PENDING_COMPLETION;
      case 'HIRED':
        return ApplicationStatus.HIRED;
      case 'COMPLETED':
        return ApplicationStatus.COMPLETED;
      case 'CANCELLED':
        return ApplicationStatus.CANCELLED;
      default:
        return ApplicationStatus.PENDING;
    }
  }

  // Convert enum to API string
  String toApiString() {
    return name;
  }

  // Get display text for UI
  String get displayName {
    switch (this) {
      case ApplicationStatus.PENDING:
        return 'Pending';
      case ApplicationStatus.VIEWED:
        return 'Viewed';
      case ApplicationStatus.REJECTED:
        return 'Rejected';
      case ApplicationStatus.ACCEPTED:
        return 'Accepted';
      case ApplicationStatus.IN_PROGRESS:
        return 'In Progress';
      case ApplicationStatus.PENDING_COMPLETION:
        return 'Awaiting Confirmation';
      case ApplicationStatus.HIRED:
        return 'Hired';
      case ApplicationStatus.COMPLETED:
        return 'Completed';
      case ApplicationStatus.CANCELLED:
        return 'Cancelled';
    }
  }

  // Get color for status badge
  int get colorValue {
    switch (this) {
      case ApplicationStatus.PENDING:
        return 0xFFFFA726; // Orange/Yellow
      case ApplicationStatus.VIEWED:
        return 0xFF42A5F5; // Blue
      case ApplicationStatus.REJECTED:
        return 0xFFEF5350; // Red
      case ApplicationStatus.ACCEPTED:
        return 0xFF66BB6A; // Green
      case ApplicationStatus.IN_PROGRESS:
        return 0xFF7E57C2; // Purple - work in progress
      case ApplicationStatus.PENDING_COMPLETION:
        return 0xFFFFB300; // Amber - awaiting confirmation
      case ApplicationStatus.HIRED:
        return 0xFF26A69A; // Teal
      case ApplicationStatus.COMPLETED:
        return 0xFF9CCC65; // Light Green
      case ApplicationStatus.CANCELLED:
        return 0xFF78909C; // Blue Grey
    }
  }

  // Check if job seeker can start work
  bool get canStartWork => this == ApplicationStatus.ACCEPTED;

  // Check if either party can request completion
  bool get canRequestCompletion => this == ApplicationStatus.IN_PROGRESS;

  // Check if job is awaiting confirmation
  bool get isAwaitingConfirmation => this == ApplicationStatus.PENDING_COMPLETION;

  // Check if job is fully completed
  bool get isCompleted => this == ApplicationStatus.COMPLETED;

  // Check if application is active (not terminal)
  bool get isActive => this == ApplicationStatus.ACCEPTED ||
      this == ApplicationStatus.IN_PROGRESS ||
      this == ApplicationStatus.PENDING_COMPLETION;
}
