import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class StudentSignUpPage extends StatefulWidget {
  const StudentSignUpPage({super.key});


  @override
  State<StudentSignUpPage> createState() => _StudentSignUpPageState();
}

class _StudentSignUpPageState extends State<StudentSignUpPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSigningUp = false;

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
    }
  }

  Future<void> _signUpStudent() async {
    setState(() => _isSigningUp = true);

    String studentId = _idController.text.trim();
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (studentId.isNotEmpty && name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        User? user = userCredential.user;
        if (user != null) {
          await FirebaseFirestore.instance.collection('students').doc(user.uid).set({
            'studentId': studentId,
            'name': name,
            'email': email,
            'role': 'student',
            'createdAt': Timestamp.now(),
          });

          await _requestLocationPermission(context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Student signed up and data stored in Firestore!")),
          );
          Navigator.pushNamed(context, "/searchStop");
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all fields")),
      );
    }

    setState(() => _isSigningUp = false);
  }

  Widget _buildTextField(TextEditingController controller, String label, TextInputType keyboardType, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      obscureText: isPassword,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Student Sign-Up")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Student Sign-Up",
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              _buildTextField(_idController, "Student ID", TextInputType.text),
              SizedBox(height: 20),
              _buildTextField(_nameController, "Student Name", TextInputType.text),
              SizedBox(height: 20),
              _buildTextField(_emailController, "Email", TextInputType.emailAddress),
              SizedBox(height: 20),
              _buildTextField(_passwordController, "Password", TextInputType.text, isPassword: true),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isSigningUp ? null : _signUpStudent,
                child: _isSigningUp
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Let me know if you want any adjustments or additional features! 🚀
