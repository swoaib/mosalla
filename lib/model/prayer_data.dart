import 'package:cloud_firestore/cloud_firestore.dart';

class PrayerData {
  final String id;
  final DateTime? fajr;
  final DateTime? fajrJamaat;
  final DateTime? duhr;
  final DateTime? duhrJamaat;
  final DateTime? asr;
  final DateTime? asrJamaat;
  final DateTime? maghrib;
  final DateTime? maghribJamaat;
  final DateTime? isha;
  final DateTime? ishaJamaat;
  final DateTime? jumma;
  final String? date;
  DateTime? sunrise;

  PrayerData({
    required this.id,
    this.fajr,
    this.fajrJamaat,
    this.duhr,
    this.duhrJamaat,
    this.asr,
    this.asrJamaat,
    this.maghrib,
    this.maghribJamaat,
    this.isha,
    this.ishaJamaat,
    this.jumma,
    this.date,
    this.sunrise,
  });

  factory PrayerData.fromMap(String docId, Map<String, dynamic>? data) {
    if (data == null) {
      return PrayerData(id: docId);
    }
    
    final Timestamp? fajr = data['Fajr'];
    final Timestamp? fajrJamaat = data['FajrJamaat'];
    final Timestamp? duhr = data['Duhr'];
    final Timestamp? duhrJamaat = data['DuhrJamaat'];
    final Timestamp? asr = data['Asr'];
    final Timestamp? asrJamaat = data['AsrJamaat'];
    final Timestamp? maghrib = data['Maghrib'];
    final Timestamp? maghribJamaat = data['MaghribJamaat'];
    final Timestamp? isha = data['Isha'];
    final Timestamp? ishaJamaat = data['IshaJamaat'];
    final Timestamp? jumma = data['Jumma'];
    final Timestamp? sunrise = data['Sunrise'];
    final String? date = data['Date'] ?? docId;

    return PrayerData(
      id: docId,
      fajr: fajr?.toDate(),
      fajrJamaat: fajrJamaat?.toDate(),
      sunrise: sunrise?.toDate(),
      duhr: duhr?.toDate(),
      duhrJamaat: duhrJamaat?.toDate(),
      asr: asr?.toDate(),
      asrJamaat: asrJamaat?.toDate(),
      maghrib: maghrib?.toDate(),
      maghribJamaat: maghribJamaat?.toDate(),
      isha: isha?.toDate(),
      ishaJamaat: ishaJamaat?.toDate(),
      jumma: jumma?.toDate(),
      date: date,
    );
  }

  factory PrayerData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return PrayerData.fromMap(doc.id, data);
  }
}
