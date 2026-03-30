import 'package:cloud_firestore/cloud_firestore.dart';

class MosallaData {
  final String id;
  final String name;
  final String location;
  final double? latitude;
  final double? longitude;
  final String description;
  final String yearFounded;
  final String? logo;

  MosallaData({
    required this.id,
    required this.name,
    required this.location,
    this.latitude,
    this.longitude,
    required this.description,
    required this.yearFounded,
    this.logo,
  });

  factory MosallaData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return MosallaData(
        id: doc.id,
        name: 'Unknown Mosalla',
        location: '',
        description: '',
        yearFounded: '',
      );
    }

    return MosallaData(
      id: doc.id,
      name: data['name'] ?? 'Unknown Mosalla',
      location: data['location'] ?? '',
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      description: data['description'] ?? '',
      yearFounded: data['yearFounded']?.toString() ?? '',
      logo: data['logo'],
    );
  }

  bool get hasCoordinates => latitude != null && longitude != null;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'description': description,
      'yearFounded': yearFounded,
      if (logo != null) 'logo': logo,
    };
  }
}
