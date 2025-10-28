import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/wallet_service.dart';
import '../theme/theme_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';

class WalletSetupScreen extends StatefulWidget {
  @override
  _WalletSetupScreenState createState() => _WalletSetupScreenState();
}

class _WalletSetupScreenState extends State<WalletSetupScreen> with TickerProviderStateMixin {
  final WalletService _walletService = WalletService();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePin = true;
  bool _obscureConfirmPin = true;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut)
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut)
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Color _getPrimaryColor(bool isDarkMode) {
    return isDarkMode ? AppColors.primaryDark : AppColors.primaryLight;
  }

  Color _getBackgroundColor(bool isDarkMode) {
    return isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight;
  }

  Color _getInputFillColor(bool isDarkMode) {
    return isDarkMode ? AppColors.inputFillDark : AppColors.inputFillLight;
  }

  Color _getTextColor(bool isDarkMode) {
    return isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
  }

  Color _getBorderColor(bool isDarkMode) {
    return isDarkMode ? AppColors.borderDark : AppColors.borderLight;
  }

  Color _getHintTextColor(bool isDarkMode) {
    return isDarkMode ? AppColors.hintTextDark : AppColors.hintTextLight;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: _getBackgroundColor(isDarkMode),
      body: Column(
        children: [
          // الجزء العلوي مع الخلفية المتدرجة
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getPrimaryColor(isDarkMode),
                  _getPrimaryColor(isDarkMode).withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              boxShadow: [
                BoxShadow(
                  color: _getPrimaryColor(isDarkMode).withOpacity(0.3),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            padding: EdgeInsets.only(top: 60, bottom: 40),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'إعداد المحفظة الذكية',
                    style: GoogleFonts.elMessiri(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'قم بإنشاء رمز آمن لحماية محفظتك',
                    style: GoogleFonts.elMessiri(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // المحتوى الرئيسي
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    
                    // معلومات حول الرمز
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getPrimaryColor(isDarkMode).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getPrimaryColor(isDarkMode).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: _getPrimaryColor(isDarkMode),
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'سيكون هذا الرمز مطلوباً في كل عملية دفع أو شحن للمحفظة',
                              style: GoogleFonts.elMessiri(
                                fontSize: 14,
                                color: _getTextColor(isDarkMode),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 30),

                    // حقل إدخال الرمز
                    Text(
                      'إنشاء رمز المحفظة',
                      style: GoogleFonts.elMessiri(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getPrimaryColor(isDarkMode),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'يجب أن يكون الرمز مكون من 4 أرقام',
                      style: GoogleFonts.elMessiri(
                        fontSize: 14,
                        color: _getTextColor(isDarkMode).withOpacity(0.7),
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildPinInputField(_pinController, 'أدخل رمز المحفظة', _obscurePin, () {
                      setState(() => _obscurePin = !_obscurePin);
                    }, isDarkMode),

                    SizedBox(height: 20),

                    // حقل تأكيد الرمز
                    Text(
                      'تأكيد رمز المحفظة',
                      style: GoogleFonts.elMessiri(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getPrimaryColor(isDarkMode),
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildPinInputField(_confirmPinController, 'تأكيد رمز المحفظة', _obscureConfirmPin, () {
                      setState(() => _obscureConfirmPin = !_obscureConfirmPin);
                    }, isDarkMode),

                    SizedBox(height: 40),

                    // زر إنشاء المحفظة
                    CustomButton(
                      text: _isLoading ? 'جاري إنشاء المحفظة...' : 'إنشاء المحفظة',
                      onPressed: _isLoading ? () {} : _createWallet,
                      backgroundColor: _isLoading 
                        ? _getBorderColor(isDarkMode)
                        : _getPrimaryColor(isDarkMode),
                    ),

                    SizedBox(height: 20),

                    // // زر تخطي (اختياري)
                    // Center(
                    //   child: TextButton(
                    //     onPressed: _isLoading ? null : _skipWalletSetup,
                    //     child: Text(
                    //       'تخطي الآن (يمكن إعداد المحفظة لاحقاً)',
                    //       style: GoogleFonts.elMessiri(
                    //         fontSize: 14,
                    //         color: _getTextColor(isDarkMode).withOpacity(0.6),
                    //         decoration: TextDecoration.underline,
                    //       ),
                    //     ),
                    //   ),
                    // ),

                    if (_isLoading) ...[
                      SizedBox(height: 20),
                      Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(_getPrimaryColor(isDarkMode)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinInputField(
    TextEditingController controller,
    String hint,
    bool obscure,
    VoidCallback toggleObscure,
    bool isDarkMode,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: _getInputFillColor(isDarkMode),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBorderColor(isDarkMode).withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: _getBorderColor(isDarkMode).withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: TextInputType.number,
        maxLength: 4,
        textAlign: TextAlign.center,
        style: GoogleFonts.elMessiri(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: _getTextColor(isDarkMode),
          letterSpacing: 8,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          hintText: obscure ? '• • • •' : '0 0 0 0',
          hintStyle: GoogleFonts.elMessiri(
            fontSize: 20,
            color: _getHintTextColor(isDarkMode),
            letterSpacing: 8,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscure ? Icons.visibility_off : Icons.visibility,
              color: _getTextColor(isDarkMode).withOpacity(0.6),
            ),
            onPressed: toggleObscure,
          ),
          prefixIcon: Icon(
            Icons.lock_outline,
            color: _getPrimaryColor(isDarkMode),
          ),
          border: InputBorder.none,
          counterText: '',
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Future<void> _createWallet() async {
    // التحقق من صحة البيانات
    if (_pinController.text.length != 4) {
      _showErrorMessage('يجب أن يكون الرمز مكون من 4 أرقام');
      return;
    }

    if (_confirmPinController.text.length != 4) {
      _showErrorMessage('يجب تأكيد الرمز بـ 4 أرقام');
      return;
    }

    if (_pinController.text != _confirmPinController.text) {
      _showErrorMessage('الرمز وتأكيد الرمز غير متطابقين');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorMessage('خطأ في تسجيل الدخول');
        return;
      }

      // إنشاء المحفظة
      await _walletService.createWallet(user.uid, _pinController.text);

      // عرض رسالة نجاح
      _showSuccessMessage('تم إنشاء المحفظة بنجاح!');
      
      // الانتقال للصفحة الرئيسية بعد تأخير قصير
      await Future.delayed(Duration(seconds: 2));
      
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }

    } catch (e) {
      _showErrorMessage('حدث خطأ أثناء إنشاء المحفظة: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // void _skipWalletSetup() {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
  //       final isDarkMode = themeProvider.isDarkMode;
        
  //       return AlertDialog(
  //         backgroundColor: _getBackgroundColor(isDarkMode),
  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //         title: Text(
  //           'تخطي إعداد المحفظة',
  //           style: GoogleFonts.elMessiri(
  //             fontWeight: FontWeight.bold,
  //             color: _getTextColor(isDarkMode),
  //           ),
  //         ),
  //         content: Text(
  //           'هل أنت متأكد من أنك تريد تخطي إعداد المحفظة؟ يمكنك إعدادها لاحقاً من خلال الإعدادات.',
  //           style: GoogleFonts.elMessiri(
  //             color: _getTextColor(isDarkMode),
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: Text(
  //               'إلغاء',
  //               style: GoogleFonts.elMessiri(
  //                 color: _getTextColor(isDarkMode).withOpacity(0.7),
  //               ),
  //             ),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //               Navigator.of(context).pushReplacementNamed('/home');
  //             },
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: _getPrimaryColor(isDarkMode),
  //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //             ),
  //             child: Text(
  //               'تخطي',
  //               style: GoogleFonts.elMessiri(color: Colors.white),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.elMessiri(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.elMessiri(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}