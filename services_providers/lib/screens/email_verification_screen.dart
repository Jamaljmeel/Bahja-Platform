import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';
import 'WalletSetupScreen.dart';
import 'login_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  Timer? _timer;
  bool _canResend = false;
  int _secondsRemaining = 30;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    
    if (_user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToLogin();
      });
      return;
    }
    
    _startVerificationProcess();
  }

  void _startVerificationProcess() {
    _sendVerificationEmail();
    _startResendTimer();
    _startVerificationCheckTimer();
  }

  void _startResendTimer() {
    setState(() {
      _canResend = false;
      _secondsRemaining = 30;
    });
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        if (_secondsRemaining == 0) {
          _canResend = true;
          timer.cancel();
        } else {
          _secondsRemaining--;
        }
      });
    });
  }

  void _startVerificationCheckTimer() {
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      await _checkVerification(autoNavigate: true);
    });
  }

  Future<void> _sendVerificationEmail() async {
    if (_user == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      await _user!.sendEmailVerification();
      if (mounted) {
        _showMessage('تم إرسال رابط التحقق إلى بريدك الإلكتروني', isError: false);
      }
    } catch (e) {
      if (mounted) {
        _showMessage('حدث خطأ أثناء إرسال البريد الإلكتروني');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _checkVerification({bool autoNavigate = false}) async {
    if (_user == null) {
      _navigateToLogin();
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      await _user!.reload();
      _user = _auth.currentUser;
      
      if (_user?.emailVerified == true) {
        if (mounted) {
          // تحديث حالة التحقق في Firestore إذا لزم الأمر
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_user!.uid)
              .update({
            'emailVerified': true,
            'isSuspended': false,
          });
          
          if (!autoNavigate) {
            _showMessage('تم التحقق من البريد بنجاح', isError: false);
          }
          
            Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => WalletSetupScreen()),
          );
        }
      } else if (!autoNavigate) {
        _showMessage('البريد الإلكتروني لم يتم التحقق منه بعد');
      }
    } catch (e) {
      _showMessage('');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToLogin() {
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (route) => false,
      );
    }
  }

  void _showMessage(String message, {bool isError = true}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.elMessiri(color: Colors.white),
          ),
          backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return _buildErrorScreen();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 50),
              Icon(
                Icons.mark_email_read_outlined,
                size: 100,
                color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
              ),
              const SizedBox(height: 20),
              Text(
                'تحقق من بريدك الإلكتروني',
                style: GoogleFonts.elMessiri(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'تم إرسال رابط التحقق إلى ${_user?.email ?? ''}',
                textAlign: TextAlign.center,
                style: GoogleFonts.elMessiri(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 30),
              _buildVerificationButton(isDark),
              const SizedBox(height: 20),
              _buildResendButton(isDark),
              const SizedBox(height: 20),
              _buildLogoutButton(),
              if (_isLoading) ...[
                const SizedBox(height: 20),
                CircularProgressIndicator(
                  color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'لم يتم العثور على مستخدم',
              style: GoogleFonts.elMessiri(fontSize: 18),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _navigateToLogin,
              child: Text(
                'العودة إلى تسجيل الدخول',
                style: GoogleFonts.elMessiri(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationButton(bool isDark) {
    return CustomButton(
      text: 'تم التحقق، المتابعة',
      onPressed: () =>_isLoading ? null : _checkVerification,
      backgroundColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
    );
  }

  Widget _buildResendButton(bool isDark) {
    return CustomButton(
      text: _canResend
          ? 'إعادة إرسال رابط التحقق'
          : 'يرجى الانتظار ($_secondsRemaining ثانية)',
      onPressed:() => _canResend && !_isLoading
          ? () {
              _sendVerificationEmail();
              _startResendTimer();
            }
          : null,
      backgroundColor: _canResend
          ? (isDark ? AppColors.primaryDark : AppColors.primaryLight)
          : (isDark ? AppColors.borderDark : AppColors.borderLight),
    );
  }

  Widget _buildLogoutButton() {
    return TextButton(
      onPressed: _isLoading
          ? null
          : () async {
              await _auth.signOut();
              _navigateToLogin();
            },
      child: Text(
        'تسجيل الخروج',
        style: GoogleFonts.elMessiri(
          fontSize: 14,
          color: Colors.red[800],
        ),
      ),
    );
  }
}