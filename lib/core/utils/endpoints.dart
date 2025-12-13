class ApiEndpoints {
  static const String _api = '/api';

  // Authentication
  static const String registerJobSeeker = '$_api/auth/register/job-seeker';
  static const String registerRecruiter = '$_api/auth/register/recruiter';
  static const String login = '$_api/auth/login';
  static const String currentUser = '$_api/users/me';

  // Jobs
  static const String jobs = '$_api/jobs';
  static const String searchJobs = '$_api/jobs/search';
  static const String myJobs = '$_api/recruiters/me/jobs';

  // Applications
  static const String myApplications = '$_api/job-seekers/me/applications';

  // Saved Jobs
  static const String mySavedJobs = '$_api/job-seekers/me/saved-jobs';

  // Categories
  static const String categories = '$_api/categories';

  // File Upload
  static const String uploadFile = '$_api/files/upload';
}
