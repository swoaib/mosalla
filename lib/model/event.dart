import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime date;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.date,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'date': Timestamp.fromDate(date),
    };
  }

  static List<Event> get dummyEvents => [
        Event(
          id: '1',
          title: 'Iftar Gathering',
          description: 'Join us for a community Iftar gathering at the Mosalla. Everyone is welcome!',
          imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=80',
          date: DateTime.now().add(const Duration(days: 1)),
        ),
        Event(
          id: '2',
          title: 'Quran Study Circle',
          description: 'Weekly Quran study circle for youth and adults. Let\'s learn together.',
          imageUrl: 'https://images.unsplash.com/photo-1582213708522-f8941bbbf71a?auto=format&fit=crop&q=80',
          date: DateTime.now().add(const Duration(days: 3)),
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
