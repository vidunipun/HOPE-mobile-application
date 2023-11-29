// ignore_for_file: file_names, use_key_in_widget_constructors, deprecated_member_use

import 'package:auth/request&donation/donation.dart';
import 'package:auth/request&donation/request.dart';
import 'package:flutter/material.dart';

import '../../constants/colors.dart';

class SelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          buttonbackground, // Set the background color to black
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'What do you want to post?\n',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: 'Otomanopee One',
                fontWeight: FontWeight.w400,
                height: 0,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle Request button press
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RequestPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: const Color(0xFF0BFFFF), // Set the button color to #0BFFFF
              ),
              child: const Text(
                'Request ',
                style: TextStyle(
                  color: Color(0xFF0D0D0D),
                  fontSize: 20,
                  fontFamily: 'Otomanopee One',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                //Handle Donation button press
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DonationPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: const Color(0xFF0BFFFF), // Set the button color to #0BFFFF
              ),
              child: const Text(
                ' Donation',
                style: TextStyle(
                  color: Color(0xFF121312),
                  fontSize: 20,
                  fontFamily: 'Otomanopee One',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
