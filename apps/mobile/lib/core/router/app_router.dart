import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Screens will be imported later
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/learning/presentation/screens/learning_screen.dart';
import '../../features/learning/presentation/screens/course_detail_screen.dart';
import '../../features/learning/presentation/screens/course_player_screen.dart';
import '../../features/sync/presentation/screens/sync_settings_screen.dart';
import '../../features/shared/presentation/screens/notification_history_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/schemes/screens/scheme_recommender_screen.dart';
import '../../features/schemes/presentation/screens/scheme_questionnaire_screen.dart';
import '../../features/mentorship/presentation/screens/mentor_match_screen.dart';
import '../../features/mentorship/presentation/screens/mentor_detail_screen.dart';
import '../../features/mentorship/presentation/screens/my_sessions_screen.dart';
import '../../features/businesses/presentation/screens/business_list_screen.dart';
import '../../features/market/presentation/screens/market_prices_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/learning',
        name: 'learning',
        builder: (context, state) => const LearningScreen(),
      ),
      GoRoute(
        path: '/learning/:id',
        name: 'course_detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return CourseDetailScreen(courseId: id);
        },
      ),
      GoRoute(
        path: '/learning/player/:courseId',
        name: 'course_player',
        builder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          final lessonId = state.uri.queryParameters['lessonId'];
          return CoursePlayerScreen(
              courseId: courseId, initialLessonId: lessonId,);
        },
      ),
      GoRoute(
        path: '/businesses',
        name: 'businesses',
        builder: (context, state) => const BusinessListScreen(),
      ),
      GoRoute(
        path: '/market',
        name: 'market',
        builder: (context, state) => const MarketPricesScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/sync',
        name: 'sync_settings',
        builder: (context, state) => const SyncSettingsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationHistoryScreen(),
      ),
      GoRoute(
        path: '/schemes',
        name: 'schemes',
        builder: (context, state) => const SchemeRecommenderScreen(),
      ),
      GoRoute(
        path: '/schemes/questionnaire',
        name: 'scheme_questionnaire',
        builder: (context, state) => const SchemeQuestionnaireScreen(),
      ),
      GoRoute(
        path: '/mentors',
        name: 'mentors',
        builder: (context, state) => const MentorMatchScreen(),
      ),
      GoRoute(
        path: '/mentors/:id',
        name: 'mentor_detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return MentorDetailScreen(mentorId: id);
        },
      ),
      GoRoute(
        path: '/mentors/sessions',
        name: 'my_sessions',
        builder: (context, state) => const MySessionsScreen(),
      ),
    ],
    redirect: (context, state) {
      final isAuthPage = state.uri.path == '/login' || state.uri.path == '/signup';
      final isLoggedIn = authState.user != null;

      // If not logged in and not on auth page, redirect to login
      if (!isLoggedIn && !isAuthPage) return '/login';

      // If logged in and on auth page, redirect to dashboard
      if (isLoggedIn && isAuthPage) return '/';

      return null; // No redirect needed
    },
  );
});
