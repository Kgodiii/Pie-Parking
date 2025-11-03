
import 'package:flutter/material.dart';
import 'package:pie/pages/payment.dart';
import 'package:pie/resources/style_constants.dart';
import 'package:pie/services/networking.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:pie/pages/home.dart';

class TicketPage extends StatefulWidget {
  const TicketPage({super.key});

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {

  var ticketData;

  void isTicketPaid() async{

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if(prefs.getBool('sessionActive') == true && prefs.getBool('sessionPaid') == true){
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return HomePage();
      }));
    }

  }

  void getTicketInfo() async{

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    int sessionIdInt = prefs.getInt("sessionId") ?? 0;
    String sessionId = sessionIdInt.toString();

    NetworkingHelper networkingHelperSession = NetworkingHelper(urlSuffix: "api/session");

    var sessionInfo = await networkingHelperSession.getDataFromId(sessionId);

    String timeInString = sessionInfo["timeIn"];
    final currentTime = DateTime.now();
    DateTime timeIn = DateFormat("yyyy-MM-dd HH:mm:ss").parse(timeInString);
    final Duration duration = currentTime.difference(timeIn);

    NetworkingHelper networkingHelperLocation = NetworkingHelper(urlSuffix: "api/location");

    var locationInfo = await networkingHelperLocation.getDataFromId(sessionInfo["locationId"].toString());

    double rate = locationInfo['hourlyRate'].toDouble();
    double runningTotal = duration.inHours * rate;
    String formattedTotal = runningTotal.toStringAsFixed(2);

    setState(() {
      ticketData = Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Ticket ID: ${sessionInfo["sessionId"]}",
            style: TextStyle(
              color: Colors.black,
              fontFamily: "Poppins",
              fontSize: 20.0,
              fontWeight: FontWeight.normal,
              letterSpacing: 1,
            ),
          ),
          Text(
            "In: ${sessionInfo["timeIn"]}",
            style: TextStyle(
              color: Colors.black,
              fontFamily: "Poppins",
              fontSize: 10.0,
              fontWeight: FontWeight.w200,
              letterSpacing: 1,
            ),
          ),
          Text(
            "R$formattedTotal",
            style: TextStyle(
              color: kPiePurple,
              fontFamily: "Poppins",
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      );
    });

  }

  @override
  void initState() {
    isTicketPaid();
    getTicketInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: kPieWhite,
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Image.asset("images/PIE Parking Icon.png"),
          ),
          leadingWidth: 50,
          actions: [
            PopupMenuButton(
              child: Icon(
                Icons.menu,
                color: kPiePink,
                size: 40.0,
              ),
              itemBuilder: (context) => [
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
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.all(40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                  flex: 3,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 80.0),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('images/PIE ticket.png'),
                      ),
                    ),
                    child: ticketData,
                  ),
                ),
                SizedBox(height: 20.0,),
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
                    child: Text("Please be sure to pay before driving to the exit gate")
                  ),
                ),
                SizedBox(height: 20.0,),
                ElevatedButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) {return PaymentPage();}));
                  },
                  style: kPieElevatedButtonStyle,
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.credit_card,
                          color: kPiePink,
                        ),
                        Text(
                          "Pay Now",
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
