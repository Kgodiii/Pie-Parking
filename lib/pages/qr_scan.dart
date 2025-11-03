import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pie/pages/home.dart';
import 'package:pie/pages/payment.dart';
import 'package:pie/pages/ticket.dart';
import 'package:pie/resources/style_constants.dart';
import 'package:pie/services/networking.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pie/pages/sign_in.dart';
import 'package:intl/intl.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {

  void isLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getBool('isLoggedIn') == false ||
        prefs.getBool('isLoggedIn') == null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return SignInPage();
      }));
    }
  }

  String errorMessage = "";

  MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: [BarcodeFormat.qrCode], // Specify only QR codes
    returnImage: false, // Set to true if you need the scanned image
  );

  void createSession(String locationId, String gateId) async{

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if(prefs.getBool('sessionActive') == true){
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return HomePage();
      }));
      return;
    }
    
    int userId = prefs.getInt("userId") ?? 0;
    String userIdString = userId.toString();

    NetworkingHelper networkingHelperSession = NetworkingHelper(urlSuffix: "api/session");

    var response = await networkingHelperSession.postCreateSession(userIdString, locationId);

    if(response["status"] == 1){
      final now = DateTime.now();
      final formattedDate = DateFormat("yyyy/MM/dd").format(now);

      prefs.setString("loginDate", formattedDate);
      prefs.setBool("sessionActive", true);
      prefs.setBool('sessionPaid', false);
      prefs.setInt("sessionId", response["sessionId"]);
      triggerGate(gateId);
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return TicketPage();
      }));
    }else{
      setState(() {
        errorMessage = "Could not create session";
      });
    }

  }

  void validateSession(String gateId) async{

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if(prefs.getBool("sessionActive") == true){
      int sessionIdInt = prefs.getInt("sessionId") ?? 0;
      String sessionId = sessionIdInt.toString();

      NetworkingHelper networkingHelperSession = NetworkingHelper(urlSuffix: "api/session");

      var response = await networkingHelperSession.getDataFromId(sessionId);

      if(response["timePaid"] != null){

        var endResponse = await networkingHelperSession.putEndSession(sessionId);

        if(endResponse["status"] == 1){
          prefs.setBool("sessionActive", false);
          prefs.remove("sessionId");
          triggerGate(gateId);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Success!')),
          );
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return HomePage();
          }));
        }else{
          setState(() {
            errorMessage = "Could not close session";
          });
        }

      }else if(response["timePaid"] == null){
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return PaymentPage();
        }));
      }
    }

  }

  void triggerGate(String gateId) async{

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    NetworkingHelper networkingHelperIot = NetworkingHelper(urlSuffix: "api/iot");

    var response = await networkingHelperIot.putGateOpen(gateId);

    if(response["status"] == 1){
      return;
    }else{
      prefs.setBool("sessionActive", false);
      prefs.remove("sessionId");
      setState(() {
        errorMessage = "Could not open gate";
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: kPieWhite,
          ),
        ),
        title: Text(
          errorMessage,
          style: TextStyle(
            backgroundColor: Color(0xD0DE3B3B),
            color: kPieWhite,
          ),
        ),
        actions: [
          PopupMenuButton(
            child: Icon(
              Icons.menu,
              color: kPiePink,
              size: 40.0,
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: "home",
                onTap: (){
                  Navigator.of(context).pushNamed('/home');
                },
                child: Text("History"),
              ),
              PopupMenuItem(
                value: "account",
                onTap: (){
                  Navigator.of(context).pushNamed('/account');
                },
                child: Text("Account"),
              ),
              PopupMenuItem(
                value: "history",
                onTap: (){
                  Navigator.of(context).pushNamed('/history');
                },
                child: Text("History"),
              ),
            ],
            onSelected: (String newValue){
              setState((){

              });
            },
          ),
        ],
        shadowColor: Colors.black,
        elevation: 4,
        scrolledUnderElevation: 6,
        backgroundColor: kPieNavy,
      ),
      body: MobileScanner(
        controller: controller,
        onDetect: (capture) {
          controller.stop();
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            String? qrInfoNullable = barcode.rawValue;
            String qrInfo = qrInfoNullable ?? "No Value";

            if(!RegExp(r'^([0-9]+,[0-9]+,[0-1]{1})$').hasMatch(qrInfo)){
              setState(() {
                errorMessage = "Invalid QR Code";
              });
            }else{
              List data = qrInfo.split(",");

              String gateId = data[0];
              String locationId = data[1];
              String gateType = data[2];

              if(gateType == "0"){
                createSession(locationId, gateId);
              }else if(gateType == "1"){
                validateSession(gateId);
              }
            }
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

}
