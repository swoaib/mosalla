import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/mosalla_data.dart';
import '../model/prayer_data.dart';

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
}
