import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/styles.dart';
import '../../services/auth.dart';

class Register extends StatefulWidget {
  final Function toggle;

  const Register({Key? key, required this.toggle}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthServices _auth = AuthServices();

  final _formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  String error = "";
  String fname = "";
  String lname = "";
  String mobilenumber = "";
  String address = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: startBackgroundBlack,
      appBar: AppBar(
        title: const Text("Register Here"),
        backgroundColor: startBackgroundBlack,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              color: Colors.white,
            ),
            child: Column(
              children: [
                // Register text at the top
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    "Register",
                    style: signInRegisterText3,
                  ),
                ),
                const SizedBox(height: 10),
                //description
                const Text(
                  "description",
                  style: descriptionStyle,
                ),
                Center(
                  child: Image.asset(
                    'assets/register.png',
                    height: 100,
                    width: 100,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        //email
                        TextFormField(
                          style: const TextStyle(color: Colors.black),
                          decoration: textInputdecorataion,
                          validator: (val) => val?.isEmpty == true
                              ? "Enter a valid email"
                              : null,
                          onChanged: (val) {
                            setState(() {
                              email = val;
                            });
                          },
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        //first name
                        TextFormField(
                          style: const TextStyle(color: Colors.black),
                          decoration: textInputdecorataion.copyWith(
                              hintText: "First Name"),
                          validator: (val) => val?.isEmpty == true
                              ? "Enter the first name"
                              : null,
                          onChanged: (val) {
                            setState(() {
                              fname = val;
                            });
                          },
                        ),

                        const SizedBox(
                          height: 7,
                        ),
                        //last name
                        TextFormField(
                          style: const TextStyle(color: Colors.black),
                          decoration: textInputdecorataion.copyWith(
                              hintText: "Last Name"),
                          validator: (val) => val?.isEmpty == true
                              ? "Enter the last name"
                              : null,
                          onChanged: (val) {
                            setState(() {
                              lname = val;
                            });
                          },
                        ),

                        const SizedBox(
                          height: 7,
                        ),
                        //mobile number
                        TextFormField(
                          style: const TextStyle(color: Colors.black),
                          decoration: textInputdecorataion.copyWith(
                              hintText: "Mobile Number"),
                          validator: (val) => val?.isEmpty == true
                              ? "Enter the mobile number"
                              : null,
                          onChanged: (val) {
                            setState(() {
                              mobilenumber = val;
                            });
                          },
                        ),

                        const SizedBox(
                          height: 7,
                        ),
                        //address
                        TextFormField(
                          style: const TextStyle(color: Colors.black),
                          decoration: textInputdecorataion.copyWith(
                              hintText: "Address"),
                          validator: (val) =>
                              val?.isEmpty == true ? "Enter the address" : null,
                          onChanged: (val) {
                            setState(() {
                              address = val;
                            });
                          },
                        ),

                        const SizedBox(
                          height: 7,
                        ),
                        //password
                        TextFormField(
                          style: const TextStyle(color: Colors.black),
                          decoration: textInputdecorataion.copyWith(
                            hintText: "password",
                          ),
                          validator: (val) =>
                              val!.length < 6 ? "Enter a valid password" : null,
                          onChanged: (val) {
                            setState(() {
                              password = val;
                            });
                          },
                        ),
                        // Divider between password form and social media login
                        const SizedBox(height: 20),
                        const Divider(
                          color: Colors.black,
                          height: 1,
                          thickness: 1,
                          indent: 40,
                          endIndent: 40,
                        ),
                        // Social Media Login
                        const SizedBox(height: 20),
                        const Text(
                          "Login with social accounts",
                          style: signInRegisterText2,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              //sign in with Facebook
                              onTap: () {},
                              child: Center(
                                child: Image.asset(
                                  'assets/facebook.jpg',
                                  height: 50,
                                  width: 50,
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            GestureDetector(
                              //sign in with Google
                              onTap: () {},
                              child: Center(
                                child: Image.asset(
                                  'assets/google.png',
                                  height: 50,
                                  width: 50,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        // Do you have an account? LOGIN
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Do you have an account?",
                              style: signInRegisterText2,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                              //go to the signIn page
                              onTap: () {
                                widget.toggle();
                              },
                              child: const Text(
                                "LOGIN",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Register button
                        const SizedBox(height: 10),
                        GestureDetector(
                          //method for register
                          onTap: () async {
                            dynamic result =
                                await _auth.registerWithEmailAndPassword(
                                    email,
                                    fname,
                                    lname,
                                    mobilenumber,
                                    address,
                                    password);

                          },
                          child: Container(
                            height: 40,
                            width: 200,
                            decoration: BoxDecoration(
                              color: startButtonGreen,
                              borderRadius: BorderRadius.circular(100),
                              border:
                                  Border.all(width: 3, color: startButtonGreen),
                            ),
                            child: const Center(
                              child: Text(
                                "REGISTER",
                                style: startButtonText,
                              ),
                            ),
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
