import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:telephony/telephony.dart';
import 'package:flutter/services.dart';
import 'spam_logistic_regression_model.dart';



final Telephony telephony = Telephony.instance;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final TextEditingController messageController = TextEditingController();
  String? predictionResult;

  @override
  void initState() {
    super.initState();
    startListeningForSms();
    _lockOrientation(); //portrait mode (ayaw gumana idk why)
  }

  void startListeningForSms() {
    telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        if (message.body != null) {
          showSnackbar(message.body!);
        }
      },
      onBackgroundMessage: backgroundMessageHandler,
      listenInBackground: true,
    );
  }

  void _lockOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
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


  //checking
  List<double> extractFeatures(String message) {
    List<double> features = List<double>.filled(158, 0.0);
    features[0] = message.length.toDouble();
    features[1] = message.contains("win") ? 1.0 : 0.0;

    return features;
  }

  void checkSpam(String message) {
    List<double> features = extractFeatures(message);
    double result = predictTextMessage(features);
    print("Prediction result: $result");

    setState(() {
      predictionResult = result > 0.5 ? 'Spam' : 'Not Spam';
    });
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
                      hintStyle: GoogleFonts.readexPro(color: const Color(0xFF878787)),
                      labelStyle: GoogleFonts.readexPro(color: const Color(0xFF798087)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF878787), width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                //Container + Message for Safe/Spam (Not Checking, but displays)
                SizedBox(height: 20, width: 20),
                if (predictionResult != null)
                  Stack(
                    children: [
                      Container(
                        height: 115,
                        width: 450,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: predictionResult == 'Spam'
                              ? const Color(0xFFf1f1f1)
                              : const Color(0xFFf4f4e8),
                          border: Border.all(
                            color: predictionResult == 'Spam'
                                ? const Color(0xFFf1f1f1)
                                : const Color(0xFFf4f4e8),
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
                          predictionResult == 'Spam' ? Icons.warning_amber_rounded : Icons.check,
                          size: 90, // Large icon size
                          color: predictionResult == 'Spam' ? const Color(0xFF727272) : const Color(0xFF355E3B),
                        ),
                      ),
                      // Text Positioning
                      Positioned(
                        right: 140,
                        top: 20,
                        child: Text(
                          predictionResult == 'Spam'
                              ? 'Most Likely Spam'
                              : 'Most Likely Safe  ',
                          style: GoogleFonts.readexPro(
                            fontWeight: FontWeight.bold,
                            color: predictionResult == 'Spam'
                                ? const Color(0xFF727272)
                                : const Color(0xFF355E3B),
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
                            'The message is most likely a ${predictionResult == 'Spam' ? 'spam' : 'safe'} text, but still proceed with caution and awareness.',
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
                            color: predictionResult == 'Spam'
                                ? const Color(0xFF727272)
                                : const Color(0xFF355E3B),
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

void backgroundMessageHandler(SmsMessage message) {
  print("Received SMS in background: ${message.body}"); // testing, will only print in cpnsole
}
