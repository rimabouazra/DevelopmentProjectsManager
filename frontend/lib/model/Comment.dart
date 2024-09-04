class Comment {
  final String id;
  final String developerId;
  final String text;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.developerId,
    required this.text,
    required this.timestamp,
  });

   factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      developerId: json['developerId'],
      text: json['text'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

   Map<String, dynamic> toJson() {
    return {
      'id': id,
      'developerId': developerId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
