import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileService {
  static Future<bool> ensureProfile(User user) async {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);

      if (!userSnapshot.exists) {
        transaction.set(userRef, {
          'email': user.email,
          'displayName': user.displayName,
          'createdAt': FieldValue.serverTimestamp(),
        });

        return false;
      }

      final role = userSnapshot.data()?['role'];
      return role == 'admin';
    });
  }
}
