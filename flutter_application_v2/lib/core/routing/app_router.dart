import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../screens/main_navigation_screen.dart';
import '../../screens/flights/flight_search_screen.dart';
import '../../screens/visa/visa_eligibility_screen.dart';
import '../../screens/holidays/holidays_list_screen.dart';
import '../../screens/hotels/hotel_enquiry_screen.dart';
import '../../features/notifications/presentation/screens/notification_center_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String home = '/home';
  static const String flights = '/flights';
  static const String visas = '/visas';
  static const String holidays = '/holidays';
  static const String hotels = '/hotels';
  static const String notifications = '/notifications';
  static const String admin = '/admin';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const MainNavigationScreen());
      case flights:
        return MaterialPageRoute(builder: (_) => const FlightSearchScreen());
      case visas:
        return MaterialPageRoute(builder: (_) => const VisaEligibilityScreen());
      case holidays:
        return MaterialPageRoute(builder: (_) => const HolidaysListScreen());
      case hotels:
        return MaterialPageRoute(builder: (_) => const HotelEnquiryScreen());
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationCenterScreen());
      case admin:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
