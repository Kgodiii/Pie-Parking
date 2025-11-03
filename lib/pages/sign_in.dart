
import 'package:flutter/material.dart';
import 'package:pie/resources/style_constants.dart';
import 'package:pie/services/networking.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:pie/pages/home.dart';
import 'package:intl/intl.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String errorMessage = "";

  void login(String username, String password) async{

    var bytes = utf8.encode(password);

    // Calculate the SHA256 hash
    var digest = sha256.convert(bytes);

    String hashPassword = digest.toString();

    NetworkingHelper networkingHelper = NetworkingHelper(urlSuffix: "api/user");

    var response = await networkingHelper.postLoginData(username, hashPassword);

    if(response["userId"] == -1){
      setState(() {
        errorMessage = "Invalid login information";
      });
    }else{
      final now = DateTime.now();
      final formattedDate = DateFormat("yyyy/MM/dd").format(now);

      final SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setBool("isLoggedIn", true);
      prefs.setInt("userId", response["userId"]);
      prefs.setString("loginDate", formattedDate);

      Navigator.push(context, MaterialPageRoute(builder: (context) {return HomePage();}));
    }

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: kPieNavy,
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
        body: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/PIE Background.png"), // Path to your image
                fit: BoxFit.cover, // Adjust how the image fits the container
              ),
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(50.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: kPieWhite,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: kShadowColor,
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              "Log In",
                              style: kPieHeadingStyle,
                            ),
                            Text(
                              errorMessage,
                              style: TextStyle(
                                color: Color(0xFFFF0000),
                                fontSize: 14.0,
                                fontFamily: "Poppins ExtraLight",
                              ),
                            ),
                            // Add TextFormFields and ElevatedButton here.
                            Container(
                              margin: EdgeInsets.only(top: 8.0),
                              child: TextFormField(
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  labelText: 'Enter your username',
                                  hintText: 'e.g., JoePrice24',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.text,
                                // The validator receives the text that the user has entered.
                                validator: (value) {

                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a username';
                                  }else if(!RegExp(r'^[A-z0-9-\.]*$').hasMatch(value)){
                                    return 'Please enter a valid username';
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
                                  labelText: 'Enter your password',
                                  hintText: 'Password',
                                  border: OutlineInputBorder(),
                                ),
                                obscureText: true,
                                keyboardType: TextInputType.visiblePassword,
                                // The validator receives the text that the user has entered.
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  // }else if(!RegExp(r'(?=.*[!@#$%^&*])(?=.*[0-9])(?=.*[A-Z])[A-z0-9!@#$%^&*]{8,}$').hasMatch(value)){
                                  //   return 'Invalid password';
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
                                    // If the form is valid, display a snackbar. In the real world,
                                    // you'd often call a server or save the information in a database.
                                    // ScaffoldMessenger.of(context).showSnackBar(
                                    //   const SnackBar(
                                    //     content: Center(
                                    //       child: Text(
                                    //         'Success!',
                                    //         style: TextStyle(
                                    //           color: kDegasityWhite,
                                    //         ),
                                    //       ),
                                    //     ),
                                    //     backgroundColor: Colors.green,
                                    //   ),
                                    // );
                                    login(_usernameController.text, _passwordController.text);
                                  }
                                },
                                child: Text('Log In'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}