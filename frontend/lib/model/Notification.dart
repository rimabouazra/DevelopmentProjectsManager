class Notification {
  final String id;
  final String message;
  final String userId; 
  final DateTime timestamp;

  Notification({
    required this.id,
    required this.message,
    required this.userId,
    required this.timestamp,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      message: json['message'],
      userId: json['userId'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
