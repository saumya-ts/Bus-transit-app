import 'package:flutter/material.dart';

class ThemeConfig {
  static ThemeData getAppTheme() {
    return ThemeData(
      primaryColor: Colors.yellow,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.yellow,
        titleTextStyle: TextStyle(
          color: Colors.black, 
          fontWeight: FontWeight.bold, 
          fontSize: 20,
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.yellow,
        foregroundColor: Colors.black,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.yellow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.yellow.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.yellow.shade700, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        labelStyle: TextStyle(color: Colors.black, fontSize: 16),
        prefixIconColor: Colors.black,
      ),
      iconTheme: IconThemeData(color: Colors.black),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        bodyMedium: TextStyle(color: Colors.black, fontSize: 16),
        labelSmall: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 14),
      ),
    );
  }
}

// Updated to make the login page fields and text more polished! Let me know if you want more adjustments 🚀
