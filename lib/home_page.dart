import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:another_telephony/telephony.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'notification.dart';

final Telephony telephony = Telephony.instance;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
  GlobalKey<ScaffoldMessengerState>();
  final TextEditingController messageController = TextEditingController();
  String? predictionResult;
  bool isLoading = false; // New loading state variable
  static const backendURL = 'http://3.27.110.191:5000/predict';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showWelcomeDialog();
    });
    startListeningForSms();
  }

  void showWelcomeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFfffcf5),
          title: Text('Welcome to Spam Detector', style: GoogleFonts.readexPro()),
          content: Text(
            'This app helps you detect whether a message is spam or not.\n\n'
            'You may manually copy and paste text to the text field and click the search button to check the message.\n\n'
            'You may also allow access to background SMS reading and notifications to notify you whether you received a spam message or not.',
            style: GoogleFonts.readexPro(),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: Text(
                'Okay, got it!',
                style: GoogleFonts.readexPro(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  @pragma('vm:entry-point')
  void startListeningForSms() {
    telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        if (message.body != null) {
          showSnackbar(message.body!);
          checkSpam(message.body!); // Check for spam on incoming messages
        }
      },
      onBackgroundMessage: backgroundMessageHandler,
      listenInBackground: true,
    );
  }

  void showSnackbar(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {
            scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void checkSpam(String message) async {
    setState(() {
      isLoading = true; // Show loading indicator
      predictionResult = null; // Reset the result
    });

    try {
      final response = await http.post(
        Uri.parse(backendURL),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'message': message}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final prediction = jsonResponse['prediction'];

        setState(() {
          predictionResult = prediction == 1 ? 'spam' : 'not spam';
        });
      } else {
        setState(() {
          predictionResult = 'Error: ${response.statusCode}';
        });
      }
    } catch (error) {
      setState(() {
        predictionResult = 'Error: $error';
      });
    } finally {
      setState(() {
        isLoading = false; // Hide loading indicator
      });
    }
  }

  static Future<String> checkSpamInBackground(String message) async {
    try {
      final response = await http.post(
        Uri.parse(backendURL),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'message': message}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final prediction = jsonResponse['prediction'];
        return prediction == 1
            ? 'spam'
            : 'not spam';
      } else {
        print('Error: ${response.statusCode}');
        return 'Error: ${response.statusCode}';
      }
    } catch (error) {
      print('Error: $error');
      return 'Error: $error';
    }
  }

  @pragma('vm:entry-point')
  static Future<void> backgroundMessageHandler(SmsMessage message) async {
    if (message.body != null) {
      String body = message.body!;
      String result = await checkSpamInBackground(body);
      print("Received SMS: $body is $result");
      NotificationHandler.showNotification(result, body);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        backgroundColor: const Color(0xFFfffcf5),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5.0, bottom: 10.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Spam Detector',
                      style: GoogleFonts.readexPro(
                        color: const Color(0xFF798087),
                        fontSize: 33,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  child: TextField(
                    controller: messageController,
                    style: GoogleFonts.readexPro(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Message',
                      hintText: 'Type Message Here...',
                      hintStyle:
                      GoogleFonts.readexPro(color: const Color(0xFF878787)),
                      labelStyle:
                      GoogleFonts.readexPro(color: const Color(0xFF798087)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xFF878787),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),//0956 387 2399
                ),
                const SizedBox(height: 10),
                if (isLoading)
                  const CircularProgressIndicator(), // Show loading indicator
                const SizedBox(height: 0),
                if (predictionResult != null)
                  Container(
                    padding: const EdgeInsets.all(10),
                    width: screenWidth * 0.9,
                    decoration: BoxDecoration(
                      color: switch (predictionResult) {
                        "spam" => const Color(0xFFffdee1),
                        "not spam" => const Color(0xFFf4f4e8),
                        _ => Colors.grey.shade100
                      },
                      border: Border.all(
                        color: switch (predictionResult) {
                          "spam" => const Color(0xFFd1515e),
                          "not spam" => const Color(0xFF355E3B),
                          _ => Colors.grey
                        },
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          switch (predictionResult) {
                            "spam" => Icons.warning_amber_rounded,
                            "not spam" => Icons.check_circle_outline,
                            _ => Icons.warning_amber_rounded
                          },
                          size: screenWidth * 0.12,
                          color: switch (predictionResult) {
                            "spam" => const Color(0xFFd1515e),
                            "not spam" => const Color(0xFF355E3B),
                            _ => Colors.grey
                          },
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                switch (predictionResult) {
                                  "spam" => "Spam Detected!",
                                  "not spam" => "Message is Safe",
                                  _ => "Error!"
                                },
                                style: GoogleFonts.readexPro(
                                  fontWeight: FontWeight.bold,
                                  color: switch (predictionResult) {
                                    "spam" => const Color(0xFFd1515e),
                                    "not spam" => const Color(0xFF355E3B),
                                    _ => Colors.grey
                                  },
                                  fontSize: screenWidth * 0.05,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                switch (predictionResult) {
                                  "spam" =>
                                  "The message appears to be spam. Be cautious before interacting.",
                                  "not spam" =>
                                  "This message is safe but always remain vigilant.",
                                  _ => predictionResult ?? ""
                                },
                                style: GoogleFonts.readexPro(
                                  color: const Color(0xFF44433c),
                                  fontSize: screenWidth * 0.035,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            String message = messageController.text;
            checkSpam(message);
          },
          backgroundColor: const Color(0xFFf4f4e8),
          child: const Icon(Icons.search_rounded),
        ),
      ),
    );
  }
}


