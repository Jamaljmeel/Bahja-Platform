import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/wallet_service.dart';
import '../widgets/custom_app_bar.dart';
import '../theme/theme_provider.dart';
import '../utils/app_colors.dart';

class ProviderWalletPage extends StatefulWidget {
  @override
  _ProviderWalletPageState createState() => _ProviderWalletPageState();
}

class _ProviderWalletPageState extends State<ProviderWalletPage> with TickerProviderStateMixin {
  final WalletService _walletService = WalletService();
  
  bool _isLoading = true;
  double _currentBalance = 0.0;
  double _totalEarnings = 0.0;
  int _totalTransactions = 0;
  Map<String, double> _monthlyEarnings = {};
  
  late AnimationController _animationController;
  late AnimationController _balanceAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _balanceAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadProviderData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _balanceAnimationController = AnimationController(
      duration: Duration(milliseconds: 1500),
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
    super.dispose();
  }

  Future<void> _loadProviderData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final stats = await _walletService.getProviderStats(user.uid);
      
      setState(() {
        _currentBalance = stats['currentBalance'];
        _totalEarnings = stats['totalEarnings'];
        _totalTransactions = stats['totalTransactions'];
        _monthlyEarnings = Map<String, double>.from(stats['monthlyEarnings']);
        _isLoading = false;
      });

      _balanceAnimationController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('خطأ في تحميل بيانات المحفظة');
    }
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    if (user == null) {
      return _buildNotSignedIn(isDarkMode);
    }

    return Scaffold(
      backgroundColor: _getBackgroundColor(isDarkMode),
      appBar: CustomAppBar(title: 'محفظة مقدم الخدمة'),
      body: _isLoading 
        ? _buildLoadingState(isDarkMode) 
        : _buildWalletContent(isDarkMode),
    );
  }

  Widget _buildNotSignedIn(bool isDarkMode) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(isDarkMode),
      appBar: CustomAppBar(title: 'محفظة مقدم الخدمة'),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            margin: EdgeInsets.all(24),
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: _getInputFillColor(isDarkMode),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _getBorderColor(isDarkMode).withOpacity(0.2),
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
                    color: _getPrimaryColor(isDarkMode).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.business_center,
                    size: 60,
                    color: _getPrimaryColor(isDarkMode),
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'يجب تسجيل الدخول للوصول للمحفظة',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: _getTextColor(isDarkMode),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getPrimaryColor(isDarkMode),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: Text(
                    'العودة',
                    style: TextStyle(
                      fontSize: 18,
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

  Widget _buildLoadingState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_getPrimaryColor(isDarkMode)),
          ),
          SizedBox(height: 16),
          Text(
            'جاري تحميل بيانات المحفظة...',
            style: TextStyle(
              fontSize: 18,
              color: _getTextColor(isDarkMode).withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletContent(bool isDarkMode) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: _loadProviderData,
        color: _getPrimaryColor(isDarkMode),
        backgroundColor: _getInputFillColor(isDarkMode),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              _buildStatsCards(isDarkMode),
              SizedBox(height: 24),
              _buildEarningsChart(isDarkMode),
              SizedBox(height: 24),
              _buildTransactionHistory(isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards(bool isDarkMode) {
    return Column(
      children: [
        // رصيد المحفظة الحالي
        AnimatedBuilder(
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
                      _getPrimaryColor(isDarkMode),
                      _getPrimaryColor(isDarkMode).withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _getPrimaryColor(isDarkMode).withOpacity(0.3),
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
                                'الرصيد الحالي',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${(_currentBalance * _balanceAnimation.value).toStringAsFixed(2)} ريال',
                                style: TextStyle(
                                  fontSize: 28,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
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
                          Icon(Icons.trending_up, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'أرباح مقدم الخدمة',
                            style: TextStyle(
                              fontSize: 14,
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
        ),
        SizedBox(height: 16),
        // بطاقات الإحصائيات
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'إجمالي الأرباح',
                '${_totalEarnings.toStringAsFixed(2)} ريال',
                Icons.monetization_on,
                Colors.green,
                isDarkMode,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'عدد المعاملات',
                '$_totalTransactions',
                Icons.receipt_long,
                Colors.blue,
                isDarkMode,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getInputFillColor(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: _getBorderColor(isDarkMode).withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: _getTextColor(isDarkMode).withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsChart(bool isDarkMode) {
    if (_monthlyEarnings.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _getInputFillColor(isDarkMode),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _getBorderColor(isDarkMode).withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.bar_chart, size: 60, color: _getTextColor(isDarkMode).withOpacity(0.4)),
            SizedBox(height: 16),
            Text(
              'لا توجد بيانات للرسم البياني',
              style: TextStyle(
                fontSize: 16,
                color: _getTextColor(isDarkMode).withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getInputFillColor(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getBorderColor(isDarkMode).withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, color: _getPrimaryColor(isDarkMode)),
              SizedBox(width: 8),
              Text(
                'الأرباح الشهرية',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getPrimaryColor(isDarkMode),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            height: 200,
            child: _buildSimpleBarChart(isDarkMode),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleBarChart(bool isDarkMode) {
    final sortedEntries = _monthlyEarnings.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    
    if (sortedEntries.isEmpty) return Container();
    
    final maxValue = sortedEntries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: sortedEntries.take(6).map((entry) {
        final height = (entry.value / maxValue) * 140;
        final monthName = _getMonthName(entry.key);
        
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${entry.value.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _getTextColor(isDarkMode),
              ),
            ),
            SizedBox(height: 4),
            Container(
              width: 30,
              height: height,
              decoration: BoxDecoration(
                color: _getPrimaryColor(isDarkMode),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: 8),
            Text(
              monthName,
              style: TextStyle(
                fontSize: 10,
                color: _getTextColor(isDarkMode).withOpacity(0.7),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  String _getMonthName(String monthKey) {
    final parts = monthKey.split('-');
    if (parts.length != 2) return monthKey;
    
    final month = int.tryParse(parts[1]) ?? 1;
    const monthNames = [
      '', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    
    return monthNames[month];
  }

  Widget _buildTransactionHistory(bool isDarkMode) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Container();

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getInputFillColor(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getBorderColor(isDarkMode).withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: _getPrimaryColor(isDarkMode)),
              SizedBox(width: 8),
              Text(
                'المعاملات الواردة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getPrimaryColor(isDarkMode),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: _walletService.getProviderTransactions(user.uid),
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
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(_getPrimaryColor(isDarkMode)),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined, 
                        size: 60, 
                        color: _getTextColor(isDarkMode).withOpacity(0.4),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'لا توجد معاملات واردة',
                        style: TextStyle(
                          color: _getTextColor(isDarkMode).withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  final transaction = doc.data() as Map<String, dynamic>;
                  return _buildTransactionItem(transaction, isDarkMode);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction, bool isDarkMode) {
    final timestamp = transaction['timestamp'] != null 
        ? (transaction['timestamp'] as Timestamp).toDate()
        : DateTime.now();
    final amount = (transaction['amount'] ?? 0.0).toDouble();
    final description = transaction['description'] ?? 'دفع من عميل';
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getBackgroundColor(isDarkMode),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBorderColor(isDarkMode).withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.add_circle,
              color: Colors.green,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _getTextColor(isDarkMode),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '${timestamp.day}/${timestamp.month}/${timestamp.year} - ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 12,
                    color: _getTextColor(isDarkMode).withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+${amount.toStringAsFixed(2)} ريال',
            style: TextStyle(
              fontSize: 16,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
              child: Text(
                message, 
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
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