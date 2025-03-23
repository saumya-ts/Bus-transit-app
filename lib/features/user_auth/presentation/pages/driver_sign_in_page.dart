import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'dart:async';
import 'package:bushopper/features/user_auth/presentation/widgets/form_container_widget.dart';

class DriverSignInPage extends StatefulWidget {
  const DriverSignInPage({super.key});

  @override
  _DriverSignInPageState createState() => _DriverSignInPageState();
}

class _DriverSignInPageState extends State<DriverSignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  StreamSubscription<Position>? _positionStream;

  void _signIn(BuildContext context) async {
    await _ensureLocationIsOn(context);

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      DocumentSnapshot driverDoc = await FirebaseFirestore.instance
          .collection('drivers')
          .doc(userCredential.user!.uid)
          .get();

      if (driverDoc.exists && driverDoc['role'] == 'driver') {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login successful as Driver!")),
        );
        Navigator.pushReplacementNamed(context, "/searchStop");
        _startLocationUpdates(userCredential.user!.uid);
      } else if (!driverDoc.exists) {
        // Automatically create driver doc if not exists
        await FirebaseFirestore.instance.collection('drivers').doc(userCredential.user!.uid).set({
          'role': 'driver',
          'latitude': 0.0,
          'longitude': 0.0,
          'timestamp': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login successful. Document created.")),
        );
        Navigator.pushReplacementNamed(context, "/driver_page");
        _startLocationUpdates(userCredential.user!.uid);
      } else {
        FirebaseAuth.instance.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Access denied: You are not registered as a driver.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign-in failed: \${e.toString()}")),
      );
    }
  }

  Future<void> _ensureLocationIsOn(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      final intent = AndroidIntent(
        action: 'android.settings.LOCATION_SOURCE_SETTINGS',
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Turning on location. Please wait...")),
      );
      await Future.delayed(Duration(seconds: 5));
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission denied. Cannot proceed.")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission permanently denied. Enable it in settings.")),
      );
      return;
    }
  }

  void _startLocationUpdates(String uid) {
    _positionStream = Geolocator.getPositionStream().listen((Position position) {
      FirebaseFirestore.instance.collection('drivers').doc(uid).update({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Driver Sign-In")),
      body: FormContainerWidget(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Driver Sign-In",
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
                  onPressed: () => Navigator.pushNamed(context, "/driverSignUp"),
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
