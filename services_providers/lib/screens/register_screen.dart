import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:services_providers/screens/email_verification_screen.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isTermsAccepted = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Column(
        children: [
          // الجزء العلوي: الشعار والخلفية المتدرجة
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark 
                  ? [AppColors.primaryDark, AppColors.primaryDark.withOpacity(0.7)]
                  : [AppColors.primaryLight, AppColors.primaryLight.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            padding: EdgeInsets.only(top: 40, bottom: 20),
            child: Column(
              children: [
                Text(
                  'Bahja',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.elMessiri(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'إنشاء حساب جديد',
                  style: GoogleFonts.elMessiri(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // الجزء الرئيسي: الحقول والأزرار
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'يرجى تعبئة البيانات :',
                        style: GoogleFonts.elMessiri(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      controller: _usernameController,
                      hintText: 'ادخل اسم المستخدم',
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'ادخل البريد الالكتروني',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      controller: _passwordController,
                      hintText: 'ادخل كلمة المرور',
                      obscureText: true,
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      controller: _confirmPasswordController,
                      hintText: 'تأكيد كلمة المرور',
                      obscureText: true,
                    ),
                    SizedBox(height: 10),

                    Row(
                      children: [
                        Checkbox(
                          value: _isTermsAccepted,
                          activeColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                          checkColor: Colors.white,
                          onChanged: (bool? value) {
                            setState(() {
                              _isTermsAccepted = value ?? false;
                            });
                          },
                        ),
                        Text(
                          'أوافق على الشروط والأحكام',
                          style: GoogleFonts.elMessiri(
                            fontSize: 14,
                            color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    CustomButton(
                      text: _isLoading ? 'جاري التسجيل...' : 'إنشاء حساب جديد',
                      onPressed: _isLoading ? () {} : _registerUser,
                      backgroundColor: _isLoading 
                        ? (isDark ? AppColors.borderDark : AppColors.borderLight)
                        : (isDark ? AppColors.primaryDark : AppColors.primaryLight),
                    ),
                    SizedBox(height: 20),

                    CustomButton(
                      text: 'تسجيل الدخول باستخدام جوجل',
                      onPressed: _isLoading ? () {}: () => _authService.signInWithGoogle(context),
                      backgroundColor: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

 void _registerUser() async {
  if (_usernameController.text.trim().isEmpty ||
      _emailController.text.trim().isEmpty ||
      _passwordController.text.trim().isEmpty ||
      _confirmPasswordController.text.trim().isEmpty) {
    _showErrorMessage('يرجى تعبئة جميع الحقول');
    return;
  }

  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(_emailController.text.trim())) {
    _showErrorMessage('البريد الإلكتروني غير صحيح');
    return;
  }

  if (_passwordController.text != _confirmPasswordController.text) {
    _showErrorMessage('كلمة المرور وتأكيد كلمة المرور غير متطابقتين');
    return;
  }

  if (!_isTermsAccepted) {
    _showErrorMessage('يرجى الموافقة على الشروط والأحكام');
    return;
  }

  setState(() => _isLoading = true);

  try {
    await _authService.createAccount(
      _emailController.text.trim(),
      _passwordController.text,
      _confirmPasswordController.text,
      _usernameController.text.trim(),
      context,
    );

    // ✅ التأكد من أن المستخدم تم إنشاؤه بنجاح قبل التنقل
    if (FirebaseAuth.instance.currentUser != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const EmailVerificationScreen()),
      );
    }
  } catch (e) {
    _showErrorMessage('حدث خطأ أثناء إنشاء الحساب');
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.elMessiri(fontSize: 14, color: Colors.white),
        ),
        backgroundColor: Colors.red[800],
      ),
    );
  }
}