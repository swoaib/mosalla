import 'package:cloud_firestore/cloud_firestore.dart';

enum EventStatus { draft, published, cancelled }

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
  final EventStatus status;

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
    this.status = EventStatus.draft,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = Map<String, dynamic>.from(doc.data() as Map? ?? {});
    
    // Migration logic
    EventStatus status = EventStatus.published; // Default for old data
    if (data['status'] != null) {
      final statusStr = data['status'] as String;
      status = EventStatus.values.firstWhere(
        (e) => e.name == statusStr,
        orElse: () => EventStatus.published,
      );
    } else if (data['isCancelled'] == true) {
      status = EventStatus.cancelled;
    } else if (data['isDraft'] == true) {
      // Fallback for draft field if it existed in some version
      status = EventStatus.draft;
    }

    return Event(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      japaneseTitle: data['japaneseTitle'],
      japaneseDescription: data['japaneseDescription'],
      imageUrl: data['imageUrl'] ?? '',
      date: data['date'] != null ? (data['date'] as Timestamp).toDate() : DateTime.now(),
      startTime: (data['startTime'] as Timestamp?)?.toDate(),
      endTime: (data['endTime'] as Timestamp?)?.toDate(),
      status: status,
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
      'status': status.name,
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
          status: EventStatus.published,
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
          status: EventStatus.published,
        ),
        Event(
          id: '3',
          title: 'Charity Drive',
          description: 'Helping the needy in our local area. Please bring your donations.',
          imageUrl: 'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?auto=format&fit=crop&q=80',
          date: DateTime.now().add(const Duration(days: 5)),
          status: EventStatus.published,
        ),
      ];
}
