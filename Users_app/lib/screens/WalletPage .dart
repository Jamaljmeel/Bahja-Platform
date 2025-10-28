import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../services/wallet_service.dart';
import '../widgets/custom_app_bar.dart';
import '../utils/constants.dart';
import 'login_screen.dart';

class WalletPage extends StatefulWidget {
  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> with TickerProviderStateMixin {
  final WalletService _walletService = WalletService();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  
  bool _isLoading = false;
  bool _isPinSet = false;
  bool _isAuthenticated = false;
  bool _showChargeSheet = false;
  bool _obscurePin = true;
  double _currentBalance = 0.0;
  
  late AnimationController _animationController;
  late AnimationController _balanceAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _balanceAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkWalletStatus();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _balanceAnimationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut)
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut)
    );

    _balanceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _balanceAnimationController, curve: Curves.easeInOut)
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _balanceAnimationController.dispose();
    _pinController.dispose();
    _amountController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _checkWalletStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final walletExists = await _walletService.checkWalletExists(user.uid);
      final balance = await _walletService.getBalance(user.uid);
      
      setState(() {
        _isPinSet = walletExists;
        _currentBalance = balance;
        _isLoading = false;
      });

      if (_isPinSet) {
        _balanceAnimationController.forward();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('خطأ في تحميل بيانات المحفظة');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return _buildNotSignedIn();
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: CustomAppBar(title: 'المحفظة الالكترونية'),
      body: _isLoading 
        ? _buildLoadingState() 
        : !_isPinSet 
          ? _buildSetupPinScreen()
          : !_isAuthenticated 
            ? _buildAuthenticationScreen()
            : _buildWalletContent(),
    );
  }

  Widget _buildNotSignedIn() {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: CustomAppBar(title: 'المحفظة الالكترونية'),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            margin: EdgeInsets.all(24),
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.inputFillColor(context),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.borderColor(context).withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.account_balance_wallet,
                    size: 60,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'يجب تسجيل الدخول للوصول للمحفظة',
                  style: AppTextStyles.extraLarge(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: Text(
                    'تسجيل الدخول',
                    style: AppTextStyles.large(context).copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 16),
          Text(
            'جاري تحميل المحفظة...',
            style: AppTextStyles.large(context).copyWith(
              color: AppColors.textColor(context).withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupPinScreen() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(height: 40),
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.security,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(height: 32),
            Text(
              'إعداد رمز المحفظة',
              style: AppTextStyles.extraLarge(context).copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'قم بإنشاء رمز تعريفي مكون من 4 أرقام لحماية محفظتك',
              style: AppTextStyles.medium(context).copyWith(
                color: AppColors.textColor(context).withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            _buildPinInputCard('إنشاء رمز المحفظة', _pinController),
            SizedBox(height: 20),
            _buildPinInputCard('تأكيد رمز المحفظة', _confirmPinController),
            SizedBox(height: 40),
            _buildActionButton(
              'إنشاء المحفظة',
              Icons.security,
              _setupWallet,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthenticationScreen() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(height: 80),
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(height: 32),
            Text(
              'أدخل رمز المحفظة',
              style: AppTextStyles.extraLarge(context).copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'يرجى إدخال الرمز التعريفي للوصول لمحفظتك',
              style: AppTextStyles.medium(context).copyWith(
                color: AppColors.textColor(context).withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            _buildPinInputCard('رمز المحفظة', _pinController),
            SizedBox(height: 40),
            _buildActionButton(
              'فتح المحفظة',
              Icons.lock_open,
              _authenticateWallet,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _buildBalanceCard(),
            SizedBox(height: 24),
            _buildQuickActions(),
            SizedBox(height: 24),
            _buildTransactionHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return AnimatedBuilder(
      animation: _balanceAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.9 + (_balanceAnimation.value * 0.1),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'رصيد المحفظة',
                            style: AppTextStyles.medium(context).copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${(_currentBalance * _balanceAnimation.value).toStringAsFixed(2)} ريال',
                            style: AppTextStyles.medium(context).copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'محفظة آمنة ومحمية',
                        style: AppTextStyles.small(context).copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            'شحن الحساب',
            Icons.add_circle,
            Colors.green,
            () => _showChargeBottomSheet(),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildQuickActionCard(
            'تغيير الرمز',
            Icons.edit,
            Colors.orange,
            () => _showChangePinDialog(),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.inputFillColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.borderColor(context).withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.medium(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

Widget _buildTransactionHistory() {
  return Container(
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.inputFillColor(context),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.history, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'سجل المعاملات',
              style: AppTextStyles.large(context).copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: _walletService.getTransactionHistory(FirebaseAuth.instance.currentUser!.uid),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'حدث خطأ في جلب البيانات',
                  style: TextStyle(color: Colors.red),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  children: [
                    Icon(Icons.history_outlined, size: 60, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'لا توجد عمليات سابقة',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return _buildTransactionItem(snapshot.data![index]);
              },
            );
          },
        ),
      ],
    ),
  );
}

 Widget _buildTransactionItem(Map<String, dynamic> transaction) {
  final isCharge = transaction['type'] == 'charge';
  final isTransfer = transaction['transactionType'] == 'transfer';
  final timestamp = (transaction['timestamp'] as Timestamp).toDate();

  return Container(
    margin: EdgeInsets.only(bottom: 12),
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.backgroundColor(context),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: AppColors.borderColor(context).withOpacity(0.1),
      ),
    ),
    child: Row(
      children: [
        // أيقونة مختلفة لكل نوع معاملة
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isTransfer 
              ? Colors.blue.withOpacity(0.1) 
              : (isCharge ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isTransfer ? Icons.swap_horiz : 
              (isCharge ? Icons.add : Icons.remove),
            color: isTransfer ? Colors.blue : 
              (isCharge ? Colors.green : Colors.red),
            size: 20,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isTransfer 
                  ? 'تحويل لخدمة ${transaction['description'] ?? 'مقدم خدمة'}' 
                  : (transaction['description'] ?? (isCharge ? 'شحن المحفظة' : 'سحب من المحفظة')),
                style: AppTextStyles.medium(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2),
              Text(
                DateFormat('yyyy/MM/dd - HH:mm').format(timestamp),
                style: AppTextStyles.small(context).copyWith(
                  color: AppColors.textColor(context).withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        Text(
          isTransfer 
            ? '-${transaction['amount'].toStringAsFixed(2)}' 
            : '${isCharge ? '+' : '-'}${transaction['amount'].toStringAsFixed(2)}',
          style: AppTextStyles.medium(context).copyWith(
            color: isTransfer ? Colors.blue : 
              (isCharge ? Colors.green : Colors.red),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

  Widget _buildPinInputCard(String title, TextEditingController controller) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.inputFillColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderColor(context).withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.borderColor(context).withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.medium(context).copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 12),
          TextField(
            controller: controller,
            obscureText: _obscurePin,
            keyboardType: TextInputType.number,
            maxLength: 4,
            style: AppTextStyles.large(context),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: '• • • •',
              hintStyle: AppTextStyles.large(context).copyWith(
                color: AppColors.textColor(context).withOpacity(0.4),
                letterSpacing: 8,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePin ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textColor(context).withOpacity(0.6),
                ),
                onPressed: () => setState(() => _obscurePin = !_obscurePin),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.borderColor(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.borderColor(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              counterText: '',
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : onPressed,
        icon: _isLoading 
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Icon(icon, size: 20),
        label: Text(
          _isLoading ? 'جاري التحميل...' : text,
          style: AppTextStyles.large(context).copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
      ),
    );
  }

  void _showChargeBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildChargeBottomSheet(),
    );
  }

  Widget _buildChargeBottomSheet() {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor(context),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderColor(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.add_circle, color: Colors.green, size: 24),
                ),
                SizedBox(width: 16),
                Text(
                  'شحن المحفظة',
                  style: AppTextStyles.extraLarge(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Text(
              'رمز التعريفي للمحفظة:',
              style: AppTextStyles.medium(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              style: AppTextStyles.large(context),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: '• • • •',
                hintStyle: AppTextStyles.large(context).copyWith(
                  color: AppColors.textColor(context).withOpacity(0.4),
                  letterSpacing: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                counterText: '',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'المبلغ المراد شحنه:',
              style: AppTextStyles.medium(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: AppTextStyles.large(context),
              decoration: InputDecoration(
                hintText: '0.00',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.monetization_on),
                suffixText: 'ريال',
              ),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _pinController.clear();
                      _amountController.clear();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('إلغاء'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => _chargeWallet(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'شحن المحفظة',
                      style: AppTextStyles.medium(context).copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _setupWallet() async {
    if (_pinController.text.length != 4) {
      _showErrorSnackBar('يجب أن يكون الرمز مكون من 4 أرقام');
      return;
    }

    if (_pinController.text != _confirmPinController.text) {
      _showErrorSnackBar('الرمز غير متطابق');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      await _walletService.createWallet(user.uid, _pinController.text);
      
      setState(() {
        _isPinSet = true;
        _isAuthenticated = true;
        _isLoading = false;
      });

      _pinController.clear();
      _confirmPinController.clear();
      _balanceAnimationController.forward();
      _showSuccessSnackBar('تم إنشاء المحفظة بنجاح!');
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('حدث خطأ في إنشاء المحفظة');
    }
  }

  Future<void> _authenticateWallet() async {
    if (_pinController.text.length != 4) {
      _showErrorSnackBar('يجب أن يكون الرمز مكون من 4 أرقام');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final isValid = await _walletService.verifyPin(user.uid, _pinController.text);
      
      if (isValid) {
        setState(() {
          _isAuthenticated = true;
          _isLoading = false;
        });
        _pinController.clear();
        _balanceAnimationController.forward();
      } else {
        setState(() => _isLoading = false);
        _showErrorSnackBar('رمز المحفظة غير صحيح');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('حدث خطأ في التحقق من الرمز');
    }
  }

  Future<void> _chargeWallet() async {
    if (_pinController.text.length != 4) {
      _showErrorSnackBar('يجب إدخال رمز المحفظة');
      return;
    }

    if (_amountController.text.isEmpty) {
      _showErrorSnackBar('يجب إدخال المبلغ');
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showErrorSnackBar('يجب إدخال مبلغ صحيح');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final isValidPin = await _walletService.verifyPin(user.uid, _pinController.text);
      
      if (!isValidPin) {
        _showErrorSnackBar('رمز المحفظة غير صحيح');
        return;
      }

      await _walletService.chargeWallet(user.uid, amount);
      
      final newBalance = await _walletService.getBalance(user.uid);
      setState(() {
        _currentBalance = newBalance;
        _isLoading = false;
      });

      Navigator.pop(context);
      _pinController.clear();
      _amountController.clear();
      _balanceAnimationController.reset();
      _balanceAnimationController.forward();
      _showSuccessSnackBar('تم شحن المحفظة بنجاح!');
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('حدث خطأ في شحن المحفظة');
    }
  }

  void _showChangePinDialog() {
    final oldPinController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmNewPinController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundColor(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.edit, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'تغيير رمز المحفظة',
              style: AppTextStyles.large(context).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'الرمز الحالي',
                  counterText: '',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: newPinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'الرمز الجديد',
                  counterText: '',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: confirmNewPinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'تأكيد الرمز الجديد',
                  counterText: '',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: AppTextStyles.medium(context)),
          ),
          ElevatedButton(
            onPressed: () async => _changePin(
              oldPinController.text,
              newPinController.text,
              confirmNewPinController.text,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('تغيير', style: AppTextStyles.medium(context)),
          ),
        ],
      ),
    );
  }

  Future<void> _changePin(String oldPin, String newPin, String confirmNewPin) async {
    if (oldPin.length != 4 || newPin.length != 4 || confirmNewPin.length != 4) {
      _showErrorSnackBar('يجب أن تكون جميع الرموز مكونة من 4 أرقام');
      return;
    }

    if (newPin != confirmNewPin) {
      _showErrorSnackBar('الرمز الجديد غير متطابق');
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser!;
      await _walletService.changePin(user.uid, oldPin, newPin);
      Navigator.pop(context);
      _showSuccessSnackBar('تم تغيير رمز المحفظة بنجاح!');
    } catch (e) {
      _showErrorSnackBar('حدث خطأ في تغيير الرمز');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(message, style: AppTextStyles.medium(context).copyWith(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(message, style: AppTextStyles.medium(context).copyWith(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}