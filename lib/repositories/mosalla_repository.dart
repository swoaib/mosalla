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

  // Fetch only the specific days for a month (28-31 reads instead of entire collection)
  Future<List<PrayerData>> getPrayerTimesByMonth(String mosallaId, String monthYear) async {
    // monthYear format: "MM-yyyy"
    final parts = monthYear.split('-');
    final month = int.parse(parts[0]);
    final year = int.parse(parts[1]);
    final daysInMonth = DateTime(year, month + 1, 0).day;

    final futures = <Future<PrayerData?>>[];
    for (int day = 1; day <= daysInMonth; day++) {
      final docId = '${day.toString().padLeft(2, '0')}-$monthYear';
      futures.add(getPrayerTime(mosallaId, docId));
    }

    final results = await Future.wait(futures);
    return results.whereType<PrayerData>().toList();
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
