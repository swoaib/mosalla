class FeedbackModel {
  final String content;
  final String? email;
  final DateTime timestamp;

  FeedbackModel({
    required this.content,
    this.email,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'email': email,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory FeedbackModel.fromMap(Map<String, dynamic> map) {
    return FeedbackModel(
      content: map['content'] ?? '',
      email: map['email'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
