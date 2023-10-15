import 'package:flutter/material.dart';

class MyListTitle extends StatelessWidget {
  final IconData icon;
  final String text;

  const MyListTitle({super.key,required this.icon,required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.white,
        ),
        title: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(text,style:const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
