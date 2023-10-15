import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/styles.dart';
import '../screens/wrapper.dart';

class GetStartedPage4 extends StatelessWidget {
  const GetStartedPage4({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: startBackgroundBlack,
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.only(bottom: 17),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.white,
                ),
                height: 8,
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: startButtonGreen,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                  ],
                ),
              ),
            ),
            Image.asset(
              'assets/start4.png',
              height: 300,
              width: 300,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 40),
            const Center(
              child: Text(
                'ALLOWS COMMUNITY BUILDING BASED ON THEIR RATINGS',
                style: startText,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 90),
            Expanded( 
              child: Align(
                alignment: Alignment.bottomCenter, // Align to the bottom center
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Wrapper(),
                      ),
                    );
                  },
                child: Container(
                  height: 40,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: startButtonGreen,
                  ),
                  child: const Center(
                    child: Text(
                      "Get Started",
                      style: (startButtonText),
                    ),
                  ),
                ),
              ),
            ),
            ),  
          ],
        ),
      ),
    );
  }
}
