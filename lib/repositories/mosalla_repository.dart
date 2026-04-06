import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/mosalla_data.dart';
import '../model/prayer_data.dart';
import '../model/event.dart';

class MosallaRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<MosallaData>> getMosallasStream() {
    return _firestore
        .collection('mosalla')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => MosallaData.fromFirestore(doc)).toList());
  }

  Stream<PrayerData> getPrayerTimesStream(String mosallaId, String docId) {
    return _firestore
        .collection('mosalla/$mosallaId/prayer_times')
        .doc(docId)
        .snapshots()
        .map((doc) => PrayerData.fromFirestore(doc));
  }

  Future<void> saveMosallaProfile(String id, Map<String, dynamic> data) async {
    await _firestore.collection('mosalla').doc(id).set(data, SetOptions(merge: true));
  }

  Future<void> createMosallaProfile(String id, Map<String, dynamic> data) async {
    await _firestore.collection('mosalla').doc(id).set(data);
  }

  Future<PrayerData?> getPrayerTime(String mosallaId, String docId) async {
    final doc = await _firestore.collection('mosalla/$mosallaId/prayer_times').doc(docId).get();
    if (doc.exists) {
      return PrayerData.fromFirestore(doc);
    }
    return null;
  }

  // Optimized: Get multiple days for a month in one request
  Future<List<PrayerData>> getPrayerTimesByMonth(String mosallaId, String monthYear) async {
    // Current schema uses docId "dd-MM-yyyy". 
    // Since we can't query by substring on docId in a simple Firestore query,
    // we fetch the collection. For 1-2 years of data (~365-730 docs), this is fast.
    final snapshot = await _firestore.collection('mosalla/$mosallaId/prayer_times').get();
    return snapshot.docs
        .where((doc) => doc.id.contains(monthYear))
        .map((doc) => PrayerData.fromFirestore(doc))
        .toList();
  }

  Future<void> savePrayerTime(String mosallaId, String docId, Map<String, dynamic> data) async {
    await _firestore.collection('mosalla/$mosallaId/prayer_times').doc(docId).set(data, SetOptions(merge: true));
  }
  
  // Takes a map of docId -> Map of fields to update
  Future<void> bulkSavePrayerTimes(String mosallaId, Map<String, Map<String, dynamic>> updatesByDocId) async {
    final batch = _firestore.batch();
    
    updatesByDocId.forEach((docId, data) {
      final docRef = _firestore.collection('mosalla/$mosallaId/prayer_times').doc(docId);
      batch.set(docRef, data, SetOptions(merge: true));
    });

    await batch.commit();
  }

  // Events
  Stream<List<Event>> getEventsStream(String mosallaId) {
    return _firestore
        .collection('mosalla/$mosallaId/events')
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList());
  }

  Future<void> saveEvent(String mosallaId, Event event) async {
    if (event.id.isEmpty) {
      await _firestore.collection('mosalla/$mosallaId/events').add(event.toFirestore());
    } else {
      await _firestore.collection('mosalla/$mosallaId/events').doc(event.id).set(event.toFirestore(), SetOptions(merge: true));
    }
  }

  Future<void> deleteEvent(String mosallaId, String eventId) async {
    await _firestore.collection('mosalla/$mosallaId/events').doc(eventId).delete();
  }
}
