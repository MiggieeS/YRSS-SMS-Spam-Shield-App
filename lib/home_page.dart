import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:telephony/telephony.dart';
import 'package:http/http.dart' as http; // Import the http package
import 'dart:convert'; // Import for JSON encoding/decoding

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
  static const backendURL = 'http://3.27.110.191:5000/predict';
  // static const backendURL = 'http://10.0.2.2:5000/predict'; // local backend

  @override
  void initState() {
    super.initState();
    startListeningForSms();
  }

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
    try {
      // Send the POST request
      final response = await http.post(
        Uri.parse(backendURL),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'message': message}),
      );

      // Check the response status
      if (response.statusCode == 200) {
        // Parse the response body
        final jsonResponse = json.decode(response.body);
        final prediction = jsonResponse['prediction'];

        setState(() {
          predictionResult = prediction == 1 ? 'spam' : 'not spam';
        });
      } else {
        print('Error: ${response.statusCode}');
        setState(() {
          predictionResult = 'Error: ${response.statusCode}';
        });
      }
    } catch (error) {
      print('Error: $error');
      setState(() {
        predictionResult = 'Error: $error';
      });
    }
  }

  // Synchronous function for background processing
  static Future<String> checkSpamInBackground(String message) async {
    try {
      // Send the POST request
      final response = await http.post(
        Uri.parse(backendURL),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'message': message}),
      );

      // Check the response status
      if (response.statusCode == 200) {
        // Parse the response body
        final jsonResponse = json.decode(response.body);
        final prediction = jsonResponse['prediction'];
        return prediction == 1 ? 'spam' : 'not spam';
      } else {
        print('Error: ${response.statusCode}');
        return 'Error: ${response.statusCode}';
      }
    } catch (error) {
      print('Error: $error');
      return 'Error: $error';
    }
  }

  static Future<void> backgroundMessageHandler(SmsMessage message) async {
    if (message.body != null) {
      String body = message.body!;
      String result = await checkSpamInBackground(body);
      print("Received SMS: $body is $result");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFFfffcf5),
          title: Row(
            children: [
              Expanded(child: Container()),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {},
          ),
        ),
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
                      hintText: 'Message',
                      hintStyle:
                          GoogleFonts.readexPro(color: const Color(0xFF878787)),
                      labelStyle:
                          GoogleFonts.readexPro(color: const Color(0xFF798087)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color(0xFF878787), width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).primaryColor, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                // Container + Message for Safe/Spam (Not Checking, but displays)
                SizedBox(height: 20, width: 20),
                if (predictionResult != null)
                  Stack(
                    children: [
                      Container(
                        height: 115,
                        width: 450,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: switch (predictionResult) {
                            'spam' => const Color(0xFFf1f1f1),
                            'not spam' => const Color(0xFFf4f4e8),
                            _ => const Color(0xFFf4f4e8)
                          },
                          border: Border.all(
                            color: switch (predictionResult) {
                              'spam' => const Color(0xFFf1f1f1),
                              'not spam' => const Color(0xFFf4f4e8),
                              _ => const Color(0xFFf4f4e8)
                            },
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      // Icon Positioning
                      Positioned(
                        left: 10,
                        top: 10,
                        child: Icon(
                          switch (predictionResult) {
                            'spam' => Icons.warning_amber_rounded,
                            'not spam' => Icons.check,
                            _ => Icons.warning_amber_rounded
                          },
                          size: 90, // Large icon size
                          color: switch (predictionResult) {
                            'spam' => Colors.red,
                            'not spam' => const Color(0xFF355E3B),
                            _ => const Color(0xFF727272)
                          },
                        ),
                      ),
                      // Text Positioning
                      Positioned(
                        right: 140,
                        top: 20,
                        child: Text(
                          switch (predictionResult) {
                            'spam' => 'Most Likely Spam!',
                            'not spam' => 'Most Likely Safe',
                            _ => "Error!"
                          },
                          style: GoogleFonts.readexPro(
                            fontWeight: FontWeight.bold,
                            color: switch (predictionResult) {
                              'spam' => Colors.red,
                              'not spam' => const Color(0xFF355E3B),
                              _ => const Color(0xFF727272)
                            },
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 60,
                        top: 50,
                        child: SizedBox(
                          width: 260,
                          child: Text(
                            switch (predictionResult) {
                              'spam' =>
                                'The message is most likely a spam text, proceed with caution and awareness.',
                              'not spam' =>
                                'The message is most likely safe, but still proceed with caution and awareness.',
                              _ => predictionResult ?? ""
                            },
                            style: GoogleFonts.readexPro(
                              color: const Color(0xFF44433c),
                              fontSize: 12, // Smaller font size
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: switch (predictionResult) {
                              'spam' => Colors.red,
                              'not spam' => const Color(0xFF355E3B),
                              _ => const Color(0xFF727272)
                            },
                          ),
                          height: 4,
                          width: double.infinity,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            String message = messageController.text.trim();
            if (message.isNotEmpty) {
              checkSpam(message);
            }
          },
          backgroundColor: const Color(0xFFd3ee7e),
          child: const Icon(Icons.check),
        ),
      ),
    );
  }
}
