import 'package:flutter/material.dart';
import 'package:frontend/model/Comment.dart';

class Subtask {
  final String id;
  final String title;
  final bool isCompleted;
  final List<Comment> comments;
  bool status;

  Subtask({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.comments = const [], 
    this.status=false,
  });

  void addComment(Comment comment) {
    comments.add(comment);
  }

  void addCommentToSubtask(Subtask subtask, String developerId, String text) {
  final comment = Comment(
    id: UniqueKey().toString(),
    developerId: developerId,
    text: text,
    timestamp: DateTime.now(),
  );
  subtask.addComment(comment);
}

}
