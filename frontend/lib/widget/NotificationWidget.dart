import 'package:flutter/material.dart';
import 'package:frontend/provider/NotificationModel.dart';
import 'package:frontend/model/Notification.dart' as CustomNotification;
import 'package:provider/provider.dart';

class NotificationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationModel>(
      builder: (context, notificationModel, child) {
        return ListView.builder(
          itemCount: notificationModel.notifications.length,
          itemBuilder: (context, index) {
            final CustomNotification.Notification notification = notificationModel.notifications[index];
            return ListTile(
              title: Text(notification.message),
              subtitle: Text(notification.timestamp.toLocal().toString()),
            );
          },
        );
      },
    );
  }
}
