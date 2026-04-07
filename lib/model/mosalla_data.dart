import 'package:cloud_firestore/cloud_firestore.dart';

class MosallaData {
  final String id;
  final String name;
  final String location;
  final double? latitude;
  final double? longitude;
  final String description;
  final String? nameJa;
  final String? descriptionJa;
  final String yearFounded;
  final String? logo;

  MosallaData({
    required this.id,
    required this.name,
    required this.location,
    this.latitude,
    this.longitude,
    required this.description,
    this.nameJa,
    this.descriptionJa,
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
      nameJa: data['nameJa'],
      descriptionJa: data['descriptionJa'],
      yearFounded: data['yearFounded']?.toString() ?? '',
      logo: data['logo'],
    );
  }

  bool get hasCoordinates => latitude != null && longitude != null;

  String localizedName(String lang) {
    if (lang == 'ja' && nameJa != null && nameJa!.isNotEmpty) {
      return nameJa!;
    }
    return name;
  }

  String localizedDescription(String lang) {
    if (lang == 'ja' && descriptionJa != null && descriptionJa!.isNotEmpty) {
      return descriptionJa!;
    }
    return description;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'description': description,
      'nameJa': nameJa,
      'descriptionJa': descriptionJa,
      'yearFounded': yearFounded,
      if (logo != null) 'logo': logo,
    };
  }
}
