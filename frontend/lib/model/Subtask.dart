import 'package:flutter/material.dart';
import 'package:frontend/model/Comment.dart';

class Subtask {
  final String id;
  final String title;
  bool isCompleted;
  final List<Comment> comments;
  bool status;

  Subtask({
    required this.id,
    required this.title,
    this.isCompleted = false,
    List<Comment>? comments,
    this.status = false,
  }) : comments = comments ?? [];

  void addComment(String developerId, String text) {
    final comment = Comment(
      id: UniqueKey().toString(),
      developerId: developerId,
      text: text,
      timestamp: DateTime.now(),
    );
    comments.add(comment);
  }

  void markAsCompleted() {
    isCompleted = true;
  }

  factory Subtask.fromJson(Map<String, dynamic> json) {
    return Subtask(
      id: json['id'],
      title: json['title'],
      isCompleted: json['isCompleted'],
      comments: (json['comments'] as List<dynamic>)
          .map((commentJson) => Comment.fromJson(commentJson))
          .toList(),
      status: json['status'],
    );
  }

   Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'comments': comments.map((comment) => comment.toJson()).toList(),
      'status': status,
    };
  }
}
