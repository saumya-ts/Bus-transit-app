import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:bushopper/features/user_auth/presentation/widgets/form_container_widget.dart';

class StudentAuthPage extends StatelessWidget {
  const StudentAuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              Future.microtask(() => Navigator.pushReplacementNamed(context, "/searchStop"));
              return const SizedBox();
            } else {
              return StudentSignInPage();
            }
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class StudentSignInPage extends StatefulWidget {
  const StudentSignInPage({super.key});

  @override
  _StudentSignInPageState createState() => _StudentSignInPageState();
}

class _StudentSignInPageState extends State<StudentSignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _requestLocationPermission(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar(context, "Location services are disabled. Please enable them.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar(context, "Location permission denied. Cannot proceed.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackBar(context, "Location permission permanently denied. Enable it in settings.");
    }
  }

  void _signIn(BuildContext context) async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar(context, "Please fill in all fields.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection('students')
          .doc(userCredential.user!.uid)
          .get();

      if (studentDoc.exists && studentDoc['role'] == 'student') {
        await _requestLocationPermission(context);
        _showSnackBar(context, "Login successful!");
        Navigator.pushNamed(context, "/searchStop");
      } else {
        FirebaseAuth.instance.signOut();
        _showSnackBar(context, "Access denied: You are not registered as a student.");
      }
    } catch (e) {
      _showSnackBar(context, "Sign-in failed: $e");
    }

    setState(() => _isLoading = false);
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Sign-In")),
      body: FormContainerWidget(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Student Sign-In",
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () => _signIn(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.yellow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                      ),
                      child: const Text("Sign In", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, "/studentSignUp"),
                child: const Text("Don't have an account? Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Let me know if you want me to tweak anything else! 🚀
