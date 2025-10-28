import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Admin_app/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class UserRow extends StatelessWidget {
  final String userId;
  final String email;
  final String typeUser;
  final bool isSuspended;

  const UserRow({
    super.key,
    required this.userId,
    required this.email,
    required this.typeUser,
    required this.isSuspended,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: kSecondaryColor,
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(email, style: TextStyle(color: Colors.white)),
        subtitle: Text(
          'النوع: $typeUser',
          style: GoogleFonts.elMessiri().copyWith(color: Colors.white),
        ),
        trailing: Switch(
          value: !isSuspended,
          onChanged: (value) async {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .update({'isSuspended': !value});
          },
          activeColor: Colors.green,
          inactiveThumbColor: Colors.red,
        ),
      ),
    );
  }
}
