import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bushopper/features/user_auth/presentation/widgets/form_container_widget.dart';
import 'map_page.dart';

class SearchStopPage extends StatefulWidget {
  const SearchStopPage({super.key});

  @override
  State<SearchStopPage> createState() => _SearchStopPageState();
}

class _SearchStopPageState extends State<SearchStopPage> {
  final TextEditingController _searchController = TextEditingController();
  bool isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      isRefreshing = true;
      _searchController.clear(); // Clears search bar
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        isRefreshing = false; // Stops loading animation
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // Back button
        backgroundColor: Colors.yellow, // Yellow background like reference
        iconTheme: const IconThemeData(color: Colors.black), // Black back button
        title: const Text(
          "Search Bus Stop",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black, // Black text
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/splash');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Logged out successfully!")),
              );
            },
          ),
        ],
      ),
      body: FormContainerWidget(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: "Enter Stop Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {}); // Updates UI as user types
                },
              ),
              const SizedBox(height: 20),

              // Bus List
              Expanded(
                child: isRefreshing
                    ? const Center(child: CircularProgressIndicator())
                    : StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('buses').snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          var buses = snapshot.data!.docs.where((doc) {
                            List<dynamic> stopsList = doc['stopping_points'];
                            List<String> stops =
                                stopsList.map((e) => e.toString().toLowerCase()).toList();

                            return stops.any((stop) =>
                                stop.contains(_searchController.text.toLowerCase()));
                          }).toList();

                          if (buses.isEmpty) {
                            return const Center(
                              child: Text(
                                "No buses found for this stop",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            );
                          }

                          // Sort buses based on starting time
                          buses.sort((a, b) => a['time'].compareTo(b['time']));

                          return ListView.builder(
                            itemCount: buses.length,
                            itemBuilder: (context, index) {
                              var bus = buses[index];
                              var docId = bus.id;

                              return Card(
                                elevation: 3,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                color: Colors.white, // Clean UI
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.black, // Black circle for bus no
                                    child: Text(
                                      "${bus['bus_no']}",
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  title: Text(
                                    "Bus No: ${bus['bus_no']}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Starting Place: ${bus['starting_place']}",
                                        style: const TextStyle(fontSize: 12, color: Colors.black),
                                      ),
                                      Text(
                                        "Starting Time: ${bus['time']}",
                                        style: const TextStyle(fontSize: 12, color: Colors.black),
                                      ),
                                      Text(
                                        "Driver Contact: ${bus['driver_contact']}",
                                        style: const TextStyle(fontSize: 12, color: Colors.black),
                                      ),
                                      Text(
                                        "Total Stops: ${bus['stopping_points'].length}",
                                        style: const TextStyle(fontSize: 12, color: Colors.black),
                                      ),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MapPage(
                                          documentId: docId,
                                          busNumber: '${bus['bus_no']}',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
