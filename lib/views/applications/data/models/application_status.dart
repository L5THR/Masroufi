// ignore_for_file: constant_identifier_names

enum ApplicationStatus {
  PENDING,
  VIEWED,
  REJECTED,
  ACCEPTED,
  HIRED,
  COMPLETED;

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
      case 'HIRED':
        return ApplicationStatus.HIRED;
      case 'COMPLETED':
        return ApplicationStatus.COMPLETED;
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
      case ApplicationStatus.HIRED:
        return 'Hired';
      case ApplicationStatus.COMPLETED:
        return 'Completed';
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
      case ApplicationStatus.HIRED:
        return 0xFF26A69A; // Teal
      case ApplicationStatus.COMPLETED:
        return 0xFF9CCC65; // Light Green
    }
  }
}
