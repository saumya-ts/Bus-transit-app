import 'dart:math';
import 'package:bushopper/features/user_auth/presentation/pages/ticketpage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WeekendPassPage extends StatefulWidget {
  final String busNumber;
  final String userId;

  const WeekendPassPage({
    required this.busNumber,
    required this.userId,
    super.key,
  });

  @override
  State<WeekendPassPage> createState() => _WeekendPassPageState();
}

class _WeekendPassPageState extends State<WeekendPassPage> {
  final _formKey = GlobalKey<FormState>();
  String? userType; // student or staff
  String? studentId;
  String? phoneNumber;
  DateTime? fromDate;
  DateTime? toDate;
  String? passId;
  bool isLoading = false;
  String? studentName;
  String? staffName;

  @override
  void initState() {
    super.initState();
    _getUserType(); // ✅ Get User Type at Start
  }

  // ✅ Get User Type (student or staff)
  Future<void> _getUserType() async {
    var studentDoc = await FirebaseFirestore.instance
        .collection('students')
        .doc(widget.userId)
        .get();

    if (studentDoc.exists) {
      setState(() {
        userType = studentDoc['role'] ?? 'student';
        studentId = studentDoc['studentId'] ?? '';
        studentName = studentDoc['name'] ?? 'N/A';
      });
      return;
    }

    var staffDoc = await FirebaseFirestore.instance
        .collection('staff')
        .doc(widget.userId)
        .get();

    if (staffDoc.exists) {
      setState(() {
        userType = staffDoc['role'] ?? 'staff';
        phoneNumber = staffDoc['phone_number'] ?? '';
        staffName = staffDoc['name'] ?? 'N/A';
      });
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("User not found in students or staff.")),
    );
  }

  // 🎲 Generate Unique Pass ID
  String _generatePassId() {
    String datePart =
        "${toDate!.day.toString().padLeft(2, '0')}${toDate!.month.toString().padLeft(2, '0')}";
    String randomPart = Random().nextInt(999).toString().padLeft(3, '0');
    return "$datePart$randomPart";
  }

  // 📅 Show Date Picker
  Future<void> _pickDate(BuildContext context, bool isFromDate) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isFromDate) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  // 💳 Handle Payment & Booking
  Future<void> _handlePaymentAndBooking() async {
    if (!_formKey.currentState!.validate()) return;

    if (fromDate == null || toDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select both from and to dates.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // ✅ Generate Pass ID
      passId = _generatePassId();

      var passData = {
        'bus_no': widget.busNumber,
        'user_id': widget.userId,
        'pass_id': passId,
        'role': userType,
        'from_date': fromDate!.toIso8601String(),
        'to_date': toDate!.toIso8601String(),
        'student_id': studentId ?? '',
        'student_name': studentName ?? '',
        'staff_name': staffName ?? '',
        'phone_number': phoneNumber ?? '',
        'amount_paid': 150,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // ✅ Store Pass Data in Firestore
      await FirebaseFirestore.instance.collection('weekend_passes').add(passData);

      // 🎉 Show Success Message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pass booked successfully! 🎟️")),
      );

      // ✅ Navigate to "My Tickets" after booking
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MyTicketsPage(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to book pass: ${e.toString()}")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Weekend Pass"),
        backgroundColor: Colors.green,
        actions: [
          // 🎟️ "My Tickets" Icon at Top Right
          IconButton(
            icon: const Icon(Icons.receipt_long, color: Colors.white),
            tooltip: 'View My Tickets',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyTicketsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🎓 Student Form
                if (userType == 'student') ...[
                  const Text(
                    "Student ID",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: studentId,
                    readOnly: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Student ID",
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: studentName,
                    readOnly: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Student Name",
                    ),
                  ),
                ],
                // 🧑‍🏫 Staff Form
                if (userType == 'staff') ...[
                  const Text(
                    "Phone Number",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: phoneNumber,
                    readOnly: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Phone Number",
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: staffName,
                    readOnly: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Staff Name",
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // 📅 From Date
                ListTile(
                  title: Text(
                    fromDate == null
                        ? "Select From Date"
                        : "From Date: ${fromDate!.toLocal()}".split(' ')[0],
                  ),
                  trailing: const Icon(Icons.calendar_today, color: Colors.blue),
                  onTap: () => _pickDate(context, true),
                ),

                // 📅 To Date
                ListTile(
                  title: Text(
                    toDate == null
                        ? "Select To Date"
                        : "To Date: ${toDate!.toLocal()}".split(' ')[0],
                  ),
                  trailing: const Icon(Icons.calendar_today, color: Colors.blue),
                  onTap: () => _pickDate(context, false),
                ),

                const SizedBox(height: 24),

                // 💳 Fixed Payment Section
                const Text(
                  "Amount to Pay: ₹150",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 24),

                // 🚀 Pay and Confirm Button
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handlePaymentAndBooking,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            "Pay ₹150 and Confirm",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
