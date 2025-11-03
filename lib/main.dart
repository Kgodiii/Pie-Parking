import 'package:flutter/material.dart';
import 'package:pie/resources/style_constants.dart';
import 'package:pie/pages/payment.dart';
import 'package:pie/pages/ticket.dart';
import 'package:pie/services/load.dart';
import 'package:pie/pages/home.dart';
import 'package:pie/pages/sign_in.dart';
import 'package:pie/pages/sign_up.dart';
import 'package:pie/pages/qr_scan.dart';

void main() {
  runApp(const RunApp());
}

class RunApp extends StatelessWidget {
  const RunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Load(),
      routes: {
        '/home': (context) => HomePage(),
        '/sign_in': (context) => SignInPage(),
        '/sign_up': (context) => SignUpPage(),
        '/qr_scan': (context) => QrScanPage(),
        '/ticket': (context) => TicketPage(),
        '/payment': (context) => PaymentPage(),
      },
      theme: ThemeData(
          fontFamily: "Poppins",
          textTheme: TextTheme(
            headlineLarge: TextStyle(color: kPieNavy),
            headlineMedium: TextStyle(color: kPieNavy),
            headlineSmall: TextStyle(color: kPieNavy),
            titleLarge: TextStyle(color: kPieNavy),
            titleMedium: TextStyle(color: kPieNavy),
            titleSmall: TextStyle(color: kPieNavy),
            bodyLarge: TextStyle(color: kPieNavy),
            bodyMedium: TextStyle(color: kPieNavy),
            bodySmall: TextStyle(color: kPieNavy),
          )
      ),
    );
  }
}