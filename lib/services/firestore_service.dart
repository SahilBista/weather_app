import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/weather_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ================= User Profile Management =================
  Future<void> createUserProfile(User user) async {
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'name': user.displayName ?? 'Anonymous',
      'createdAt': FieldValue.serverTimestamp(),
      'authProvider': user.providerData.isNotEmpty
          ? user.providerData[0].providerId
          : 'email',
      'lastLogin': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUserLastLogin(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'lastLogin': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data();
  }

  // ================= Weather CRUD Operations =================
  Future<void> saveWeather(String userId, WeatherData weather) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('weather_history')
        .add({
          'city': weather.city,
          'temp': weather.temp,
          'description': weather.description,
          'timestamp': FieldValue.serverTimestamp(),
          'icon': _getWeatherIconCode(weather.description),
        });
  }

  Stream<List<Map<String, dynamic>>> getWeatherHistory(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('weather_history')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              ...data,
              'docId': doc.id, // Include document ID for updates/deletes
            };
          }).toList(),
        );
  }

  Future<void> updateWeatherRecord(
    String userId,
    String docId,
    Map<String, dynamic> updates,
  ) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('weather_history')
        .doc(docId)
        .update(updates);
  }

  Future<void> deleteWeatherRecord(String userId, String docId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('weather_history')
        .doc(docId)
        .delete();
  }

  // ================= Helper Methods =================
  String _getWeatherIconCode(String description) {
    if (description.contains('rain')) return 'rainy';
    if (description.contains('cloud')) return 'cloudy';
    if (description.contains('snow')) return 'ac_unit';
    return 'wb_sunny';
  }
}
