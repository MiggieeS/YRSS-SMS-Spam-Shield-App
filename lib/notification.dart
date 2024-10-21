import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHandler {
  static int id = 0;

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {}

  static Future<void> init() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings("@mipmap/ic_launcher");

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveNotificationResponse,
    );
  }

  static Future<void> showNotification(String title, String body) async {
    String predictionResult;
    try {
      predictionResult = num.parse(title) >= 50.00 ? "spam" : "not spam";
    } catch (error) {
      predictionResult = title;
    }

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channel id',
      'channel name',
      channelDescription: 'channel description',
      importance: Importance.max,
      priority: Priority.high,
      channelShowBadge: false,
      colorized: true,
      color: switch (predictionResult) {
        "spam" => const Color(0xFFd1515e),
        "not spam" => const Color(0xFF355E3B),
        _ => Colors.grey
      },
    );
    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        id++,
        switch (predictionResult) {
          "spam" => "${title}% likely to be SPAM!",
          "not spam" => "${100-num.parse(title)}% likely to be safe.",
          _ => "Error!"
        },
        switch (predictionResult) {
          "spam" => body,
          "not spam" => body,
          _ => title,
        },
        notificationDetails);
  }
}
