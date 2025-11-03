import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pie/pages/home.dart';
import 'package:pie/pages/sign_in.dart';
import 'package:pie/pages/sign_up.dart';
import 'package:pie/pages/ticket.dart';
import 'package:pie/resources/style_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class Load extends StatefulWidget {
  const Load({super.key});

  @override
  State<Load> createState() => _LoadState();
}

class _LoadState extends State<Load> {

  Future<void> reset() async{

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.clear();

  }

  Future<void> getIsLoggedIn() async{

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if(prefs.getBool('isLoggedIn') == null){
      Navigator.push(context, MaterialPageRoute(builder: (context) {return SignUpPage();})); //TODO: Create and add Sign Up page
    }else if(prefs.getBool('isLoggedIn') == true){
      if(prefs.getBool('sessionActive') == true){
        Navigator.push(context, MaterialPageRoute(builder: (context) {return TicketPage();}));
      }else {
        final currentDate = DateTime.now();

        final lastLoginString = prefs.getString("loginDate") ?? "2000/01/01 00:00:00";
        DateTime lastLogin = DateFormat("yyyy/MM/dd").parse(lastLoginString);

        final Duration duration = currentDate.difference(lastLogin);

        if(duration.inDays > 15){
          Navigator.push(context, MaterialPageRoute(builder: (context) {return SignInPage();}));
        }

        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return HomePage();
        }));
      }
    }else{
      Navigator.push(context, MaterialPageRoute(builder: (context) {return SignInPage();}));
    }

  }

  @override
  void initState() {
    //reset();
    getIsLoggedIn();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kPieWhite,
        body: Center(
          child: SpinKitDoubleBounce(
            color: kPiePurple,
            size: 50.0,
          ),
        )
    );
  }
}