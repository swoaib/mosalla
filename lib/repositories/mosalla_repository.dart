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

  // Helpers for monthly documents
  String _getMonthId(String docId) => docId.substring(3); // e.g. "04-2026"
  String _getDayId(String docId) => docId.substring(0, 2); // e.g. "15"

  Stream<PrayerData> getPrayerTimesStream(String mosallaId, String docId) {
    final monthId = _getMonthId(docId);
    final dayId = _getDayId(docId);
    return _firestore
        .collection('mosalla/$mosallaId/prayer_months')
        .doc(monthId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return PrayerData(id: docId);
      final data = doc.data();
      if (data == null || data[dayId] == null) return PrayerData(id: docId);
      return PrayerData.fromMap(docId, data[dayId] as Map<String, dynamic>);
    });
  }

  Future<void> saveMosallaProfile(String id, Map<String, dynamic> data) async {
    await _firestore.collection('mosalla').doc(id).set(data, SetOptions(merge: true));
  }

  Future<void> createMosallaProfile(String id, Map<String, dynamic> data) async {
    await _firestore.collection('mosalla').doc(id).set(data);
  }

  Future<PrayerData?> getPrayerTime(String mosallaId, String docId) async {
    final monthId = _getMonthId(docId);
    final dayId = _getDayId(docId);
    final doc = await _firestore.collection('mosalla/$mosallaId/prayer_months').doc(monthId).get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null && data[dayId] != null && data[dayId] is Map) {
        return PrayerData.fromMap(docId, Map<String, dynamic>.from(data[dayId] as Map));
      }
    }
    return null;
  }

  Future<List<PrayerData>> getPrayerTimesByMonth(String mosallaId, String monthYear) async {
    final doc = await _firestore.collection('mosalla/$mosallaId/prayer_months').doc(monthYear).get();
    if (!doc.exists) return [];
    
    final data = doc.data();
    if (data == null) return [];
    
    final results = <PrayerData>[];
    data.forEach((dayKey, dayData) {
      if (dayData != null && dayData is Map) {
        results.add(PrayerData.fromMap('$dayKey-$monthYear', Map<String, dynamic>.from(dayData as Map)));
      }
    });

    results.sort((a, b) => a.id.compareTo(b.id));
    return results;
  }

  Future<void> savePrayerTime(String mosallaId, String docId, Map<String, dynamic> data) async {
    final monthId = _getMonthId(docId);
    final dayId = _getDayId(docId);
    await _firestore.collection('mosalla/$mosallaId/prayer_months').doc(monthId).set({dayId: data}, SetOptions(merge: true));
  }
  
  // Takes a map of docId -> Map of fields to update
  Future<void> bulkSavePrayerTimes(String mosallaId, Map<String, Map<String, dynamic>> updatesByDocId) async {
    final batch = _firestore.batch();
    
    final Map<String, Map<String, dynamic>> monthUpdates = {};
    
    updatesByDocId.forEach((docId, data) {
      final monthId = _getMonthId(docId);
      final dayId = _getDayId(docId);
      
      if (!monthUpdates.containsKey(monthId)) {
        monthUpdates[monthId] = {};
      }
      monthUpdates[monthId]![dayId] = data;
    });

    monthUpdates.forEach((monthId, data) {
      final docRef = _firestore.collection('mosalla/$mosallaId/prayer_months').doc(monthId);
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
