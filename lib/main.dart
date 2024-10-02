import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:telephony/telephony.dart';

final Telephony telephony = Telephony.instance;

void backgrounMessageHandler(SmsMessage message) async {
  // Handle background SMS message
  print("Received SMS in background: ${message.body}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request SMS permissions before starting the app
  bool? permissionsGranted = await telephony.requestSmsPermissions;

  runApp(MyApp());
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
