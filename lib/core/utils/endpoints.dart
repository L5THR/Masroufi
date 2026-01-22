// lib/core/utils/endpoints.dart

class ApiEndpoints {
  static const String _api = '/api';

  // ==================== AUTHENTICATION ====================
  static const String registerJobSeeker = '$_api/auth/register/job-seeker';
  static const String registerRecruiter = '$_api/auth/register/recruiter';
  static const String login = '$_api/auth/login';
  static const String currentUser = '$_api/users/me';

  // ==================== USER PROFILE ====================
  static const String updateJobSeekerProfile =
      '$_api/users/me/job-seeker-profile';
  static const String updateRecruiterProfile =
      '$_api/users/me/recruiter-profile';

  // ==================== JOBS ====================
  static const String jobs = '$_api/jobs';
  static const String searchJobs = '$_api/jobs/search';
  static const String myJobs = '$_api/jobs/recruiters/me/jobs';

  // Dynamic job endpoints
  static String jobById(int jobId) => '$jobs/$jobId';
  static String updateJob(int jobId) => '$jobs/$jobId';
  static String deleteJob(int jobId) => '$jobs/$jobId';
  static String jobQuiz(int jobId) => '$jobs/$jobId/quiz';

  // ==================== APPLICATIONS ====================
  static const String myApplications = '$_api/job-seekers/me/applications';

  // Dynamic application endpoints
  static String applyToJob(int jobId) => '$jobs/$jobId/apply';
  static String jobApplications(int jobId) => '$jobs/$jobId/applications';
  static String updateApplicationStatus(int applicationId) =>
      '$_api/applications/$applicationId/status';
  static String applicationDetail(int applicationId) =>
      '$_api/applications/$applicationId';

  // Job Completion endpoints
  static String startWork(int applicationId) =>
      '$_api/applications/$applicationId/start';
  static String requestCompletion(int applicationId) =>
      '$_api/applications/$applicationId/request-completion';
  static String confirmCompletion(int applicationId) =>
      '$_api/applications/$applicationId/confirm-completion';
  static String cancelCompletionRequest(int applicationId) =>
      '$_api/applications/$applicationId/cancel-completion-request';

  // ==================== SAVED JOBS ====================
  static const String mySavedJobs = '$_api/job-seekers/me/saved-jobs';

  // Dynamic saved job endpoints
  static String saveJob(int jobId) => '$jobs/$jobId/save';
  static String unsaveJob(int jobId) => '$jobs/$jobId/save';

  // ==================== CATEGORIES ====================
  static const String categories = '$_api/categories';
  static String categorySkills(int categoryId) => '$categories/$categoryId/skills';

  // Admin Category Management
  static const String adminCategories = '$_api/admin/categories';
  static String adminUpdateCategory(int categoryId) => '$adminCategories/$categoryId';
  static String adminDeleteCategory(int categoryId) => '$adminCategories/$categoryId';

  // ==================== FILE UPLOAD ====================
  static const String uploadFile = '$_api/files/upload';

  // ==================== NOTIFICATIONS ====================
  static const String notifications = '$_api/notifications';
  static String markNotificationRead(int notificationId) =>
      '$notifications/$notificationId/read';

  // ==================== QUIZ ====================
  static const String quizzes = '$_api/quizzes';
  static String getQuizById(int quizId) => '$quizzes/$quizId';
  static String submitQuiz(int quizId) => '$quizzes/$quizId/submit';
  static String quizAttempts(int quizId) => '$quizzes/$quizId/attempts';
  static String updateQuiz(int quizId) => '$quizzes/$quizId';
  static String deleteQuiz(int quizId) => '$quizzes/$quizId';

  // ==================== CHAT ====================
  static const String chatMessages = '$_api/chat/messages';
  static const String chatConversations = '$_api/chat/conversations';
  static String chatHistory(int userId) => '$_api/chat/history/$userId';

  // ==================== REVIEWS ====================
  static const String reviews = '$_api/reviews';
  static const String myReceivedReviews = '$_api/reviews/me/received';
  static const String myGivenReviews = '$_api/reviews/me/given';
  static String reviewById(int reviewId) => '$reviews/$reviewId';
  static String userReviews(int userId) => '$reviews/user/$userId';
  static String userRatingSummary(int userId) => '$reviews/user/$userId/summary';
  static String reviewStatus(int applicationId) =>
      '$reviews/application/$applicationId/status';

  // ==================== REPORTS ====================
  static const String reports = '$_api/reports';
  static const String myReports = '$_api/reports/me';

  // ==================== ADMIN ====================
  static const String adminDashboard = '$_api/admin/dashboard';
  static const String adminUsers = '$_api/admin/users';
  static const String adminReports = '$_api/admin/reports';
  static const String adminActivities = '$_api/admin/activities';

  static String updateUserStatus(int userId) => '$adminUsers/$userId/status';
  static String updateUserRole(int userId) => '$adminUsers/$userId/role';
  static String deleteUser(int userId) => '$adminUsers/$userId';
  static String updateReportStatus(int reportId) =>
      '$adminReports/$reportId/status';

  // Admin job management
  static const String adminJobs = '$_api/admin/jobs';
  static String adminDeleteJob(int jobId) => '$adminJobs/$jobId';
}
