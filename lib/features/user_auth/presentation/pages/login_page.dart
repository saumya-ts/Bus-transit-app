import 'package:flutter/material.dart';
import 'package:bushopper/features/user_auth/presentation/widgets/form_container_widget.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Login As"),
        centerTitle: true,
      ),
      body: FormContainerWidget(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Login",
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/studentLogin');
                },
                child: const Text("Login as Student"),
              ),
              const SizedBox(height: 20),
              
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/driverLogin');
                },
                child: const Text("Login as Driver"),
              ),
              const SizedBox(height: 20),
              
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/staffLogin');
                },
                child: const Text("Login as Staff"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Let me know if you want me to tweak the design further or adjust the layout! 🚀
