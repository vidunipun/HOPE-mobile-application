import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CardDetailsPage extends StatefulWidget {
  @override
  _CardDetailsPageState createState() => _CardDetailsPageState();
}

class _CardDetailsPageState extends State<CardDetailsPage> {
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController expDateController = TextEditingController();
  TextEditingController cvvController = TextEditingController();
  TextEditingController payController = TextEditingController();
  int isCardValid = 0;

  String userUID = FirebaseAuth.instance.currentUser?.uid ?? '';
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      fetchUserCard();
    });
    super.initState();
  }

  @override
  void dispose() {
    cardNumberController.dispose();
    expDateController.dispose();
    cvvController.dispose();
    payController.dispose();
    super.dispose();
  }

  //paying
  Future<void> paycash() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .collection('bank')
              .doc(userUID)
              .get();

      if (documentSnapshot.exists) {
        final Map<String, dynamic>? userData = documentSnapshot.data();
        if (userData != null) {
          final String balance = userData['balance'];
          print(balance);
          int? intbalance = int.tryParse(balance);
          int? intpay = int.tryParse(payController.text);
          int afterpay;
          if (intbalance != null) {
            if (intpay != null) {
              afterpay = intbalance - intpay;
              print(afterpay);
            }
          }
        }
      } else {
        print('card details are nothing match.');
      }
    } catch (e) {
      print('Error checking card details: $e');
    }
  }

  Future<void> checkCardDetails() async {
    String cardNumber = cardNumberController.text;
    String expDate = expDateController.text;
    String cvv = cvvController.text;

    try {
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .collection('bank')
              .doc(userUID)
              .get();

      if (documentSnapshot.exists) {
        final Map<String, dynamic>? userData = documentSnapshot.data();
        if (userData != null) {
          final String? storedCardNumber = userData['card_no'];
          final String? storedExpDate = userData['exp_date'];
          final String? storedCVV = userData['cvv'];

          if (storedCardNumber != null &&
              storedExpDate != null &&
              storedCVV != null) {
            if (storedCardNumber == cardNumber &&
                storedExpDate == expDate &&
                storedCVV == cvv) {
              setState(() {
                isCardValid = 1;
              });

              print('Card details are valid. Proceed with the transaction.');
              await FirebaseFirestore.instance.collection('cards').add({
                'card_no': cardNumber,
                'exp_date': expDate,
                'cvv': cvv,
              });
            } else {
              setState(() {
                isCardValid = 2;
              });
              print(
                  'Card details do not match the records in the "bank" collection.');
            }
          } else {
            setState(() {
              isCardValid = 2;
            });
            print('Card details in user data are missing.');
          }
        }
      } else {
        print('User document does not exist in the "bank" collection.');
      }
    } catch (e) {
      print('Error checking card details: $e');
    }
  }

  Future<void> fetchUserCard() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;
      CollectionReference users =
          FirebaseFirestore.instance.collection('cards');

      try {
        DocumentSnapshot userSnapshot = await users.doc(uid).get();
        if (userSnapshot.exists) {
          Map<String, dynamic> userData =
              userSnapshot.data() as Map<String, dynamic>;

          cardNumberController.text = userData['card_no'] ?? '';
          expDateController.text = userData['exp_date'] ?? '';
          cvvController.text = userData['cvv'] ?? '';
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Card Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: cardNumberController,
              decoration: InputDecoration(labelText: 'Card Number'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: expDateController,
              decoration: InputDecoration(labelText: 'Expiration Date (MM/YY)'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: cvvController,
              decoration: InputDecoration(labelText: 'CVV'),
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                checkCardDetails();
              },
              child: Text('Submit'),
            ),
            SizedBox(height: 16.0),
            Text(
              isCardValid == 1
                  ? 'Card details are added.'
                  : isCardValid == 2
                      ? 'Card details do not match'
                      : 'enter details',
              style: TextStyle(
                color: isCardValid == 1 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            // TextField(
            //   controller: payController,
            //   decoration: InputDecoration(labelText: 'Pay'),
            // ),
            // ElevatedButton(onPressed: paycash, child: Text("Pay"))
          ],
        ),
      ),
    );
  }
}
