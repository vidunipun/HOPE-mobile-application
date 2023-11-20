// ignore_for_file: camel_case_types, avoid_print

import 'package:auth/screens/home/wall/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class payment extends StatefulWidget {
  final String cardNo;
  final String uid;
  final String postid;

  const payment(
      {required this.cardNo, Key? key, required this.uid, required this.postid, String? usercard})
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
          int afterpay;

          if (intbalance != null) {
            if (intpay != null) {
              afterpay = intbalance - intpay;
              print(afterpay);

              //update sender Bank
              DocumentReference<Map<String, dynamic>> documentReference =
                  FirebaseFirestore.instance.collection('Bank').doc(userUID);
              documentReference.update({
                'balance': afterpay.toString(),
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

  //update tonow
  Future<void> tonow() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .collection('requests')
              .doc(
                  widget.postid) // Assuming postid uniquely identifies the post
              .get();

      if (documentSnapshot.exists) {
        final Map<String, dynamic>? requestData = documentSnapshot.data();
        if (requestData != null) {
          int? rintAmount = int.tryParse(amountController.text);

          if (rintAmount != null) {
            // Calculate the new to_now value by adding rintAmount to the existing value
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
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: cardNumberController,
              decoration: const InputDecoration(labelText: 'Card Number'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                await paycash();

                await rpaycash();

                await tonow();

                // ignore: use_build_context_synchronously
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Home(),
                    ));
              },
              child: const Text("Pay"),
            )
          ],
        ),
      ),
    );
  }
}
