import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';
import '../../utils/constants.dart';
import '../../theme/app_theme.dart';
import '../WeddingInvitation/screens/create_invitation.dart';
import '../WeddingInvitation/screens/guests_screen.dart';
import '../WeddingInvitation/screens/qr_scanner_screen.dart';

class ElectronicInvitationsScreen extends StatefulWidget {
  @override
  _ElectronicInvitationsScreenState createState() =>
      _ElectronicInvitationsScreenState();
}

class _ElectronicInvitationsScreenState
    extends State<ElectronicInvitationsScreen> with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late AnimationController _rotationController;

  late Animation<double> _floatingAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    // إعداد Animation Controllers
    _floatingController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _slideController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // إعداد الأنيميشن
    _floatingAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_rotationController);

    // بدء الأنيميشن
    _slideController.forward();
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: CustomScrollView(
        slivers: [
          // AppBar مخصص مع تأثيرات بصرية
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // خلفية متدرجة ديناميكية
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                Color(0xFF1A1A2E),
                                Color(0xFF16213E),
                                Color(0xFF0F3460),
                              ]
                            : [
                                Color(0xFF667eea),
                                Color(0xFF764ba2),
                                Color(0xFFf093fb),
                              ],
                      ),
                    ),
                  ),

                  // عناصر ديكورية متحركة
                  ...List.generate(6, (index) {
                    return AnimatedBuilder(
                      animation: _rotationAnimation,
                      builder: (context, child) {
                        return Positioned(
                          top: 50 + (index * 30.0),
                          right: 20 + (index * 40.0),
                          child: Transform.rotate(
                            angle: _rotationAnimation.value + (index * 0.5),
                            child: Container(
                              width: 20 + (index * 5.0),
                              height: 20 + (index * 5.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.1),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),

                  // العنوان الرئيسي
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: AnimatedBuilder(
                      animation: _floatingAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatingAnimation.value),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'الدعوات الإلكترونية',
                                style:  AppTextStyles.title(context).copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      offset: Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'أنشئ وأرسل دعواتك الرقمية بسرعة',
                                style:  AppTextStyles.medium(context).copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.2),
                                      offset: Offset(0, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // المحتوى الرئيسي
          SliverToBoxAdapter(
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    SizedBox(height: 20),

                    // المربعات الثلاثة الرئيسية
                    _buildMainFeatures(context, isDark),

                    SizedBox(height: 40),

                    // قسم الإحصائيات

                    SizedBox(height: 40),

                    // قسم المميزات الإضافية
                    _buildFeaturesSection(context, isDark),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainFeatures(BuildContext context, bool isDark) {
    final features = [
      {
        'title': 'ادارة المدعوين',
        'subtitle': 'تابع المدعوين وحالة الحضور بسهولة',
        'icon': Icons.add_circle_outline,
        'colors': isDark
            ? [Color(0xFF4A90E2), Color(0xFF357ABD)]
            : [Color(0xFF667eea), Color(0xFF764ba2)],
        'route': () => GuestsScreen(),
      },
      {
        'title': 'انشاء دعوة',
        'subtitle': 'أنشاء دعوة مخصصة لمناسبتك الخاصة',
        'icon': Icons.people_outline,
        'colors': isDark
            ? [Color(0xFF27AE60), Color(0xFF2ECC71)]
            : [Color(0xFF11998e), Color(0xFF38ef7d)],
        'route': () => CreateInvitationScreen(),
      },
      {
        'title': 'الماسح الضوئي',
        'subtitle': 'امسح رموز QR لتسجيل الحضور فوراً',
        'icon': Icons.qr_code_scanner,
        'colors': isDark
            ? [Color(0xFF8E44AD), Color(0xFF9B59B6)]
            : [
                Color.fromARGB(255, 111, 223, 218),
                Color.fromARGB(255, 232, 154, 179)
              ],
        'route': () => QrScannerScreen(),
      },
    ];

    return Column(
      children: features.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, dynamic> feature = entry.value;

        return AnimatedBuilder(
          animation: _slideController,
          builder: (context, child) {
            return Transform.translate(
              offset:
                  Offset(0, (1 - _slideController.value) * (100 * (index + 1))),
              child: Container(
                margin: EdgeInsets.only(bottom: 20),
                child: _buildFeatureCard(
                  context: context,
                  title: feature['title'],
                  subtitle: feature['subtitle'],
                  icon: feature['icon'],
                  gradientColors: feature['colors'],
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            feature['route'](),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(1.0, 0.0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  index: index,
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    required int index,
  }) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: index == 1 ? _pulseAnimation.value : 1.0,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[0].withOpacity(0.4),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(25),
                  onTap: onTap,
                  child: Stack(
                    children: [
                      // نمط ديكوري في الخلفية
                      Positioned(
                        top: -20,
                        right: -20,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),

                      // المحتوى الرئيسي
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Row(
                          children: [
                            // الأيقونة مع تأثير متحرك
                            AnimatedBuilder(
                              animation: _floatingController,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset:
                                      Offset(0, _floatingAnimation.value * 0.3),
                                  child: Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      icon,
                                      color: Colors.white,
                                      size: 35,
                                    ),
                                  ),
                                );
                              },
                            ),

                            SizedBox(width: 20),

                            // النصوص
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    title,
                                    style:
                                        AppTextStyles.medium(context).copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    subtitle,
                                    style:
                                        AppTextStyles.small(context).copyWith(
                                      color: Colors.white,
                                      
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // سهم التنقل مع تأثير دوراني
                            AnimatedBuilder(
                              animation: _rotationController,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _rotationAnimation.value * 0.1,
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsSection(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceColor.withOpacity(0.1)
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : AppColors.grey.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String number, String label,
      IconData icon, bool isDark) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value * 0.95 + 0.05,
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [Color(0xFF4A90E2), Color(0xFF357ABD)]
                        : [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              SizedBox(height: 12),
              Text(
                number,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.small(context)?.copyWith(
                  color: AppColors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeaturesSection(BuildContext context, bool isDark) {
    final features = [
      {
        'icon': Icons.share,
        'title': ' إرسال عبر واتساب او منصات التواصل',
        'description': 'شارك الدعوات مباشرة مع جهات الاتصال',
        'color': Color(0xFF25D366),
      },
      {
        'icon': Icons.qr_code,
        'title': 'رموز QR فريدة',
        'description': 'كل مدعو يحصل على رمز QR خاص به',
        'color': Color(0xFF6C5CE7),
      },
      {
        'icon': Icons.analytics,
        'title': 'تتبع الحضور',
        'description': 'راقب من حضر ومن لم يحضر بعد',
        'color': Color(0xFFE17055),
      },
    ];

    return Container(
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  Color(0xFF1A1A2E).withOpacity(0.8),
                  Color(0xFF16213E).withOpacity(0.8),
                ]
              : [
                  Colors.white.withOpacity(0.9),
                  AppColors.primary.withOpacity(0.05),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : AppColors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.accentColor, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.star_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 15),
              Text(
                'مميزات رائعة',
                style: AppTextStyles.title(context)?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 25),
          ...features.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> feature = entry.value;

            return AnimatedBuilder(
              animation: _slideController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    (1 - _slideController.value) * (index.isEven ? -100 : 100),
                    0,
                  ),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: _buildFeatureItem(
                      context,
                      feature['icon'],
                      feature['title'],
                      feature['description'],
                      feature['color'],
                      isDark,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    Color color,
    bool isDark,
  ) {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatingAnimation.value * 0.2),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: color.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.medium(context)?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor(context),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        description,
                        style: AppTextStyles.small(context)?.copyWith(
                          color: AppColors.grey,
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
}
