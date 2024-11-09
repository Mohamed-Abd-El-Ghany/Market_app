import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../resources/strings_manager.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  NotificationsPageState createState() => NotificationsPageState();
}

class NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return   Center(
      child: Text(AppStrings.notifications.tr()),
    );
  }
}
