import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MyTicketsPage extends StatefulWidget {
  const MyTicketsPage({super.key});

  @override
  State<MyTicketsPage> createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Tickets 🎟️"),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('weekend_passes')
            .where('user_id', isEqualTo: userId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No tickets found!",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          var tickets = snapshot.data!.docs;

          return ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              var ticket = tickets[index].data() as Map<String, dynamic>?;
              if (ticket == null) return const SizedBox.shrink();

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (ticket['role'] == 'student' && (ticket['student_id'] ?? '').isNotEmpty) ...[
                        _infoRow("Student ID", ticket['student_id'] ?? 'N/A'),
                        _infoRow("Student Name", ticket['student_name'] ?? 'N/A'),
                      ],
                      _infoRow("Pass ID", ticket['pass_id'] ?? 'N/A'),
                      _infoRow("Bus No", ticket['bus_no'] ?? 'N/A'),
                      _infoRow("From Date", _formatDate(ticket['from_date'] ?? '')),
                      _infoRow("To Date", _formatDate(ticket['to_date'] ?? '')),
                      _infoRow("Amount Paid", "₹150"),
                      const SizedBox(height: 8),
                      _statusIndicator(ticket['from_date'] ?? '', ticket['to_date'] ?? ''),
                      validityCountdown(ticket['from_date'] ?? '', ticket['to_date'] ?? ''),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text(
                          "Cancel Pass",
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () => _confirmDeletePass(tickets[index].id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    if (date.isEmpty) return "N/A";
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd MMM yyyy').format(parsedDate);
    } catch (e) {
      return "Invalid Date";
    }
  }

  Widget _statusIndicator(String fromDate, String toDate) {
    DateTime now = DateTime.now();
    DateTime from = DateTime.parse(fromDate);
    DateTime to = DateTime.parse(toDate);

    if (now.isBefore(from)) {
      return const Text("Pass Not Active", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold));
    } else if (now.isAfter(to)) {
      return const Text("Pass Expired", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold));
    } else {
      return const Text("Pass Active", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold));
    }
  }

  Widget validityCountdown(String fromDate, String toDate) {
    DateTime now = DateTime.now();
    DateTime to = DateTime.parse(toDate);

    if (now.isAfter(to)) {
      return const Text("Validity: Expired", style: TextStyle(color: Colors.red));
    } else {
      int daysLeft = to.difference(now).inDays;
      return Text("Validity: $daysLeft days left", style: const TextStyle(color: Colors.blue));
    }
  }

  void _confirmDeletePass(String passId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Cancel Pass"),
          content: const Text("Are you sure you want to cancel this pass?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                _deletePass(passId);
                Navigator.pop(context);
              },
              child: const Text("Yes", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deletePass(String passId) {
    FirebaseFirestore.instance.collection('weekend_passes').doc(passId).delete();
  }
}