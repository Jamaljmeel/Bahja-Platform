import 'package:Admin_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButtonAuth extends StatelessWidget {
  final void Function()? onPressed;
  final String title;
  const CustomButtonAuth({super.key, this.onPressed, required this.title});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      height: 40,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      //color: Color.fromARGB(255, 15, 93, 248),
      color: kSecondaryColor,
      textColor: Colors.white,
      onPressed: onPressed,
      child: Text(title,
          style: GoogleFonts.elMessiri().copyWith(
              // color: Colors.white,
              )),
    );
  }
}
