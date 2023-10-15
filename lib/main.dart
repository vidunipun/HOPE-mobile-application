import 'package:auth/models/UserModel.dart';
import 'package:auth/services/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'get_started/get_started.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserModel?>.value(
      value: AuthServices().user,
      initialData: UserModel(uid: ""),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: GetStarted(),
        //home: EditProfilePage(),
      ),
    );
  }
}
