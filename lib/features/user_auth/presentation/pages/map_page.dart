import 'package:bushopper/features/user_auth/presentation/pages/WeekendPassPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:bushopper/features/user_auth/presentation/widgets/form_container_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MapPage extends StatefulWidget {
  final String documentId;
  final String busNumber;

  const MapPage({
    required this.documentId,
    required this.busNumber,
    super.key,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List<Map<String, dynamic>> stops = [];
  String? busNo;
  int currentStopIndex = 0;
  bool isEvening = false;
  bool routeReversed = false;
  bool isSecurity = false;
  bool isDriver = false;
  bool isStudentOrStaff = false; // ✅ Track if user is a student or staff

  @override
  void initState() {
    super.initState();
    _checkUserRole(); // ✅ Check user role (Student, Staff, Driver, Security)
    _fetchBusRoute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          busNo == null ? 'Loading Bus Route...' : 'Bus No: $busNo Route',
        ),
        actions: [
          if (isSecurity)
            Tooltip(
              message: 'Verify Passes',
              child: IconButton(
                icon: const FaIcon(FontAwesomeIcons.shieldAlt, color: Colors.blue, size: 26),
                onPressed: () {
                  Navigator.pushNamed(context, '/verifyPass');
                },
              ),
            ),
        ],
      ),
      body: FormContainerWidget(
        child: stops.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: stops.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            ListTile(
                              leading: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    index == currentStopIndex ? Icons.directions_bus : Icons.circle,
                                    color: _getStopColor(index),
                                  ),
                                  if (index != stops.length - 1)
                                    Container(
                                      height: 30,
                                      width: 2,
                                      color: Colors.grey,
                                    ),
                                ],
                              ),
                              title: Text(
                                stops[index]['place_name'],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: index == currentStopIndex
                                  ? const Text("Bus is here", style: TextStyle(color: Colors.blue))
                                  : null,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  // ✅ Show "Book Pass" button ONLY for students & staff
                  if (isStudentOrStaff)
                    ElevatedButton(
                      onPressed: _bookBusPass,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      ),
                      child: const Text(
                        "Book Pass",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
      ),
    );
  }

  Color _getStopColor(int index) {
    if (index == 0) return Colors.green;
    if (index == stops.length - 1) return Colors.red;
    return index == currentStopIndex ? Colors.orange : Colors.grey;
  }

  Future<void> _fetchBusRoute() async {
    try {
      var busDoc = await FirebaseFirestore.instance.collection('buses').doc(widget.documentId).get();

      if (busDoc.exists) {
        var busData = busDoc.data();
        busNo = busData?['bus_no'].toString();
        var rawStops = busData?['stopping_points'];

        if (rawStops != null && rawStops.isNotEmpty) {
          if (rawStops is List<dynamic>) {
            if (rawStops.first is String) {
              stops = rawStops.map((place) => {'place_name': place, 'latitude': 0.0, 'longitude': 0.0}).toList();
            } else {
              stops = rawStops.where((stop) => stop != null).map((stop) => {
                'place_name': stop['place_name'].toString(),
                'latitude': double.parse(stop['latitude'].toString()),
                'longitude': double.parse(stop['longitude'].toString()),
              }).toList();
            }
          }
        }

        if (_isEveningTime() && !routeReversed) {
          setState(() {
            stops = stops.reversed.toList();
            routeReversed = true;
          });
        }

        setState(() {
          currentStopIndex = 0;
        });

        _trackBusLocation();
      } else {
        setState(() {
          stops = [{'place_name': 'No stops found or invalid data'}];
        });
      }
    } catch (e) {
      setState(() {
        stops = [{'place_name': 'No stops found or invalid data'}];
      });
    }
  }

  bool _isEveningTime() {
    var now = DateTime.now();
    return now.hour >= 12;
  }

  void _trackBusLocation() {
    FirebaseFirestore.instance.collection('drivers').where('bus_number', isEqualTo: busNo).snapshots().listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        var driverDoc = snapshot.docs.first;
        double? driverLat = driverDoc['latitude'];
        double? driverLong = driverDoc['longitude'];

        if (driverLat != null && driverLong != null) {
          int nearestIndex = _findNearestStop(driverLat, driverLong);
          double distance = _calculateDistance(driverLat, driverLong, nearestIndex);

          if (nearestIndex != -1 && distance <= 500) {
            setState(() {
              currentStopIndex = nearestIndex;
            });
          } else {
            setState(() {
              currentStopIndex = -1;
            });
          }
        }
      } else {
        setState(() {
          currentStopIndex = 0;
        });
      }
    });
  }

  int _findNearestStop(double lat, double long) {
    double minDistance = double.infinity;
    int nearestIndex = -1;

    for (int i = 0; i < stops.length; i++) {
      double distance = _calculateDistance(lat, long, i);
      if (distance < minDistance) {
        minDistance = distance;
        nearestIndex = i;
      }
    }
    return nearestIndex;
  }

  double _calculateDistance(double lat, double long, int index) {
    var stop = stops[index];
    double lat2 = stop['latitude'];
    double long2 = stop['longitude'];
    return Geolocator.distanceBetween(lat, long, lat2, long2);
  }

  Future<void> _checkUserRole() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      var studentDoc = await FirebaseFirestore.instance.collection('students').doc(currentUser.uid).get();
      var staffDoc = await FirebaseFirestore.instance.collection('staff').doc(currentUser.uid).get();
      var driverDoc = await FirebaseFirestore.instance.collection('drivers').doc(currentUser.uid).get();

      if (studentDoc.exists || staffDoc.exists) {
        setState(() {
          isStudentOrStaff = true;
        });
      }

      if (staffDoc.exists && staffDoc['position'].toString().toLowerCase() == 'security') {
        setState(() {
          isSecurity = true;
        });
      }

      if (driverDoc.exists) {
        setState(() {
          isDriver = true;
        });
      }
    }
  }

  void _bookBusPass() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WeekendPassPage(
          busNumber: busNo ?? "Unknown Bus",
          userId: FirebaseAuth.instance.currentUser!.uid,
        ),
      ),
    );
  }
}
