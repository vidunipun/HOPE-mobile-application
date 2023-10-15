import 'package:auth/screens/authentication/register.dart';
import 'package:auth/screens/authentication/sign_in.dart';
import 'package:flutter/material.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({super.key});

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool singingPage = true;

  //toggle pages
  void switchPages() {
    setState(() {
      singingPage = !singingPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (singingPage == true) {
      return SingIn(toggle: switchPages);
    } else {
      return Register(toggle: switchPages);
    }
  }
}
