import 'package:educano_app/features/courses/pages/courses_page.dart';
import 'package:flutter/material.dart';

import 'core/navigation/app_routes.dart';
import 'core/navigation/navigation_service.dart';
import 'core/theme/educano_theme.dart';

import 'package:educano_app/features/home/pages/home_page.dart';
import 'package:educano_app/features/auth/pages/auth_entry_page.dart';
import 'package:educano_app/features/auth/pages/forgot_password_page.dart';
import 'package:educano_app/features/auth/pages/login_page.dart';
import 'package:educano_app/features/auth/pages/signup_page.dart';
import 'package:educano_app/features/auth/pages/verify_account_page.dart';
import 'package:educano_app/features/flashcards/pages/flashcards_page.dart';
import 'package:educano_app/features/ranking/pages/ranking_page.dart';
import 'package:educano_app/features/store_inventory/pages/store_inventory_page.dart';
import 'package:educano_app/features/profile/pages/profile_page.dart';
import 'package:educano_app/features/settings/pages/settings_page.dart';
import 'package:educano_app/features/account_plan/account_plan_page.dart';

import 'features/dashboard/pages/dashboard_page.dart';
import 'package:educano_app/features/dashboard/pages/dashboard_items_page.dart';
import 'package:educano_app/features/dashboard/pages/dashboard_users_page.dart';
import 'package:educano_app/features/dashboard/pages/dashboard_questions_page.dart';
import 'package:educano_app/features/dashboard/pages/dashboard_courses_page.dart';

import 'package:educano_app/features/course/pages/course_page.dart';
import 'package:educano_app/features/materials/models/material_route_args.dart';
import 'package:educano_app/features/materials/pages/material_page.dart';
import 'package:educano_app/features/exam/pages/last_exams_page.dart';
import 'package:educano_app/features/exam/pages/exam_page.dart';
import 'package:educano_app/features/exam/views/exam_config_view.dart';
import 'package:educano_app/features/exam/views/exam_finish_view.dart';
import 'package:educano_app/features/exam/views/exam_result_view.dart';
import 'package:educano_app/features/exam/models/exam_session.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const EducanoApp());
}

class EducanoApp extends StatelessWidget {
  const EducanoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Educano',
      debugShowCheckedModeBanner: false,
      theme: EducanoTheme.lightTheme,
      navigatorKey: NavigationService.navigatorKey,
      initialRoute: AppRoutes.home,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.home:
            return _buildRoute(const AuthEntryPage(), settings);

          case AppRoutes.login:
            return _buildRoute(const LoginPage(), settings);

          case AppRoutes.signup:
            return _buildRoute(const SignupPage(), settings);

          case AppRoutes.verifyAccount:
            final email = settings.arguments;
            return _buildRoute(
              email is String
                  ? VerifyAccountPage(email: email)
                  : const LoginPage(),
              settings,
            );

          case AppRoutes.forgotPassword:
            return _buildRoute(const ForgotPasswordPage(), settings);

          case AppRoutes.flashcards:
            return _buildRoute(const FlashcardsPage(), settings);

          case AppRoutes.ranking:
            return _buildRoute(const RankingPage(), settings);

          case AppRoutes.storeInventory:
            return _buildRoute(const StoreInventoryPage(), settings);

          case AppRoutes.profile:
            return _buildRoute(const ProfilePage(), settings);

          case AppRoutes.accountPlan:
            return _buildRoute(const AccountPlanPage(), settings);

          case AppRoutes.settings:
            return _buildRoute(const SettingsPage(), settings);

          case AppRoutes.courses:
            return _buildRoute(const CoursesPage(), settings);

          case AppRoutes.dashboard:
            return _buildRoute(DashboardPage(), settings);

          case AppRoutes.dashboardCourses:
            return _buildRoute(const DashboardCoursesPage(), settings);

          case AppRoutes.dashboardUsers:
            return _buildRoute(const DashboardUsersPage(), settings);

          case AppRoutes.dashboardQuestions:
            return _buildRoute(const DashboardQuestionsPage(), settings);

          case AppRoutes.dashboardItems:
            return _buildRoute(DashboardItemsPage(), settings);

          case AppRoutes.course:
            final args = settings.arguments;
            final courseId = args is String ? args : 'vestibular-2026';

            return _buildRoute(CoursePage(courseId: courseId), settings);

          case AppRoutes.material:
            final args = settings.arguments;
            if (args is! MaterialRouteArgs) {
              return _buildRoute(const HomePage(), settings);
            }
            return _buildRoute(CourseMaterialPage(arguments: args), settings);

          case AppRoutes.lastExams:
            return _buildRoute(const LastExamsPage(), settings);

          case AppRoutes.examConfig:
            return _buildRoute(const ExamConfigView(), settings);

          case AppRoutes.exam:
          case AppRoutes.activity:
            final session = settings.arguments;
            if (session is! ExamSession) {
              return _buildRoute(const ExamConfigView(), settings);
            }
            return _buildRoute(ExamPage(session: session), settings);

          case AppRoutes.examFinish:
            final session = settings.arguments;
            return _buildRoute(
              ExamFinishScreen(
                session: session is ExamSession ? session : null,
              ),
              settings,
            );

          case AppRoutes.examResult:
            final session = settings.arguments;
            return _buildRoute(
              ExamResultScreen(
                session: session is ExamSession ? session : null,
                args: session is ExamResultArgs ? session : null,
              ),
              settings,
            );

          default:
            return _buildRoute(const AuthEntryPage(), settings);
        }
      },
    );
  }

  Route<dynamic> _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) {
        return page;
      },
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    );
  }
}
