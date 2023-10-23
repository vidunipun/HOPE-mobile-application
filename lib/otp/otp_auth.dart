// ignore_for_file: unused_local_variable, library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_auth/email_auth.dart';

class EmailOTPPage extends StatefulWidget {
  const EmailOTPPage({super.key});

  @override
  _EmailOTPPageState createState() => _EmailOTPPageState();
}

class _EmailOTPPageState extends State<EmailOTPPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController otpController = TextEditingController();

  bool otpSent = false;
  @override
  void initState() {
    super.initState();
    getCurrentUserEmail().then((email) {
      if (email != null) {
        setState(() {
          emailController.text = email;
        });
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    otpController.dispose();
    super.dispose();
  }

  Future<String?> getCurrentUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
            .instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          return userDoc.data()!['email'];
        }
      } catch (e) {
        print('Error getting user email: $e');
      }
    }

    return null;
  }

Future<void> sendOTP(String emailAddress) async {
  // Create an instance of the EmailAuth class.
  var emailAuth = EmailAuth(sessionName: 'test');

  // Send the OTP.
  var res = await emailAuth.sendOtp(
    recipientMail: emailAddress,
    otpLength: 6, // You can adjust the OTP length as needed
  );
}

  void verifyOTP() {
    // Implement the logic to verify the entered OTP here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email OTP Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Enter Email',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    sendOTP("maneelakshan@gmail.com");
                  },
                ),
              ),
              //readOnly: true,
            ),
            const SizedBox(height: 16.0),

              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Enter OTP',
                ),
              ),
            const SizedBox(height: 16.0),
            if (otpSent)
              ElevatedButton(
                onPressed: () {
                  verifyOTP();
                },
                child: const Text('Verify OTP'),
              ),
          ],
        ),
      ),
    );
  }
}
