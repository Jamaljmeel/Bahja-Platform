import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Admin_app/constants.dart';
import 'package:Admin_app/components/custombuttonauth.dart';
import 'package:Admin_app/components/customlogoauth.dart';
import 'package:Admin_app/components/textformfield.dart';
import 'package:Admin_app/dashboard_screen.dart';
//import 'package:Admin_app/screens/RegisterAdmin.dart';
import 'package:Admin_app/root_wrapper.dart'; // ✅ تأكد من إنشاء هذا الملف
import 'package:google_fonts/google_fonts.dart';

class AdminLoginByUsername extends StatefulWidget {
  const AdminLoginByUsername({super.key});

  @override
  State<AdminLoginByUsername> createState() => _AdminLoginByUsernameState();
}

class _AdminLoginByUsernameState extends State<AdminLoginByUsername> {
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isLoading = false;

  void showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> loginAdmin() async {
    FocusScope.of(context).unfocus();

    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final query = await FirebaseFirestore.instance
          .collection('adminAccounts')
          .where('username', isEqualTo: username.text.trim())
          .where('password', isEqualTo: password.text.trim())
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        showSnack('اسم المستخدم أو كلمة المرور غير صحيحة');
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardScreen(),
            settings: const RouteSettings(name: '/root'),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      showSnack('حدث خطأ أثناء تسجيل الدخول');
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(height: 50),
                    const CustomLogoAuth(),
                    const SizedBox(height: 20),
                    Text(
                      "تسجيل دخول الأدمن",
                      style: GoogleFonts.elMessiri().copyWith(
                        color: kBgColor,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "قم بإدخال اسم المستخدم وكلمة المرور",
                      style: GoogleFonts.elMessiri().copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "اسم المستخدم",
                      style: GoogleFonts.elMessiri().copyWith(
                        color: kSecondaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    CustomTextForm(
                      hinttext: "ادخل اسم المستخدم",
                      mycontroller: username,
                      validator: (val) =>
                          val == null || val.isEmpty ? "مطلوب" : null,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "كلمة المرور",
                      style: GoogleFonts.elMessiri().copyWith(
                        color: kSecondaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    CustomTextForm(
                      hinttext: "ادخل كلمة المرور",
                      mycontroller: password,
                      validator: (val) =>
                          val == null || val.isEmpty ? "مطلوب" : null,
                    ),
                    const SizedBox(height: 20),
                    CustomButtonAuth(
                      title: "تسجيل الدخول",
                      onPressed: loginAdmin,
                    ),
                    InkWell(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => const RegisterAdmin(),
                        //   ),
                        // );
                      },
                      child: const Center(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              // TextSpan(text: "لا يوجد حساب بالفعل "),
                              // TextSpan(
                              //   text: "إنشاء حساب",
                              //   style: TextStyle(
                              //     color: kBgColor,
                              //     fontWeight: FontWeight.bold,
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
