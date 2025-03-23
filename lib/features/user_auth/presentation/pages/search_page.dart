import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'map_page.dart';

class SearchStopPage extends StatefulWidget {
  const SearchStopPage({super.key});

  @override
  State<SearchStopPage> createState() => _SearchStopPageState();
}

class _SearchStopPageState extends State<SearchStopPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Bus Stop")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: "Enter Stop Name",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('buses').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Filtering buses based on the stop name
                  var buses = snapshot.data!.docs.where((doc) {
                    var stops = List<String>.from(doc['stopping_points'] ?? []);
                    return stops.any((stop) => stop.toLowerCase().contains(
                          _searchController.text.toLowerCase(),
                        ));
                  }).toList();

                  if (buses.isEmpty) {
                    return const Center(child: Text("No buses found for this stop"));
                  }

                  return ListView.builder(
                    itemCount: buses.length,
                    itemBuilder: (context, index) {
                      var bus = buses[index];
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text("Bus No: ${bus['bus_no']}",
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Starting Place: ${bus['starting_place']}"),
                              Text("Time: ${bus['time']}"),
                              Text("Driver Contact: ${bus['driver_contact']}"),
                            ],
                          ),
                          onTap: () {
                            // Navigate to Map Page with stopping points
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapPage(
                                  stops: List<String>.from(bus['stopping_points']),
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
    );
  }
}
