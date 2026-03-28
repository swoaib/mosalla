import 'package:cloud_firestore/cloud_firestore.dart';

class MosallaData {
  final String id;
  final String name;
  final String location;
  final String description;
  final String yearFounded;
  final String? logo;

  MosallaData({
    required this.id,
    required this.name,
    required this.location,
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
      description: data['description'] ?? '',
      yearFounded: data['yearFounded']?.toString() ?? '',
      logo: data['logo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'description': description,
      'yearFounded': yearFounded,
      if (logo != null) 'logo': logo,
    };
  }
}
