import 'package:auth/request&donation/donation.dart';
import 'package:auth/request&donation/request.dart';
import 'package:flutter/material.dart';

import '../../constants/colors.dart';

class SelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: startBackgroundBlack,
      body: Column(
        children: [
          // Add the button and text at the top
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        tooltip: 'Back',
                      ),
                      Text(
                        'Add Post',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'What do you want to post?\n',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Otomanopee One',
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Handle Request button press
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RequestPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF0BFFFF),
                  ),
                  child: Text(
                    'Request',
                    style: TextStyle(
                      color: Color(0xFF0D0D0D),
                      fontSize: 20,
                      fontFamily: 'Otomanopee One',
                      fontWeight: FontWeight.w400,
                      height: 0,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    //Handle Donation button press
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DonationPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF0BFFFF),
                  ),
                  child: Text(
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
        ],
      ),
    );
  }
}
