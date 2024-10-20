import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:another_telephony/telephony.dart';
import 'package:flutter/services.dart';
import 'notification.dart';

final Telephony telephony = Telephony.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request SMS permissions before starting the app
  bool? permissionsGranted = await telephony.requestSmsPermissions;

  // Initialize NotificationHandler.
  NotificationHandler.init();

  // set to portrait mode only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HomePage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}
