import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final String? japaneseTitle;
  final String? japaneseDescription;
  final String imageUrl;
  final DateTime date;
  final DateTime? startTime;
  final DateTime? endTime;

  Event({
    required this.id,
    required this.title,
    required this.description,
    this.japaneseTitle,
    this.japaneseDescription,
    required this.imageUrl,
    required this.date,
    this.startTime,
    this.endTime,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      japaneseTitle: data['japaneseTitle'],
      japaneseDescription: data['japaneseDescription'],
      imageUrl: data['imageUrl'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      startTime: data['startTime'] != null ? (data['startTime'] as Timestamp).toDate() : null,
      endTime: data['endTime'] != null ? (data['endTime'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'japaneseTitle': japaneseTitle,
      'japaneseDescription': japaneseDescription,
      'imageUrl': imageUrl,
      'date': Timestamp.fromDate(date),
      if (startTime != null) 'startTime': Timestamp.fromDate(startTime!),
      if (endTime != null) 'endTime': Timestamp.fromDate(endTime!),
    };
  }

  static List<Event> get dummyEvents => [
        Event(
          id: '1',
          title: 'Iftar Gathering',
          japaneseTitle: 'イフタール・ギャザリング',
          description: 'Join us for a community Iftar gathering at the Mosalla. Everyone is welcome!',
          japaneseDescription: 'モサラで開催されるコミュニティ・イフタール・ギャザリングに参加しましょう。どなたでも歓迎します！',
          imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=80',
          date: DateTime.now().add(const Duration(days: 1)),
          startTime: DateTime.now().add(const Duration(days: 1, hours: 18)),
          endTime: DateTime.now().add(const Duration(days: 1, hours: 20)),
        ),
        Event(
          id: '2',
          title: 'Quran Study Circle',
          japaneseTitle: 'コーラン勉強会',
          description: 'Weekly Quran study circle for youth and adults. Let\'s learn together.',
          japaneseDescription: '青少年と大人のための週刊コーラン勉強会。一緒に学びましょう。',
          imageUrl: 'https://images.unsplash.com/photo-1582213708522-f8941bbbf71a?auto=format&fit=crop&q=80',
          date: DateTime.now().add(const Duration(days: 3)),
          startTime: DateTime.now().add(const Duration(days: 3, hours: 10)),
        ),
        Event(
          id: '3',
          title: 'Charity Drive',
          description: 'Helping the needy in our local area. Please bring your donations.',
          imageUrl: 'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?auto=format&fit=crop&q=80',
          date: DateTime.now().add(const Duration(days: 5)),
        ),
      ];
}
