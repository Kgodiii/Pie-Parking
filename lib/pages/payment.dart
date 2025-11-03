
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:payfast/payfast.dart';
import 'package:pie/pages/home.dart';
import 'package:pie/resources/style_constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pie/services/networking.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {

  String firstname = "";
  String lastname = "";
  String email = "";
  String paymentId = "";
  String totalAmount = "";
  String locationName = "";
  String timeElapsed = "";

  void getPaymentInfo() async{

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String userId = prefs.getInt('userId').toString();

    NetworkingHelper networkingHelperUser = NetworkingHelper(urlSuffix: "api/user");

    var response = await networkingHelperUser.getDataFromId(userId);
    setState(() {
      firstname = response['firstname'];
      lastname = response['lastname'];
      email = response['email'];
    });

  }

  void createPayment() async{

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    int sessionIdInt = prefs.getInt("sessionId") ?? 0;
    String sessionId = sessionIdInt.toString();

    String userId = prefs.getInt('userId').toString();

    NetworkingHelper networkingHelperSession = NetworkingHelper(urlSuffix: "api/session");

    var sessionInfo = await networkingHelperSession.getDataFromId(sessionId);

    String timeInString = sessionInfo["timeIn"];
    final currentTime = DateTime.now();
    DateTime timeIn = DateFormat("yyyy-MM-dd HH:mm:ss").parse(timeInString);
    final Duration duration = currentTime.difference(timeIn);

    String locationId = sessionInfo["locationId"].toString();

    NetworkingHelper networkingHelperLocation = NetworkingHelper(urlSuffix: "api/location");

    var locationInfo = await networkingHelperLocation.getDataFromId(locationId);

    double rate = locationInfo['hourlyRate'].toDouble();
    double runningTotal = duration.inHours * rate;
    String formattedTotal = runningTotal.toStringAsFixed(2);

    if(runningTotal <= 0){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ticket Paid")),
      );
      sleep(Duration(seconds: 2));
      prefs.setBool('sessionPaid', true);
      String sessionId = prefs.getInt('sessionId').toString();

      NetworkingHelper networkingHelperSession = NetworkingHelper(urlSuffix: "api/session");

      var response = await networkingHelperSession.putPaySession(sessionId);

      if(response['status'] == 1) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return HomePage();
        }));
      }
    }

    int totalMinutes = duration.inMinutes;
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;

    String twoDigitMinutes = minutes.toString().padLeft(2, '0');
    String formattedTime = '${hours}h:${twoDigitMinutes}m';

    NetworkingHelper networkingHelperTransaction = NetworkingHelper(urlSuffix: "api/transaction");

    var response = await networkingHelperTransaction.postCreateTransaction("0", formattedTotal, sessionId, userId, locationId);

    if(response['status'] == 1){
      String transactionId = response['transactionId'].toString();

      setState(() {
        paymentId = transactionId;
        totalAmount = runningTotal.toString();
        locationName = locationInfo['locationName'];
        timeElapsed = formattedTime;
      });
    }
  }

  void paymentCompleted(Map<String, dynamic> data) async{

    String transactionId = data['m_payment_id'];
    String paymentUUID = data['payment_uuid'];

    NetworkingHelper networkingHelperTransaction = NetworkingHelper(urlSuffix: "api/transaction");

    var response = await networkingHelperTransaction.postPaymentComplete(transactionId, paymentUUID);

    if(response['status'] == 1){
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setBool('sessionPaid', true);
      String sessionId = prefs.getInt('sessionId').toString();

      NetworkingHelper networkingHelperSession = NetworkingHelper(urlSuffix: "api/session");

      var response = await networkingHelperSession.putPaySession(sessionId);

      if(response['status'] == 1){
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return HomePage();
        }));
      }
    }
  }

  void paymentCancelled(){
    print('payment cancelled');
  }

  @override
  void initState() {
    getPaymentInfo();
    createPayment();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
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
          shadowColor: Colors.black,
          elevation: 4,
          scrolledUnderElevation: 6,
          backgroundColor: kPieNavy,
        ),
          body: Center(
            child: PayFast(
              // all the 'data' fields are required
              data: {
                'merchant_id': '10042960', // Your payfast merchant id (use sandbox details if sandbox is set to true)
                'merchant_key': 'kpy3ngnar6f0d', // Your payfast merchant key (use sandbox details if sandbox is set to true)
                'name_first': firstname, // customer first name
                'name_last': lastname,   // customer last name
                'email_address': email, // email address
                'm_payment_id': paymentId, // payment id
                'amount': totalAmount, // amount
                'item_name': 'Ticket', // item name (SHOULD BE ONE WORD, NO SPACES)
              },
              passPhrase: 'mypAyFAst2025_',  // Your payfast passphrase
              useSandBox: true, // true to use Payfast sandbox, false to use their live server
              // if useSandbox is set to true, use a sandbox link
              // you can use the github link below or provide your own link
              onsiteActivationScriptUrl: 'https://youngcet.github.io/sandbox_payfast_onsite_payments/', // url to the html file
              onPaymentCompleted: paymentCompleted, // callback function for successful payment
              onPaymentCancelled: paymentCancelled, // callback function for cancelled payment
              paymentSumarryWidget: Padding(
                padding: const EdgeInsets.only(top: 70.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  Flexible(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.all(40.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: kPieNavy,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(10.0), // Rounded corners with a radius of 10
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "images/PIE Pay Icon.png",
                          height: 200.0,
                        ),
                        SizedBox(height: 20.0,),
                        Text(
                          "PAYMENT",
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Poppins",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                  SizedBox(height: 40.0,),
                  Flexible(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: kPieNavy,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(10.0), // Rounded corners with a radius of 10
                      ),
                      child: Column(
                        children: [
                          Text(
                            locationName,
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 20.0,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Text("Time:"),
                                  Text(timeElapsed)
                                ],
                              ),
                              Column(
                                children: [
                                  Text("Amount Due:"),
                                  Text(totalAmount),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            payButtonStyle: kPieElevatedButtonStyle,
              waitingOverlayWidget: Center(
                child: Container(
                  height: 400,
                  width: double.infinity,
                  child: Center(
                    child: SpinKitDoubleBounce(
                      color: kPiePurple,
                      size: 50.0,
                    ),
                  ),
                ),
              ),
              onError: (errorMessage) {
                print('Payfast Error: $errorMessage');

                // Example: show a snackbar or alert dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(errorMessage)),
                );
              },
                      ),
        ),
      ),
    );
  }
}
