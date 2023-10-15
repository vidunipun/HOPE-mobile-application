import 'package:flutter/material.dart';

class LikeButton extends StatelessWidget {
  final bool isliked;
  void Function()? onTap;

  LikeButton({super.key, required this.isliked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        isliked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
        color: isliked ? Colors.blueAccent[400] : Colors.grey,
      ),
    );
  }
}
