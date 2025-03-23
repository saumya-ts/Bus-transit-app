import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register Student
  Future<String?> registerStudent({
    required String studentId,
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      // Save student details in Firestore
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'studentId': studentId,
          'name': name,
          'email': email,
          'role': 'student',
          'createdAt': Timestamp.now(),
        });

        return user.uid;
      }
    } catch (e) {
      print("Error registering student: $e");
      return null;
    }
    return null;
  }
}
