import 'package:flutter/material.dart';

const kPieNavy = Color(0xFF021431);
const kPiePink = Color(0xFFF7B1AE);
const kPiePurple = Color(0xFFBBB2FB);
const kPieWhite = Color(0xFFFFFFFF);

const kShadowColor = Color(0xFF333333);

const kPieHeadingStyle = TextStyle(
  fontFamily: "Poppins",
  fontSize: 30.0,
  fontWeight: FontWeight.bold,
  color: kPieNavy,
);

const kPieSubHeadingStyle = TextStyle(
  fontFamily: "Poppins ExtraLight",
  fontSize: 20.0,
  color: kPieNavy,
);

const kPieElevatedButtonStyle = ButtonStyle(
  backgroundColor: WidgetStatePropertyAll<Color>(kPieNavy),
  foregroundColor: WidgetStatePropertyAll<Color>(kPiePurple),
);