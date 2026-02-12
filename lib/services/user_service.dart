import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  // Singleton pattern
  static final UserService _instance = UserService._internal();
  static UserService get instance => _instance;

  UserService._internal();

  // Cached user data
  Map<String, dynamic>? _userData;

  Map<String, dynamic>? get currentUserData => _userData;

  /// Fetches user data from Firestore and caches it.
  /// Should be called on Login.
  Future<void> fetchUserData(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        _userData = doc.data();
      } else {
        _userData = null;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      rethrow;
    }
  }

  /// Updates specific fields in Firestore and updates the local cache.
  Future<void> updateHealthProfile(
    String uid,
    Map<String, dynamic> healthProfileData,
  ) async {
    try {
      // 1. Update Firestore
      // We assume healthProfileData keys are like 'health_profile.is_diabetic' if using dot notation
      // or we construct the map.
      // To keep it simple and safe, let's update the specific nested Map locally and send it.

      // However, Firestore update with dot notation is cleaner for partial updates.
      // But we need to update local _userData as well.

      // Let's expect the full 'health_profile' map or partial map to merge.
      // For this app's use case in UserConfigScreen, we are updating the whole 'health_profile' object or parts of it.

      // Let's support passing the new health_profile map directly.
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'health_profile': healthProfileData,
      });

      // 2. Update Local Cache
      if (_userData != null) {
        _userData!['health_profile'] = healthProfileData;
      }
    } catch (e) {
      print('Error updating user data: $e');
      rethrow;
    }
  }

  /// Clears cached data. Call on Logout.
  void clear() {
    _userData = null;
  }
}
