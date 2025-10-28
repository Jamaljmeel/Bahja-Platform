// TODO Implement this library.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Admin_app/constants.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: kSecondaryColor,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(
              icon,
              size: 35,
              color: Color.fromARGB(255, 253, 253, 254),
            ),
            Text(title,
                style: GoogleFonts.elMessiri().copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            Text(value,
                style: GoogleFonts.elMessiri()
                    .copyWith(color: Colors.white, fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
