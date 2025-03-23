import 'package:flutter/material.dart';

class FormContainerWidget extends StatelessWidget {
  final Widget child;

  const FormContainerWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.yellow, Color.fromARGB(255, 255, 235, 59)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: child,
        ),
      ),
    );
  }
}

// Let me know if you want me to tweak anything else! 🚀
