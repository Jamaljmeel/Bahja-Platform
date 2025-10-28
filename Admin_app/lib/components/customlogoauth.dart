import 'package:flutter/material.dart';

class CustomLogoAuth extends StatelessWidget {
  const CustomLogoAuth({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        alignment: Alignment.center,
        width: 80,
        height: 80,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.grey[200], borderRadius: BorderRadius.circular(70)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(70),
          child: Image.asset(
            "images/logo.jpg",
            height: 80,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
