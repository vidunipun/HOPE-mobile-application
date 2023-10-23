
import 'package:auth/models/UserModel.dart';
import 'package:auth/screens/authentication/authenticate.dart';
import 'package:auth/screens/home/wall/home.dart';




import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});
  


  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);
    if (user == null) {
      return const Authenticate();
    } else {
      return   const Home();
  
    }
  }
}
