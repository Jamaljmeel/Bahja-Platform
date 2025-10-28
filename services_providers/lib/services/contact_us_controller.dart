import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:services_providers/services/notification_service%20.dart';

class ContactUsController {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  String selectedCategory = 'رسالة';
  bool isLoading = false;
   String usersId = FirebaseAuth.instance.currentUser?.uid ?? "";

  Future<void> sendMessage(BuildContext context, Function setState) async {
     String responsaveID = DateTime.now().millisecondsSinceEpoch.toString();
     String? fcmToken = await NotificationService().getToken();
    setState(() => isLoading = true);

    try {
      if (phoneController.text.isNotEmpty && messageController.text.isNotEmpty) {
        await FirebaseFirestore.instance.collection('ContactUs').add({
          'phone': phoneController.text,
          'message': messageController.text,
          'category': selectedCategory,
          'fcmToken': fcmToken,
          'usersId': usersId,
          'timestamp': FieldValue.serverTimestamp(),
         'responsave': {
          responsaveID: {
            'createdAt': '', 
            'response':'',
          },
        },
        });

        showSnackbar(context, 'تم إرسال الرسالة بنجاح!', Colors.green);
        phoneController.clear();
        messageController.clear();
      } else {
        showSnackbar(context, 'يرجى ملء جميع الحقول', Colors.red);
      }
    } catch (e) {
      showSnackbar(context, 'حدث خطأ أثناء الإرسال', Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showSnackbar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.elMessiri(color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.bold,),
        ),
        backgroundColor: color,
      ),
    );
  }
}
