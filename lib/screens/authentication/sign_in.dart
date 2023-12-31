import 'package:auth/constants/colors.dart';
import 'package:auth/constants/styles.dart';
import 'package:auth/services/auth.dart';
import 'package:flutter/material.dart';

class SingIn extends StatefulWidget {
  //function
  final Function toggle;

  const SingIn({Key? key, required this.toggle}) : super(key: key);

  @override
  State<SingIn> createState() => _SingInState();
}

class _SingInState extends State<SingIn> {
//refference for the Authservice class
  final AuthServices _auth = AuthServices();
//form key
  final _formKey = GlobalKey<FormState>();
//email password states
  String email = "";
  String password = "";
  String error = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: buttonbackground,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: buttonbackground,
                ),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        "Log In",
                        style: signInRegisterText3,
                      ),
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
                              decoration: const InputDecoration(
                                  hintText: "email",
                                  hintStyle: TextStyle(color: Colors.white),
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white))),
                              validator: (val) => val?.isEmpty == true
                                  ? "Enter a valid email"
                                  : null,
                              onChanged: (val) {
                                setState(() {
                                  email = val;
                                });
                              },
                            ),
                            //password
                            const SizedBox(
                              height: 14,
                            ),
                            TextFormField(
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                  hintText: 'password',
                                  hintStyle: TextStyle(color: Colors.white),
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white))),
                              obscureText: true,
                              validator: (val) => val!.length < 6
                                  ? "Enter a valid password"
                                  : null,
                              onChanged: (val) {
                                setState(
                                  () {
                                    password = val;
                                  },
                                );
                              },
                            ),
                            //google
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              error,
                              style: const TextStyle(color: Colors.red),
                            ),

                            //register page
                            const SizedBox(
                              height: 15,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Do not have an account",
                                  style: signInRegisterText2,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                  //go to the register page
                                  onTap: () {
                                    widget.toggle();
                                  },
                                  child: const Text(
                                    "REGISTER",
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ],
                            ),
                            //button
                            const SizedBox(
                              height: 20,
                            ),
                            GestureDetector(
                              //method for log in
                              onTap: () async {
                                dynamic result =
                                    await _auth.signInUsingEmailAndPassword(
                                        email, password);
                                if (result == null) {
                                  setState(
                                    () {
                                      error =
                                          "User name or password is not matching ";
                                    },
                                  );
                                }
                              },
                              child: Container(
                                height: 40,
                                width: 200,
                                decoration: BoxDecoration(
                                    color: startButtonGreen,
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                        width: 3, color: startButtonGreen)),
                                child: const Center(
                                  child:
                                      Text("LOG IN", style: (startButtonText)),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              //method for log in
                              onTap: () async {
                                dynamic result =
                                    await _auth.signInUsingEmailAndPassword(
                                        email, password);
                                if (result == null) {
                                  setState(
                                    () {
                                      error =
                                          "User name or password is not matching ";
                                    },
                                  );
                                }
                              },
                              // child: GestureDetector(
                              //   //method for loggin as guest
                              //   onTap: () async {
                              //     await _auth.signInAnonoymously();
                              //   },
                              //   child: Container(
                              //     height: 40,
                              //     width: 200,
                              //     decoration: BoxDecoration(
                              //         color: startButtonGreen,
                              //         borderRadius: BorderRadius.circular(100),
                              //         border: Border.all(
                              //             width: 3, color: startButtonGreen)),
                              //     child: const Center(
                              //         child: Text(
                              //       "LOG IN AS GUEST",
                              //       style: (startButtonText),
                              //     )),
                              //   ),
                              // ),
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
        ));
  }
}
