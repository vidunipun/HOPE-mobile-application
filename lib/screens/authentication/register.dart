// ignore_for_file: unused_field

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
  String idnumber = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: buttonbackground,
      // appBar: AppBar(
      //   title: const Text("Register Here"),
      //   backgroundColor: startBackgroundBlack,
      // ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              color: buttonbackground,
            ),
            child: Column(
              children: [
                // Register text at the top
                const Padding(
                  padding: EdgeInsets.only(top: 29),
                  child: Text(
                    "Register",
                    style: signInRegisterText3,
                  ),
                ),
                const SizedBox(height: 10),
                //description

                Center(
                  child: ClipOval(
                    child: Image.asset(
                      'assets/register.png',
                      height: 100,
                      width: 100,
                    ),
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
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              hintText: "Email",
                              hintStyle: TextStyle(color: Colors.white),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white))),
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
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              hintText: "First Name",
                              hintStyle: TextStyle(color: Colors.white),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white))),
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
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              hintText: "Last Name",
                              hintStyle: TextStyle(color: Colors.white),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white))),
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
                        //id number
                        TextFormField(
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              hintText: "ID Number",
                              hintStyle: TextStyle(color: Colors.white),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white))),
                          validator: (val) => val?.isEmpty == true
                              ? "Enter the Id number"
                              : null,
                          onChanged: (val) {
                            setState(() {
                              idnumber = val;
                            });
                          },
                        ),
                        //mobile number
                        TextFormField(
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              hintText: "Mobile Number",
                              hintStyle: TextStyle(color: Colors.white),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white))),
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
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              hintText: "Address",
                              hintStyle: TextStyle(color: Colors.white),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white))),
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
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Password",
                            hintStyle: TextStyle(color: Colors.white),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          obscureText: true,
                          validator: (val) {
                            if (val!.length < 10) {
                              return "Password should be at least 10 characters";
                            }
                            // Check if the password contains at least one number
                            if (!val.contains(RegExp(r'\d'))) {
                              return "Password must contain at least one number";
                            }
                            return null; // Password is valid
                          },
                          onChanged: (val) {
                            setState(() {
                              password = val;
                              print("Password: $password");
                            });
                          },
                        ),

                        // Divider between password form and social media login
                        const SizedBox(height: 25),
                        const Divider(
                          color: Colors.white,
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
                                    password,
                                    idnumber);
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
