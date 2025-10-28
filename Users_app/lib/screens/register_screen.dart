import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/custom_label.dart';
import '../widgets/custom_text_field.dart';
// import '../widgets/custom_text_from_field.dart';
import '../widgets/custom_button.dart';
import '../utils/constants.dart';
import '../theme/app_theme.dart';
import 'email_verification_screen.dart';

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
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: Column(
        children: [
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
                  'إنشاء حساب جديد',
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
                    CustomLabel(text: 'يرجى تعبئة البيانات :'),
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
                      maxLines: 1, 
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      controller: _confirmPasswordController,
                      hintText: 'تأكيد كلمة المرور',
                      obscureText: true,
                      maxLines: 1, 
                    ),
                    SizedBox(height: 10),

                    Row(
                      children: [
                        Theme(
                          data: Theme.of(context).copyWith(
                            checkboxTheme: CheckboxThemeData(
                              fillColor: MaterialStateProperty.resolveWith((states) {
                                if (states.contains(MaterialState.selected)) {
                                  return AppColors.primary;
                                }
                                return AppColors.borderColor(context);
                              }),
                            ),
                          ),
                          child: Checkbox(
                            value: _isTermsAccepted,
                            onChanged: (bool? value) {
                              setState(() {
                                _isTermsAccepted = value ?? false;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'أوافق على الشروط والأحكام',
                            style: AppTextStyles.medium(context).copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    CustomButton(
                      text: _isLoading ? 'جاري التسجيل...' : 'إنشاء حساب جديد',
                      onPressed: _isLoading ? () {} : _registerUser,
                      backgroundColor: _isLoading ? AppColors.grey : AppColors.primary,
                    ),
                    SizedBox(height: 20),

                    CustomButton(
                      text: 'تسجيل الدخول باستخدام جوجل',
                      onPressed: _isLoading ? () {} : () => _authService.signInWithGoogle(context),
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
          style: AppTextStyles.medium(context).copyWith(color: Colors.white),
        ),
        backgroundColor: Colors.red[800],
      ),
    );
  }
}