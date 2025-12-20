// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/app_theme.dart';
import 'core/network/dio_client.dart';
import 'core/storage/hive_storage.dart';

// Auth
import 'views/auth/logic/cubit/auth_cubit.dart';
import 'views/auth/data/repositories/auth_repository.dart';
import 'views/auth/presentation/pages/login_screen.dart';
import 'views/auth/presentation/pages/register_job_seeker_screen.dart';
import 'views/auth/presentation/pages/register_recruiter_screen.dart';
import 'views/auth/presentation/pages/role_selection_screen.dart';

// Splash & Onboarding
import 'views/splash/presentation/pages/splash_screen.dart';
import 'views/splash/presentation/pages/onboarding_screen.dart';

// Job Seeker
import 'views/home/presentation/pages/job_seeker_home_screen.dart';
import 'views/home/presentation/pages/edit_job_seeker_profile.dart';

// Recruiter
import 'views/recruiter/presentation/pages/recruiter_home_screen.dart';
import 'views/recruiter/logic/create_job_cubit.dart';
import 'views/recruiter/logic/recruiter_jobs_cubit.dart';
import 'views/recruiter/logic/recruiter_applicants_cubit.dart';
import 'package:flutter_alinfo9/core/network/file_upload_repository.dart';
import 'views/recruiter/logic/recruiter_profile_cubit.dart';
import 'views/recruiter/presentation/pages/create_job_screen.dart';
import 'views/recruiter/presentation/pages/edit_job_screen.dart';
import 'views/recruiter/presentation/pages/edit_recruiter_profile.dart';

// Jobs
import 'views/jobs/logic/job_cubit.dart';
import 'views/jobs/data/repositories/job_repository.dart';
import 'views/jobs/presentation/pages/job_details_screen.dart';
import 'views/jobs/logic/saved_job_cubit.dart';
import 'views/jobs/data/repositories/saved_job_repository.dart';

// Applications
import 'views/applications/data/repositories/application_repository.dart';
import 'views/applications/presentation/pages/my_applications_screen.dart';
import 'views/applications/presentation/pages/application_management_screen.dart';

// User
import 'views/auth/data/repositories/user_repository.dart';


// Quiz
import 'views/quiz/presentation/pages/quiz_screen.dart';

// Chat
import 'views/chat/presentation/pages/chat_page.dart';

// Admin
import 'views/admin/presentation/pages/admin_dashboard_screen.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive storage
  await HiveStorage.init();

  // Load saved token and set it in Dio
  final token = await HiveStorage.getToken();
  if (token != null && token.isNotEmpty) {
    DioClient.instance.setAuthToken(token);
    debugPrint('✅ Token loaded from storage: ${token.substring(0, 20)}...');
  } else {
    debugPrint('⚠️ No token found in storage');
  }

  // Load and apply saved theme mode
  final savedThemeMode = HiveStorage.getThemeMode();
  final themeMode = savedThemeMode == 'light'
      ? ThemeMode.light
      : savedThemeMode == 'dark'
      ? ThemeMode.dark
      : ThemeMode.system;

  runApp(MasroufiApp(initialThemeMode: themeMode));
}

class MasroufiApp extends StatefulWidget {
  final ThemeMode initialThemeMode;

  const MasroufiApp({super.key, this.initialThemeMode = ThemeMode.dark});

  @override
  State<MasroufiApp> createState() => _MasroufiAppState();

  static _MasroufiAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MasroufiAppState>();
  }
}

