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
      appBar: AppBar(
        title: const Text("Verify Weekend Pass"),
        backgroundColor: Colors.green,
      ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                "Show Tickets",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            if (busNumber != null) _buildTicketList(busNumber!),
          ],
        ),
      ),
    );
  }

  // 📄 Build Ticket List
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

              if (ticket == null) {
                return const SizedBox.shrink();
              }

              return _buildTicketCard(ticket, tickets[index].id);
            },
          );
        },
      ),
    );
  }

  // 🎨 Ticket Card Design
  Widget _buildTicketCard(Map<String, dynamic> ticket, String passId) {
    String userType = ticket['role'] ?? 'student';
    bool isStaff = userType == 'staff';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow("Pass ID", ticket['pass_id'] ?? 'N/A'),
            _infoRow("Bus No", ticket['bus_no'] ?? 'N/A'),

            // 🎓 Student Info
            if (!isStaff) ...[
              _infoRow("Student ID", ticket['student_id'] ?? 'N/A'),
              _infoRow("Student Name", ticket['student_name'] ?? 'N/A'),
            ],

            // 🧑‍🏫 Staff Info
            if (isStaff) ...[
              _infoRow("Staff Name", ticket['staff_name'] ?? 'N/A'),
              _infoRow("Position", ticket['position'] ?? 'N/A'),
            ],

            _infoRow("From Date", _formatDate(ticket['from_date'] ?? '')),
            _infoRow("To Date", _formatDate(ticket['to_date'] ?? '')),

            const SizedBox(height: 12),

            // ✅ Verify & Remove Pass Button
            ElevatedButton(
              onPressed: () => _verifyAndDeletePass(passId),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                "Verify & Remove Pass",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ℹ️ Information Row Widget
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
          Flexible(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  // 📅 Date Formatter
  String _formatDate(String date) {
    if (date.isEmpty) return "N/A";
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd MMM yyyy').format(parsedDate);
    } catch (e) {
      return "Invalid Date";
    }
  }

  // 🚨 Verify & Delete Pass
  void _verifyAndDeletePass(String passId) async {
    try {
      await FirebaseFirestore.instance.collection('weekend_passes').doc(passId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pass verified and removed successfully! ✅")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting pass: ${e.toString()}")),
      );
    }
  }
}
