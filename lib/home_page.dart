import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:telephony/telephony.dart';
import 'package:flutter/services.dart';



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

  // Local scoring function
  double score(List<double> input) {
    return -0.0358770572885019 +
        input[0] * 0.15696613903359896 +
        input[1] * 0.09279704168707996 +
        input[2] * 0.07831656537402229 +
        input[3] * 0.09433270425694708 +
        input[4] * 0.15696613903359896 +
        input[5] * 0.09279704168707996 +
        input[6] * 0.09433270425694708 +
        input[7] * 0.08800695350999603 +
        input[8] * 0.14618195668731174 +
        input[9] * 0.14618195668731174 +
        input[10] * 0.07831656537402229 +
        input[11] * 0.07831656537402229 +
        input[12] * 0.09223288843071553 +
        input[13] * 0.0798497124570837 +
        input[14] * 0.10903644376288923 +
        input[15] * 0.08800695350999603 +
        input[16] * 0.09223288843071553 +
        input[17] * 0.1596994249141674 +
        input[18] * 0.07831656537402229 +
        input[19] * 0.08800695350999603 +
        input[20] * 0.09433270425694708 +
        input[21] * -0.14307683179351782 +
        input[22] * -0.11487917984083854 +
        input[23] * 0.14484677920597588 +
        input[24] * -0.0968790850716365 +
        input[25] * -0.0968790850716365 +
        input[26] * -0.14307683179351782 +
        input[27] * -0.09298661213600339 +
        input[28] * -0.18597322427200677 +
        input[29] * 0.09279704168707996 +
        input[30] * 0.08800695350999603 +
        input[31] * 0.08800695350999603 +
        input[32] * 0.10903644376288923 +
        input[33] * 0.2446269407349587 +
        input[34] * 0.09433270425694708 +
        input[35] * 0.09279704168707996 +
        input[36] * 0.07831656537402229 +
        input[37] * -0.09298661213600339 +
        input[38] * 0.08800695350999603 +
        input[39] * -0.11487917984083854 +
        input[40] * 0.08800695350999603 +
        input[41] * 0.07831656537402229 +
        input[42] * 0.09433270425694708 +
        input[43] * 0.10903644376288923 +
        input[44] * -0.2789598364080101 +
        input[45] * 0.08800695350999603 +
        input[46] * 0.09223288843071553 +
        input[47] * -0.15651436204428487 +
        input[48] * -0.14911030464418304 +
        input[49] * -0.14911030464418304 +
        input[50] * 0.1596994249141674 +
        input[51] * 0.09279704168707996 +
        input[52] * 0.15663313074804458 +
        input[53] * 0.15663313074804458 +
        input[54] * 0.1541473344444075 +
        input[55] * 0.07831656537402229 +
        input[56] * 0.1541473344444075 +
        input[57] * 0.2775273947740079 +
        input[58] * 0.10903644376288923 +
        input[59] * -0.09298661213600339 +
        input[60] * -0.0968790850716365 +
        input[61] * 0.10903644376288923 +
        input[62] * 0.0798497124570837 +
        input[63] * -0.165821257868579 +
        input[64] * -0.11487917984083854 +
        input[65] * 0.1541473344444075 +
        input[66] * -0.0968790850716365 +
        input[67] * -0.0968790850716365 +
        input[68] * 0.10903644376288923 +
        input[69] * 0.08800695350999603 +
        input[70] * -0.11487917984083854 +
        input[71] * -0.14911030464418304 +
        input[72] * 0.09433270425694708 +
        input[73] * 0.08800695350999603 +
        input[74] * 0.09223288843071553 +
        input[75] * 0.09433270425694708 +
        input[76] * 0.09279704168707996 +
        input[77] * 0.09223288843071553 +
        input[78] * -0.154246729540001 +
        input[79] * -0.165821257868579 +
        input[80] * 0.0798497124570837 +
        input[81] * -0.18597322427200677 +
        input[82] * 0.09223288843071553 +
        input[83] * -0.09298661213600339 +
        input[84] * 0.0798497124570837 +
        input[85] * 0.18559408337415992 +
        input[86] * 0.09279704168707996 +
        input[87] * 0.09279704168707996 +
        input[88] * -0.165821257868579 +
        input[89] * 0.0798497124570837 +
        input[90] * 0.09223288843071553 +
        input[91] * 0.09433270425694708 +
        input[92] * 0.0798497124570837 +
        input[93] * -0.09298661213600339 +
        input[94] * -0.2789598364080101 +
        input[95] * 0.10903644376288923 +
        input[96] * -0.09298661213600339 +
        input[97] * -0.14307683179351782 +
        input[98] * 0.09223288843071553 +
        input[99] * 0.0798497124570837 +
        input[100] * 0.08800695350999603 +
        input[101] * -0.09298661213600339 +
        input[102] * 0.16247506902680448 +
        input[103] * -0.193758170143273 +
        input[104] * 0.07831656537402229 +
        input[105] * 0.07831656537402229 +
        input[106] * 0.10903644376288923 +
        input[107] * 0.1503557091991814 +
        input[108] * 0.08800695350999603 +
        input[109] * -0.09298661213600339 +
        input[110] * 0.09433270425694708 +
        input[111] * -0.0968790850716365 +
        input[112] * -0.2982206092883661 +
        input[113] * 0.0798497124570837 +
        input[114] * -0.0968790850716365 +
        input[115] * 0.09433270425694708 +
        input[116] * 0.17159991353167225 +
        input[117] * -0.09298661213600339 +
        input[118] * -0.11487917984083854 +
        input[119] * -0.14307683179351782 +
        input[120] * 0.16316080930775081 +
        input[121] * -0.11487917984083854 +
        input[122] * -0.0968790850716365 +
        input[123] * -0.09351615230456894 +
        input[124] * 0.0798497124570837 +
        input[125] * 0.15663313074804458 +
        input[126] * -0.18597322427200677 +
        input[127] * -0.1507762344054674 +
        input[128] * 0.15663313074804458 +
        input[129] * 0.10903644376288923 +
        input[130] * -0.14307683179351782 +
        input[131] * 0.09433270425694708 +
        input[132] * 0.07831656537402229 +
        input[133] * -0.09298661213600339 +
        input[134] * 0.07831656537402229 +
        input[135] * 0.1793142631571188 +
        input[136] * 0.15663313074804458 +
        input[137] * 0.16247506902680448 +
        input[138] * -0.0968790850716365 +
        input[139] * 0.10903644376288923 +
        input[140] * 0.10903644376288923 +
        input[141] * -0.14911030464418304 +
        input[142] * 0.0874259746024899 +
        input[143] * -0.165821257868579 +
        input[144] * -0.14911030464418304 +
        input[145] * 0.08800695350999603 +
        input[146] * -0.09918361183719553 +
        input[147] * -0.2789598364080101 +
        input[148] * 0.0798497124570837 +
        input[149] * -0.09351615230456894 +
        input[150] * -0.18597322427200677 +
        input[151] * -0.165821257868579 +
        input[152] * -0.2789598364080101 +
        input[153] * -0.0968790850716365 +
        input[154] * -0.1843402173521587 +
        input[155] * -0.09298661213600339 +
        input[156] * 0.10903644376288923 +
        input[157] * 0.10903644376288923 ;

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
    double result = score(features);
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
