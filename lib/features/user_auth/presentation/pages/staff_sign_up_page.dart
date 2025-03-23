import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:bushopper/features/user_auth/presentation/widgets/form_container_widget.dart';

class StaffSignUpPage extends StatefulWidget {
  const StaffSignUpPage({super.key});

  @override
  _StaffSignUpPageState createState() => _StaffSignUpPageState();
}

class _StaffSignUpPageState extends State<StaffSignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();

  bool _isLoading = false;

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

    Navigator.pushReplacementNamed(context, "/searchStop");
  }

  void _signUp(BuildContext context) async {
    if (_nameController.text.isEmpty ||
        _positionController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password must be at least 6 characters")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await FirebaseFirestore.instance.collection('staff').doc(userCredential.user!.uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'position': _positionController.text.trim(),
        'role': 'staff',
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Staff account created successfully!")),
      );

      await _requestLocationPermission(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign-up failed: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Staff Sign-Up")),
      body: FormContainerWidget(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Create a Staff Account",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: "Name", border: OutlineInputBorder()),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _positionController,
                  decoration: InputDecoration(labelText: "Position", border: OutlineInputBorder()),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: "Email", border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: "Password", border: OutlineInputBorder()),
                  obscureText: true,
                ),
                SizedBox(height: 10),
                Text(
                  "Password must be at least 6 characters",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () => _signUp(context),
                        child: Text("Sign Up"),
                      ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, "/staffLogin"),
                  child: Text("Already have an account? Sign In"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Let me know if you want any changes! 🚀
