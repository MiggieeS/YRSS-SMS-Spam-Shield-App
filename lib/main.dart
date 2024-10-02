import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:telephony/telephony.dart';
import 'package:flutter/services.dart';

final Telephony telephony = Telephony.instance;

void backgrounMessageHandler(SmsMessage message) async {
  print("Received SMS in background: ${message.body}"); // for testing, will only show up in the console if ran
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  bool? permissionsGranted = await telephony.requestSmsPermissions;

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