class _MasroufiAppState extends State<MasroufiApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
  }

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;

      // Save theme preference
      final themeName = _themeMode == ThemeMode.dark ? 'dark' : 'light';
      HiveStorage.saveThemeMode(themeName);
      debugPrint('🎨 Theme changed to: $themeName');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Global Auth Cubit - Available throughout the app
        BlocProvider(
          create: (context) => AuthCubit(AuthRepository()),
          lazy: false,
        ),

        // Add more global providers here as we build them:
        // BlocProvider(create: (context) => ProfileCubit(ProfileRepository())),
        // BlocProvider(create: (context) => NotificationCubit(NotificationRepository())),
      ],
      child: MaterialApp(
        title: 'MASROUFI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _themeMode,
        initialRoute: '/',
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ==================== SPLASH & ONBOARDING ====================
      case '/':
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );

      case '/onboarding':
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
          settings: settings,
        );

      // ==================== AUTHENTICATION ====================
      case '/role-selection':
        return MaterialPageRoute(
          builder: (_) => const RoleSelectionScreen(),
          settings: settings,
        );

      case '/login':
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case '/register-job-seeker':
        return MaterialPageRoute(
          builder: (_) => const RegisterJobSeekerScreen(),
          settings: settings,
        );

      case '/register-recruiter':
        return MaterialPageRoute(
          builder: (_) => const RegisterRecruiterScreen(),
          settings: settings,
        );

      // ==================== JOB SEEKER ====================
      case '/job-seeker-home':
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => JobCubit(JobRepository()),
              ),
              BlocProvider(
                create: (context) => SavedJobCubit(SavedJobRepository(dioClient: DioClient.instance)),
              ),
            ],
            child: const JobSeekerHomeScreen(),
          ),
          settings: settings,
        );

      case '/edit-job-seeker-profile':
        return MaterialPageRoute(
          builder: (_) => const EditJobSeekerProfileScreen(),
          settings: settings,
        );

      // ==================== RECRUITER ====================
      case '/recruiter-home':
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => RecruiterJobsCubit(JobRepository()),
              ),
              BlocProvider(
                create: (context) =>
                    RecruiterApplicantsCubit(ApplicationRepository()),
              ),
              BlocProvider(
                create: (context) => RecruiterProfileCubit(UserRepository()),
              ),
            ],
            child: const RecruiterHomeScreen(),
          ),
          settings: settings,
        );

      case '/create-job':
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) =>
                CreateJobCubit(JobRepository(), FileUploadRepository()),
            child: const CreateJobScreen(),
          ),
          settings: settings,
        );

      case '/edit-job':
        final args = settings.arguments as Map<String, dynamic>?;
        final jobId = args?['jobId'] as int?;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) =>
                CreateJobCubit(JobRepository(), FileUploadRepository()),
            child: EditJobScreen(jobId: jobId),
          ),
          settings: settings,
        );

      case '/edit-recruiter-profile':
        return MaterialPageRoute(
          builder: (_) => const EditRecruiterProfileScreen(),
          settings: settings,
        );

      // ==================== JOBS ====================
      case '/job-details':
        final args = settings.arguments as Map<String, dynamic>?;
        final isRecruiter = args?['isRecruiter'] as bool? ?? false;
        final jobId = args?['jobId'] as int?;
        return MaterialPageRoute(
          builder: (_) =>
              JobDetailsScreen(isRecruiter: isRecruiter, jobId: jobId),
          settings: settings,
        );

      // ==================== APPLICATIONS (NEW) ====================
      case '/my-applications':
        return MaterialPageRoute(
          builder: (_) => const MyApplicationsScreen(),
          settings: settings,
        );

      case '/application-management':
        final args = settings.arguments as Map<String, dynamic>?;
        final jobId = args?['jobId'] as int?;
        final jobTitle = args?['jobTitle'] as String?;

        if (jobId == null || jobTitle == null) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(child: Text('Missing job information')),
            ),
          );
        }

        return MaterialPageRoute(
          builder: (_) =>
              ApplicationManagementScreen(jobId: jobId, jobTitle: jobTitle),
          settings: settings,
        );

      // ==================== QUIZ ====================
      case '/quiz':
        return MaterialPageRoute(
          builder: (_) => const QuizScreen(),
          settings: settings,
        );

      // ==================== CHAT ====================
      case '/chat':
        return MaterialPageRoute(
          builder: (_) => const ChatScreen(),
          settings: settings,
        );

      // ==================== ADMIN ====================
      case '/admin-dashboard':
        return MaterialPageRoute(
          builder: (_) => const AdminDashboardScreen(),
          settings: settings,
        );

      // ==================== DEFAULT (404) ====================
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Route "${settings.name}" not found',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).pushReplacementNamed('/'),
                    child: const Text('Go Home'),
                  ),
                ],
              ),
            ),
          ),
          settings: settings,
        );
    }
  }
}

// Helper mixin for theme access (kept for backward compatibility)
mixin MasroufiAppThemeNotifier {
  ThemeMode get themeMode;
  void toggleTheme();
}
