import 'package:bushopper/features/user_auth/presentation/pages/WeekendPassPage.dart';
import 'package:bushopper/features/user_auth/presentation/pages/driver_location_updater.dart';
import 'package:bushopper/features/user_auth/presentation/widgets/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bushopper/features/app/splash_screen/splash_screen.dart';
import 'package:bushopper/features/user_auth/presentation/pages/driver_sign_up.dart';
import 'package:bushopper/features/user_auth/presentation/pages/login_page.dart';
import 'package:bushopper/features/user_auth/presentation/pages/search_page.dart';
import 'package:bushopper/features/user_auth/presentation/pages/staff_sign_up_page.dart';
import 'package:bushopper/features/user_auth/presentation/pages/student_sign_in.dart';
import 'package:bushopper/features/user_auth/presentation/pages/student_sign_up_page.dart';
import 'package:bushopper/features/user_auth/presentation/pages/driver_sign_in_page.dart';
import 'package:bushopper/features/user_auth/presentation/pages/staff_sign_in_page.dart';
import 'package:bushopper/features/user_auth/presentation/pages/verify_pass_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    /// ✅ Automatically start location tracking if the driver is logged in
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null && user.displayName == 'driver') {
        DriverLocationUpdater.startTracking();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BusHopper',
      theme: ThemeConfig.getAppTheme(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/splash':
            return MaterialPageRoute(
              builder: (context) => const SplashScreen(child: LoginPage()),
            );
          case '/studentLogin':
            return MaterialPageRoute(
              builder: (context) => StudentSignInPage(),
            );
          case '/studentSignUp':
            return MaterialPageRoute(
              builder: (context) => StudentSignUpPage(),
            );
          case '/driverLogin':
            return MaterialPageRoute(
              builder: (context) => DriverSignInPage(),
            );
          case '/driverSignUp':
            return MaterialPageRoute(
              builder: (context) => DriverSignUpPage(),
            );
          case '/staffLogin':
            return MaterialPageRoute(
              builder: (context) => StaffSignInPage(),
            );
          case '/staffSignUp':
            return MaterialPageRoute(
              builder: (context) => StaffSignUpPage(),
            );
          case '/searchStop':
            return MaterialPageRoute(
              builder: (context) => SearchStopPage(),
            );
          case '/weekendPass':
            // 🎟️ Navigate to Weekend Pass Page
            return MaterialPageRoute(
              builder: (context) => WeekendPassPage(
                userId: settings.arguments as String,
                 busNumber: 'r',
              ),
            );
          case '/verifyPass':
            // 🔎 Navigate to Verify Pass Page (for security)
            return MaterialPageRoute(
              builder: (context) => const VerifyPassPage(),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => const LoginPage(),
            );
        }
      },
    );
  }
}
