import 'package:field_survey/screens/auth/login.dart';
import 'package:field_survey/screens/auth/register.dart';
import 'package:field_survey/screens/dashboard/dashboard.dart';
import 'package:field_survey/screens/profile/profile.dart';
import 'package:field_survey/screens/profile/edit_profile.dart';
import 'package:field_survey/screens/survey/DaftarSurvey.dart';
import 'package:field_survey/screens/survey/SurveyForm.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import 'app_routes.dart';

class AppPages {
  static final router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => SplashScreen(),
      ),
      GoRoute(path: AppRoutes.login, builder: (context, state) => LoginPage()),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => DashboardPage(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => ProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.edit_profile,
        builder: (context, state) => EditProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.surveyForm,
        builder: (context, state) => SurveyFormPage(),
      ),
      GoRoute(
        path: AppRoutes.surveyDaftar,
        builder: (context, state) => SurveyPage(),
      ),
    ],
  );
}
