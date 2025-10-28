import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import '../widgets/custom_label.dart';
import '../utils/constants.dart';
import '../theme/app_theme.dart';

// ignore: must_be_immutable
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
            style: AppTextStyles.medium(context).copyWith(color: Colors.white),
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
        return Scaffold(
          backgroundColor: AppColors.backgroundColor(context),
          body: Column(
            children: [
              // الجزء العلوي: الشعار والخلفية المتدرجة
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                padding: EdgeInsets.only(top: 40, bottom: 20),
                child: Column(
                  children: [
                    Text(
                      'Bahja / بهجة',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.display(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'يرجى تسجيل الدخول لاستخدام خدمات التطبيق',
                      style: AppTextStyles.medium(context).copyWith(
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
                                backgroundColor: AppColors.primary,
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
                                backgroundColor: AppColors.backgroundColor(context),
                                textColor: AppColors.primary,
                                borderColor: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        // حقل إدخال البريد الإلكتروني
                        CustomLabel(text: 'أدخل البريد الإلكتروني'),
                        SizedBox(height: 10),
                        CustomTextField(
                          controller: _emailController,
                          hintText: 'ادخل البريد الإلكتروني',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 10),
                        // حقل إدخال كلمة المرور
                        CustomLabel(text: 'أدخل كلمة المرور'),
                        SizedBox(height: 10),
                        CustomTextField(
                          controller: _passwordController,
                          hintText: 'ادخل كلمة المرور',
                          obscureText: true,
                          maxLines: 1, 
                        ),
                        // زر "هل نسيت كلمة المرور؟"
                        TextButton(
                          onPressed: () => _authService.resetPassword(_emailController.text, context),
                          child: Text(
                            'هل نسيت كلمة المرور؟',
                            style: AppTextStyles.medium(context).copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        // زر تسجيل الدخول مع تعطيله أثناء التحميل
                        CustomButton(
                          text: isLoading ? 'جاري تسجيل الدخول...' : 'تسجيل الدخول',
                          onPressed: isLoading ? () {} : () => _login(context, setState),
                          backgroundColor: isLoading ? AppColors.grey : AppColors.primary,
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