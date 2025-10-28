import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool isLoading = false;

  void _login(BuildContext context, Function setState) async {
    if (isLoading) return;

    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى تعبئة جميع الحقول',
            style: GoogleFonts.elMessiri(fontSize: 14, color: Colors.white),
          ),
          backgroundColor: Colors.red[800],
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    await _authService.loginWithEmailAndPassword(
      _emailController.text,
      _passwordController.text,
      context,
    );

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
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
                      'يرجى تسجيل الدخول لتقديم خدمة ',
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
                        // زر تسجيل الدخول وإنشاء حساب جديد
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: CustomButton(
                                text: 'تسجيل الدخول',
                                onPressed: () {},
                                backgroundColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: CustomButton(
                                text: 'انشاء حساب',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                                  );
                                },
                                backgroundColor: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
                                textColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                                borderColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        // حقل إدخال البريد الإلكتروني
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'أدخل البريد الإلكتروني',
                            style: GoogleFonts.elMessiri(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        CustomTextField(
                          controller: _emailController,
                          hintText: 'ادخل البريد الإلكتروني',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 10),
                        // حقل إدخال كلمة المرور
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'أدخل كلمة المرور',
                            style: GoogleFonts.elMessiri(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        CustomTextField(
                          controller: _passwordController,
                          hintText: 'ادخل كلمة المرور',
                          obscureText: true,
                        ),
                        // زر "هل نسيت كلمة المرور؟"
                        TextButton(
                          onPressed: () => _authService.resetPassword(_emailController.text, context),
                          child: Text(
                            'هل نسيت كلمة المرور؟',
                            style: GoogleFonts.elMessiri(
                              fontSize: 14,
                              color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                            ),
                          ),
                        ),
                        // زر تسجيل الدخول مع تعطيله أثناء التحميل
                        CustomButton(
                          text: isLoading ? 'جاري تسجيل الدخول...' : 'تسجيل الدخول',
                          onPressed: isLoading ? () {} : () => _login(context, setState),
                          backgroundColor: isLoading 
                            ? (isDark ? AppColors.borderDark : AppColors.borderLight)
                            : (isDark ? AppColors.primaryDark : AppColors.primaryLight),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}