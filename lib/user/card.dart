import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

class AddCardDetailsPage extends StatefulWidget {
  const AddCardDetailsPage({Key? key}) : super(key: key);

  @override
  _AddCardDetailsPageState createState() => _AddCardDetailsPageState();
}

class _AddCardDetailsPageState extends State<AddCardDetailsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _cardNumberController = TextEditingController();
  TextEditingController _expiryDateController = TextEditingController();
  TextEditingController _cvvController = TextEditingController();

  bool _cardDetailsCorrect = false;
    Future<Map<String, dynamic>> checkCardDetails(String cardNumber, String expiryDate, String cvc) async {
    
    String uri = "http://192.168.8.100/mysqlflutter/check_card.php";
    var res = await http.post(Uri.parse(uri), body: {
      "card_number": cardNumber,
      "expiry_date": expiryDate,
      "cvc": cvc,
    });
    return jsonDecode(res.body);
  }
  @override
void dispose() {
  _cardNumberController.dispose();
  _expiryDateController.dispose();
  _cvvController.dispose();
  super.dispose();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Card Details"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _cardNumberController,
                decoration: InputDecoration(labelText: 'Card Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the card number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _expiryDateController,
                decoration: InputDecoration(labelText: 'Expiry Date'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the expiry date';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _cvvController,
                decoration: InputDecoration(labelText: 'CVV'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the CVV';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Perform the action to check card details
                    String cardNumber = _cardNumberController.text;
                    String expiryDate = _expiryDateController.text;
                    String cvv = _cvvController.text;

                    // Send a request to your PHP script to check card details
                    var response = await checkCardDetails(cardNumber, expiryDate, cvv);

                    // Check the response to determine if card details are correct
                    if (response["success"] == "true") {
                      setState(() {
                        _cardDetailsCorrect = true;
                      });
                      // Show a message indicating that card details are correct
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Card details are correct."),
                      ));
                    } else {
                      // Show a message indicating that card details are incorrect
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Card details are incorrect."),
                      ));
                    }
                  }
                },
                child: Text('Save'),
              ),
              if (_cardDetailsCorrect) Text('Card details are correct.'),
            ],
          ),
        ),
      ),
    );
  }


}
