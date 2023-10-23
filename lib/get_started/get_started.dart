// ignore_for_file: library_private_types_in_public_api

import 'package:auth/constants/colors.dart';
import 'package:flutter/material.dart';
import '../constants/styles.dart';
import '../screens/wrapper.dart';

class GetStarted extends StatefulWidget {
  const GetStarted({Key? key}) : super(key: key);

  @override
  _GetStartedState createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> {
  final PageController _pageController = PageController(initialPage: 0);
  final List<String> imagePaths = [
    'assets/start1.png',
    'assets/start2.png',
    'assets/start3.png',
    'assets/start4.png',
  ];
  final List<String> titles = [
    'CONNECTS PEOPLE IN NEED WITH GENEROUS DONORS',
    'ENABLE QUICK AND EASY DONATION',
    'HELP USERS FIND NEARBY CHARITY EVENTS',
    'ALLOWS COMMUNITY BUILDING BASED ON THEIR RATINGS',
  ];
  int currentIndex = 0;

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
                    for (int i = 0; i < imagePaths.length; i++)
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: i == currentIndex ? startButtonGreen : Colors.transparent,
                          ),
                          ),
                          ),
                  ],
                  ),
                  ),
                  ),

                                      Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: imagePaths.length,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        imagePaths[index],
                        height: 300,
                        width: 300,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 40),
                      Center(
                        child: Text(
                          titles[index],
                          style: startText,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 90),
             Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () {
                  if (currentIndex < imagePaths.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                         builder: (context) => const Wrapper(),
                       
                      ),
                    );
                            }
                },
                  
                child: Container(
                  height: 40,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: startButtonGreen,
                  ),
                  child: Center(
                    child: Text(
                      currentIndex < imagePaths.length - 1 ? 'Get Started' : 'Get Started',
                      style: startButtonText,
                  
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
