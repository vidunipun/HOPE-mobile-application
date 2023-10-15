import 'package:flutter/material.dart';
import 'get_started_page4.dart';
import '../constants/colors.dart';
import '../constants/styles.dart';

class GetStartedPage3 extends StatelessWidget {
  const GetStartedPage3({super.key});

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
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: startButtonGreen,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(),
                    ),
                  ],
                ),
              ),
            ),
            Image.asset(
              'assets/start3.png',
              height: 300,
              width: 300,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 40),
            const Center(
              child: Text(
                'HELP USERS FIND NEARBY CHARITY EVENTS',
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
                        builder: (context) => const GetStartedPage4(),
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
