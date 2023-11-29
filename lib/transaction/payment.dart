// ignore_for_file: camel_case_types, avoid_print

import 'package:auth/constants/colors.dart';
import 'package:auth/screens/home/wall/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class payment extends StatefulWidget {
  final String cardNo;
  final String uid;
  final String postid;

  const payment(
      {required this.cardNo,
      Key? key,
      required this.uid,
      required this.postid,
      String? usercard})
      : super(key: key);

  @override
  State<payment> createState() => _paymentState();
}

class _paymentState extends State<payment> {
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  int isCardValid = 0;

  String userUID = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    print(widget.cardNo);

    cardNumberController.text = widget.cardNo;

    super.initState();
  }

  //paying //update sender
  Future<void> paycash() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .collection('Bank')
              .doc(userUID)
              .get();

      if (documentSnapshot.exists) {
        final Map<String, dynamic>? userData = documentSnapshot.data();
        if (userData != null) {
          final String balance = userData['balance'];
          print(balance);
          int? intbalance = int.tryParse(balance);
          int? intpay = int.tryParse(amountController.text);

          if (intbalance != null && intpay != null) {
            // Calculate the updated balance after the payment
            int afterpay = intbalance - intpay;
            print(afterpay);

            // Calculate points to be incremented
            double pointsIncrement = intpay * 0.001;

            // Update sender's Bank balance
            DocumentReference<Map<String, dynamic>> senderDocumentReference =
                FirebaseFirestore.instance.collection('Bank').doc(userUID);
            senderDocumentReference.update({
              'balance': afterpay.toString(),
            }).then((value) {
              print('Balance updated successfully.');
            }).catchError((error) {
              print('Error updating balance: $error');
            });

            // Increment points in the users collection
            DocumentReference<Map<String, dynamic>> userDocumentReference =
                FirebaseFirestore.instance.collection('users').doc(userUID);
            userDocumentReference.update({
              'points': FieldValue.increment(pointsIncrement),
            }).then((value) {
              print('Points incremented successfully.');
            }).catchError((error) {
              print('Error incrementing points: $error');
            });
            // After updating points, assign ranks
            print("before");
            assignRanks(userUID);
            print("after");
          }
        }
      } else {
        print('User details not found.');
      }
    } catch (e) {
      print('Error checking details: $e');
    }
    print(widget.cardNo);
  }

  //update reciver
  Future<void> rpaycash() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .collection('Bank')
              .doc(widget.uid)
              .get();

      if (documentSnapshot.exists) {
        final Map<String, dynamic>? userData = documentSnapshot.data();
        if (userData != null) {
          final String balance = userData['balance'];
          print(balance);
          int? rintbalance = int.tryParse(balance);
          int? rintpay = int.tryParse(amountController.text);
          int rafterpay;

          if (rintbalance != null) {
            if (rintpay != null) {
              rafterpay = rintbalance + rintpay;
              print(rafterpay);

              //update reciver Bank
              DocumentReference<Map<String, dynamic>> documentReference =
                  FirebaseFirestore.instance.collection('Bank').doc(widget.uid);
              documentReference.update({
                'balance': rafterpay.toString(),
              }).then((value) {
                print('Field updated successfully.');
              }).catchError((error) {
                print('Error updating field: $error');
              });
            }
          }
        }
      } else {
        print('card details are nothing match.');
      }
    } catch (e) {
      print('Error checking card details: $e');
    }
    print(widget.cardNo);
  }

  Future<void> assignRanks(String userId) async {
    // Fetch the user's document
    DocumentReference<Map<String, dynamic>> userDocumentReference =
        FirebaseFirestore.instance.collection('users').doc(userId);

    try {
      // Use a transaction to ensure atomicity
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot<Map<String, dynamic>> userSnapshot =
            await userDocumentReference.get();

        // Get the 'points' value from the user's document
        int userPoints = (userSnapshot.data()?['points'] as num?)?.toInt() ?? 0;

        //  assign ranks based on points
        String rank;
        if (userPoints > 100) {
          rank = 'Gold';
        } else if (userPoints > 50) {
          rank = 'Silver';
        } else {
          rank = 'Bronze';
        }

        // Update or create the 'rank' field in the user's document
        transaction.set(
          userDocumentReference,
          {'rank': rank},
          SetOptions(merge: true),
        );

        print('Rank assigned or updated successfully: $rank');
      });
    } catch (error) {
      print('Error assigning or updating rank: $error');
    }
  }

  //update tonow
  Future<void> tonow() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .collection('requests')
              .doc(widget.postid)
              .get();

      if (documentSnapshot.exists) {
        final Map<String, dynamic>? requestData = documentSnapshot.data();
        if (requestData != null) {
          int? rintAmount = int.tryParse(amountController.text);

          if (rintAmount != null) {
            int? currentToNow = requestData['to_now'];
            int newToNow =
                currentToNow != null ? currentToNow + rintAmount : rintAmount;

            // Update the to_now field in the requests collection
            DocumentReference<Map<String, dynamic>> documentReference =
                FirebaseFirestore.instance
                    .collection('requests')
                    .doc(widget.postid);
            documentReference.update({
              'to_now': newToNow,
            }).then((value) {
              print('to_now field updated successfully.');
            }).catchError((error) {
              print('Error updating to_now field: $error');
            });
          }
        }
      } else {
        print('Post not found.');
      }
    } catch (e) {
      print('Error checking post details: $e');
    }
  }

  @override
  void dispose() {
    cardNumberController.dispose();
    amountController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: buttonbackground,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(
                  height: 15,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  tooltip: 'Back',
                ),
                const Text(
                  'Payment',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
            TextField(
              controller:
                  cardNumberController, // Controller to control the text field's content.
              decoration: const InputDecoration(
                labelText:
                    'Card Number', // Label text displayed above the text field.
                labelStyle:
                    TextStyle(color: Colors.white), // Style for the label text.
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors
                          .white), // Border color when the field is enabled.
                ),
              ),
              style: const TextStyle(
                color: Colors.white, // Text color of the input.
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller:
                  amountController, // Controller to control the text field's content.
              decoration: const InputDecoration(
                labelText:
                    'Amount', // Label text displayed above the text field.
                labelStyle:
                    TextStyle(color: Colors.white), // Style for the label text.
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors
                          .white), // Border color when the field is enabled.
                ),
              ),
              style: const TextStyle(
                color: Colors.white, // Text color of the input.
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Get the current user
                  User? currentUser = FirebaseAuth.instance.currentUser;

                  if (currentUser != null) {
                    // Retrieve the user's account balance
                    DocumentSnapshot<Map<String, dynamic>>
                        bankDocumentSnapshot = await FirebaseFirestore.instance
                            .collection('Bank')
                            .doc(currentUser.uid)
                            .get();

                    if (bankDocumentSnapshot.exists) {
                      // Extract the balance from the document
                      int? accountBalance =
                          int.tryParse(bankDocumentSnapshot.data()?['balance']);

                      // Convert the amountController.text to an integer
                      int? enteredAmount = int.tryParse(amountController.text);

                      if (accountBalance != null && enteredAmount != null) {
                        // Check if the account balance is greater than the entered amount
                        if (accountBalance >= enteredAmount) {
                          // Execute the payment-related functions
                          await paycash();
                          await rpaycash();
                          await tonow();

                          // Navigate to the Home page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Home(),
                            ),
                          );
                        } else {
                          // if the account balance is insufficient
                          print('Insufficient account balance.');
                        }
                      } else {
                        // if balance or enteredAmount is null
                        print('Error parsing balance or entered amount.');
                      }
                    } else {
                      // if the Bank document does not exist
                      print('Bank document not found.');
                    }
                  } else {
                    // if there is no current user
                    print('No current user.');
                  }
                } catch (e) {
                  print('Error checking account balance: $e');
                }
              },
              child: const Text("Pay"),
            )
          ],
        ),
      ),
    );
  }
}
