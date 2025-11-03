import 'package:flutter/material.dart';
import 'package:pie/resources/style_constants.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:pie/services/networking.dart';
import 'package:pie/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController = TextEditingController();

  void signUp(String firstname, String lastname, String username, String email, String password) async{

    var bytes = utf8.encode(password);

    // Calculate the SHA256 hash
    var digest = sha256.convert(bytes);

    String hashPassword = digest.toString();

    NetworkingHelper networkingHelper = NetworkingHelper(urlSuffix: "api/user");

    var response = await networkingHelper.postSignUpData(firstname, lastname, username, email, hashPassword);

    if(response['status'] == 1) {
      final now = DateTime.now();
      final formattedDate = DateFormat("yyyy/MM/dd").format(now);

      final SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setBool("isLoggedIn", true);
      prefs.setInt("userId", response["userId"]);
      prefs.setString("loginDate", formattedDate);

      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return HomePage();
      }));
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sign Up Failed, Please Retry'),
          duration: const Duration(seconds: 3), // Optional: Set duration
          behavior: SnackBarBehavior.floating, // Optional: Set behavior
        ),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: kPieNavy,
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 70.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 80),
                  child: Image.asset("images/PIE Parking Icon.png"),
                ),
                Text(
                  "PIE",
                  style: TextStyle(
                    color: kPieWhite,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w900,
                    fontSize: 40.0,
                  ),
                ),
                Text(
                  "PARKING AS EASY AS...",
                  style: TextStyle(
                    color: kPieWhite,
                    fontFamily: "Poppins ExtraLight",
                    fontSize: 20.0,
                    fontWeight: FontWeight.w100,
                  ),
                ),
                SizedBox(height: 20.0,),
                Container(
                  margin: EdgeInsets.all(10.0),
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: kPieWhite,
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Let's Get Started...",
                          style: TextStyle(
                            color: kPiePurple,
                            fontSize: 30.0,
                            fontWeight: FontWeight.w900,
                            fontFamily: "Poppins",
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 8.0),
                          child: TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'First Name',
                              hintText: 'e.g., John',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.text,
                            // The validator receives the text that the user has entered.
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }else if(value.contains(RegExp(r'[^A-z ]'))){
                                return 'Only letters A to z accepted';
                              }else {
                                return null;
                              }
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 8.0),
                          child: TextFormField(
                            controller: _surnameController,
                            decoration: InputDecoration(
                              labelText: 'Last Name',
                              hintText: 'e.g., Doe',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.text,
                            // The validator receives the text that the user has entered.
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }else if(value.contains(RegExp(r'[^A-z ]'))){
                                return 'Only letters A to z accepted';
                              }else {
                                return null;
                              }
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 8.0),
                          child: TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              hintText: 'e.g., JohnDoe123',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.text,
                            // The validator receives the text that the user has entered.
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }else if(value.contains(RegExp(r'^([A-z0-9\.-_])$'))){
                                return 'Invalid username, try another';
                              }else {
                                return null;
                              }
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 8.0),
                          child: TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'e.g., john@example.com',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            // The validator receives the text that the user has entered.
                            validator: (value) {

                              if (value == null || value.isEmpty) {
                                return 'Please enter an email address';
                              }else if(!RegExp(r'^([A-z0-9]+)(@)([A-z]+)(\.)([A-z\.]+)$').hasMatch(value)){
                                return 'Invalid email address';
                              }else {
                                return null;
                              }
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 8.0),
                          child: TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Create a password',
                              hintText: 'P@ssw0rd',
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                            keyboardType: TextInputType.visiblePassword,
                            // The validator receives the text that the user has entered.
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }else if(!RegExp(r'(?=.*[!@#$%^&*])(?=.*[0-9])(?=.*[A-Z])[A-z0-9!@#$%^&*]{8,}$').hasMatch(value)){
                                return 'Use capitals, numbers & symbols';
                              }
                              return null;
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 8.0),
                          child: TextFormField(
                            controller: _repeatPasswordController,
                            decoration: InputDecoration(
                              labelText: 'Repeat password',
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                            keyboardType: TextInputType.visiblePassword,
                            // The validator receives the text that the user has entered.
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }else if(value != _passwordController.text){
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 8.0),
                          child: ElevatedButton(
                            style: kPieElevatedButtonStyle,
                            onPressed: () {
                              // Validate returns true if the form is valid, or false otherwise.
                              if (_formKey.currentState!.validate()) {
                                signUp(_nameController.text, _surnameController.text, _usernameController.text, _emailController.text, _passwordController.text);
                              }
                            },
                            child: const Text('Sign Up'),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
