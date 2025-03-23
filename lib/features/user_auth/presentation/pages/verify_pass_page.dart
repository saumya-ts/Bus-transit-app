import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class VerifyPassPage extends StatefulWidget {
  const VerifyPassPage({super.key});

  @override
  State<VerifyPassPage> createState() => _VerifyPassPageState();
}

class _VerifyPassPageState extends State<VerifyPassPage> {
  final TextEditingController _busNoController = TextEditingController();
  String? busNumber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Weekend Pass")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _busNoController,
              decoration: const InputDecoration(
                labelText: "Enter Bus Number",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  busNumber = _busNoController.text.trim();
                });
              },
              child: const Text("Show Tickets"),
            ),
            const SizedBox(height: 20),
            if (busNumber != null) _buildTicketList(busNumber!),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketList(String busNumber) {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('weekend_passes')
            .where('bus_no', isEqualTo: busNumber)
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
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow("Pass ID", ticket['pass_id'] ?? 'N/A'),
                      _infoRow("Bus No", ticket['bus_no'] ?? 'N/A'),
                      _infoRow("Student ID", ticket['student_id'] ?? 'N/A'),
                      _infoRow("Student Name", ticket['student_name'] ?? 'N/A'),
                      _infoRow("From Date", _formatDate(ticket['from_date'] ?? '')),
                      _infoRow("To Date", _formatDate(ticket['to_date'] ?? '')),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => _verifyAndDeletePass(tickets[index].id),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text("Verify & Remove Pass"),
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

  void _verifyAndDeletePass(String passId) {
    FirebaseFirestore.instance.collection('weekend_passes').doc(passId).delete();
  }
}
