import 'package:bushopper/features/app/splash_screen/splash_screen.dart';
import 'package:bushopper/features/user_auth/presentation/pages/login_page.dart';
import 'package:bushopper/features/user_auth/presentation/pages/search_page.dart';
import 'package:bushopper/features/user_auth/presentation/pages/staff_sign_up_page.dart';
import 'package:bushopper/features/user_auth/presentation/pages/student_sign_in.dart';
import 'package:bushopper/features/user_auth/presentation/pages/student_sign_up_page.dart';
import 'package:bushopper/features/user_auth/presentation/pages/driver_sign_in_page.dart';
import 'package:bushopper/features/user_auth/presentation/pages/staff_sign_in_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BusHopper',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
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
              builder: (context) => DriverLoginPage(),
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
          default:
            return MaterialPageRoute(
              builder: (context) => SearchStopPage(),
            );
        }
      },
    );
  }
}
