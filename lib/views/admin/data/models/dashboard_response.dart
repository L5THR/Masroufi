class DashboardResponse {
  final Map<String, dynamic> stats;

  DashboardResponse({required this.stats});

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      stats: json['stats'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stats': stats,
    };
  }

  // Convenience getters for common stats
  int get totalUsers => (stats['totalUsers'] as num?)?.toInt() ?? 0;
  int get activeJobs => (stats['activeJobs'] as num?)?.toInt() ?? 0;
  int get reports => (stats['reports'] as num?)?.toInt() ?? 0;
  int get completedJobs => (stats['completedJobs'] as num?)?.toInt() ?? 0;
  int get pendingApplications =>
      (stats['pendingApplications'] as num?)?.toInt() ?? 0;

  @override
  String toString() {
    return 'DashboardResponse(stats: $stats)';
  }
}
