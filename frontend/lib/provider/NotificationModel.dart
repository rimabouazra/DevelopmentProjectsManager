import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:frontend/model/Notification.dart'as CustomNotification;

class NotificationModel extends ChangeNotifier {
  final List<CustomNotification.Notification> _notifications = [];

  List<CustomNotification.Notification> get notifications => _notifications;

  void addNotification(String userId, String message) {
    final newNotification = CustomNotification.Notification(
      id: UniqueKey().toString(),
      message: message,
      userId: userId,
      timestamp: DateTime.now(),
    );
    _notifications.add(newNotification);
    notifyListeners();
  }

  void removeNotification(String id) {
    _notifications.removeWhere((notification) => notification.id == id);
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }
}
