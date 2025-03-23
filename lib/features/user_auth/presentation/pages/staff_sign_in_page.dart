import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:bushopper/features/user_auth/presentation/widgets/form_container_widget.dart';

class StaffAuthPage extends StatelessWidget {
  const StaffAuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              Future.microtask(() => Navigator.pushReplacementNamed(context, "/searchStop"));
              return SizedBox();
            } else {
              return StaffSignInPage();
            }
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class StaffSignInPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  StaffSignInPage({super.key});

  Future<void> _requestLocationPermission(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location services are disabled. Please enable them.")),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location permission denied. Cannot proceed.")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location permission permanently denied. Enable it in settings.")),
      );
      return;
    }
  }

  void _signIn(BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      DocumentSnapshot staffDoc = await FirebaseFirestore.instance
          .collection('staff') 
          .doc(userCredential.user!.uid)
          .get();

      if (staffDoc.exists && staffDoc['role'] == 'staff') {
        await _requestLocationPermission(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login successful as Staff!")),
        );
        Navigator.pushReplacementNamed(context, "/searchStop");
      } else {
        FirebaseAuth.instance.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Access denied: You are not registered as staff.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign-in failed: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Staff Sign-In")),
      body: FormContainerWidget(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Staff Sign-In",
                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 30),
                
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 20),
                
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 30),
                
                ElevatedButton(
                  onPressed: () => _signIn(context),
                  child: Text("Sign In"),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, "/staffSignUp"),
                  child: Text("Don't have an account? Sign Up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Let me know if you need any adjustments! 🚀
