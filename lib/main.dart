// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_alinfo9/core/app_theme.dart';
import 'package:flutter_alinfo9/views/chat/presentation/pages/chat_page.dart';
import 'package:flutter_alinfo9/views/home/presentation/pages/edit_job_seeker_profile.dart';
import 'package:flutter_alinfo9/views/recruiter/presentation/pages/edit_job_screen.dart';
import 'package:flutter_alinfo9/views/recruiter/presentation/pages/edit_recruiter_profile.dart';
import 'package:flutter_alinfo9/views/splash/presentation/pages/onboarding_screen.dart';
import 'views/splash/presentation/pages/splash_screen.dart';
import 'views/auth/presentation/pages/role_selection_screen.dart';
import 'views/auth/presentation/pages/login_screen.dart';
import 'views/auth/presentation/pages/register_job_seeker_screen.dart';
import 'views/auth/presentation/pages/register_recruiter_screen.dart';
import 'views/home/presentation/pages/job_seeker_home_screen.dart';
import 'views/jobs/presentation/pages/job_details_screen.dart';
import 'views/quiz/presentation/pages/quiz_screen.dart';
import 'views/recruiter/presentation/pages/recruiter_home_screen.dart';
import 'views/recruiter/presentation/pages/create_job_screen.dart';
import 'views/admin/presentation/pages/admin_dashboard_screen.dart';

void main() {
  runApp(const MasroufiApp());
}

mixin MasroufiAppThemeNotifier {
  ThemeMode get themeMode;
  void toggleTheme();
}

class MasroufiApp extends StatefulWidget {
  const MasroufiApp({super.key});

  @override
  State<MasroufiApp> createState() => _MasroufiAppState();

  static _MasroufiAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MasroufiAppState>();
  }
}

class _MasroufiAppState extends State<MasroufiApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MASROUFI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case '/onboarding':
            return MaterialPageRoute(builder: (_) => const OnboardingScreen());
          case '/role-selection':
            return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/register-job-seeker':
            return MaterialPageRoute(builder: (_) => const RegisterJobSeekerScreen());
          case '/register-recruiter':
            return MaterialPageRoute(builder: (_) => const RegisterRecruiterScreen());
          case '/job-seeker-home':
            return MaterialPageRoute(builder: (_) => const JobSeekerHomeScreen());
          case '/job-details':
            final args = settings.arguments as Map<String, dynamic>?;
            final isRecruiter = args?['isRecruiter'] ?? false;
            return MaterialPageRoute(
              builder: (_) => JobDetailsScreen(isRecruiter: isRecruiter),
            );
          case '/quiz':
            return MaterialPageRoute(builder: (_) => const QuizScreen());
          case '/chat':
            return MaterialPageRoute(builder: (_) => const ChatScreen());
          case '/recruiter-home':
            return MaterialPageRoute(builder: (_) => const RecruiterHomeScreen());
          case '/create-job':
            return MaterialPageRoute(builder: (_) => const CreateJobScreen());
          case '/edit-job':
            return MaterialPageRoute(builder: (_) => const EditJobScreen());
          case '/admin-dashboard':
            return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
          case '/edit-recruiter-profile':
            return MaterialPageRoute(builder: (_) => const EditRecruiterProfileScreen());
          case '/edit-job-seeker-profile':
            return MaterialPageRoute(builder: (_) => const EditJobSeekerProfileScreen());
          default:
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(child: Text('Route ${settings.name} not found')),
              ),
            );
        }
      },
    );
  }
}
