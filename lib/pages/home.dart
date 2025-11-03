import 'package:flutter/material.dart';
import 'package:pie/pages/qr_scan.dart';
import 'package:pie/resources/style_constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String contextWord = "ENTER";

  Widget bottomBoxContent = Center(
    child: SpinKitDoubleBounce(
      color: kPiePurple,
      size: 50.0,
    ),
  );

  Widget entryContent = Column(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            FontAwesomeIcons.one,
            color: kPiePurple,
          ),
          Text("Scan the QR on the Gate")
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            FontAwesomeIcons.two,
            color: kPiePurple,
          ),
          Text("Shop without stress, no paper ticket")
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            FontAwesomeIcons.three,
            color: kPiePurple,
          ),
          Text("Skip the queue, no need for cash... \nPay in the App")
        ],
      )
    ],
  );

  Widget exitContent = Column(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      Text(
        "Going already? We hope to see you soon..."
      ),
      Text(
        "To exit, simply scan the QR code on the Exit Gate"
      ),
    ],
  );

  void getContext() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if(prefs.getBool("sessionActive") == true){
      setState(() {
        contextWord = "EXIT";
        bottomBoxContent = exitContent;
      });
    }else{
      setState(() {
        contextWord = "ENTER";
        bottomBoxContent = entryContent;
      });
    }
  }

  @override
  void initState() {
    getContext();
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
                    flex: 2,
                    child: GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) {return QrScanPage();}));
                      },
                      child: Container(
                        padding: EdgeInsets.all(20.0),
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
                              "images/qr_scanner_icon.png",
                              height: 200.0,
                            ),
                            Text(
                              "SCAN TO $contextWord",
                              style: TextStyle(
                                fontSize: 30.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Poppins",
                              ),
                            ),
                            Text(
                              "It's That Easy...",
                              style: TextStyle(
                                fontSize: 20.0,
                                fontFamily: "Poppins ExtraLight",
                                color: kPiePurple,
                              ),
                            ),
                          ],
                        ),
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
                      child: bottomBoxContent,
                    ),
                  ),
                  SizedBox(height: 40.0,),
                  ElevatedButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) {return QrScanPage();}));
                    },
                    style: kPieElevatedButtonStyle,
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.qr_code,
                            color: kPiePink,
                          ),
                          Text(
                            "Scan Now",
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
