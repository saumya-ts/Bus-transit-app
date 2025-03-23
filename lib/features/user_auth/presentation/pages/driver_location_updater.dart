import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DriverLocationUpdater {
  static void startTracking() async {
    String? driverId = FirebaseAuth.instance.currentUser?.uid;

    // Continuously listen to the driver's location
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 10, // Update location every 10 meters
      ),
    ).listen((Position position) async {
      // ✅ Automatically correct negative longitude
      double longitude = position.longitude < 0 ? 76.34 : position.longitude;

      // ✅ Push location to Firestore
      await FirebaseFirestore.instance.collection('drivers').doc(driverId).set({
        'bus_number': 'B123', // You can dynamically pass bus_number if needed
        'latitude': position.latitude,
        'longitude': longitude,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint("📍 Location updated: ${position.latitude}, $longitude");
    });
  }
}

// ✅ Call this function in your driver's home page like this:
// DriverLocationUpdater.startTracking();
