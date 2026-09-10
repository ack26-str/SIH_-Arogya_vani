import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/welcome_screen.dart';
import '../../features/onboarding/presentation/screens/language_selection_screen.dart';
import '../../features/onboarding/presentation/screens/profile_setup_screen.dart';
import '../../features/onboarding/presentation/screens/consent_screen.dart';
import '../../features/onboarding/presentation/screens/session_setup_screen.dart';
import '../../features/home/presentation/screens/main_shell_screen.dart';
import '../../features/home/presentation/screens/home_dashboard_screen.dart';
import '../../features/conversation/presentation/screens/conversation_screen.dart';
import '../../features/medical_records/presentation/screens/medical_records_screen.dart';
import '../../features/medical_records/presentation/screens/record_processing_screen.dart';
import '../../features/medical_records/presentation/screens/record_details_screen.dart';
import '../../features/clinical_summary/presentation/screens/clinical_summary_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/language',
      builder: (context, state) => const LanguageSelectionScreen(),
    ),
    GoRoute(
      path: '/profile-setup',
      builder: (context, state) => const ProfileSetupScreen(),
    ),
    GoRoute(
      path: '/consent',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ConsentScreen(),
    ),
    GoRoute(
      path: '/session-setup',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SessionSetupScreen(),
    ),
    // Persistent Bottom Navigation Shell
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShellScreen(navigationShell: navigationShell);
      },
      branches: [
        // Tab 0: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeDashboardScreen(),
            ),
          ],
        ),
        // Tab 1: Consultation
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/conversation',
              builder: (context, state) => const ConversationScreen(),
            ),
          ],
        ),
        // Tab 2: Records
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/records',
              builder: (context, state) => const MedicalRecordsScreen(),
            ),
          ],
        ),
        // Tab 3: Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    // Standalone Sub-routes
    GoRoute(
      path: '/upload-record',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const MedicalRecordsScreen(autoTriggerUpload: true),
    ),
    GoRoute(
      path: '/record-processing',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const RecordProcessingScreen(),
    ),
    GoRoute(
      path: '/record-details',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const RecordDetailsScreen(),
    ),
    GoRoute(
      path: '/clinical-summary',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ClinicalSummaryScreen(),
    ),
    GoRoute(
      path: '/settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
