import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:bushopper/features/user_auth/presentation/widgets/form_container_widget.dart';

class DriverSignUpPage extends StatefulWidget {
  const DriverSignUpPage({super.key});

  @override
  _DriverSignUpPageState createState() => _DriverSignUpPageState();
}

class _DriverSignUpPageState extends State<DriverSignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _busNumberController = TextEditingController();

  bool _isLoading = false;

  void _signUp(BuildContext context) async {
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _busNumberController.text.isEmpty) {
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

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      await FirebaseFirestore.instance.collection('drivers').doc(userCredential.user!.uid).set({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'bus_number': _busNumberController.text.trim(),
        'email': _emailController.text.trim(),
        'role': 'driver',
        'latitude': position.latitude,
        'longitude': position.longitude,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Driver account created successfully!")),
      );
      Navigator.pushReplacementNamed(context, "/searchStop");
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
      appBar: AppBar(title: Text("Driver Sign-Up")),
      body: FormContainerWidget(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Create a Driver Account",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: "Name", border: OutlineInputBorder()),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: "Phone", border: OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _busNumberController,
                  decoration: InputDecoration(labelText: "Bus Number", border: OutlineInputBorder()),
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
                SizedBox(height: 30),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () => _signUp(context),
                        child: Text("Sign Up"),
                      ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, "/driverLogin"),
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
