import 'package:gam/screens/NotificationsScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../services/navigation_service.dart';
import '../utils/auth_utils.dart';
import '../widgets/offer_card.dart';
import '../widgets/section_card.dart';
import '../widgets/bottom_nav_bar.dart';
import 'EventServicesPage.dart';
import '../Chatbot/screens/ChatbotPage.dart';
import 'MapPage.dart';
import 'OffersPage.dart';
import '../utils/constants.dart';
import 'WalletPage .dart';
import 'electronic_invitations_screen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String usersId = FirebaseAuth.instance.currentUser?.uid ?? "";

  // Animation controllers
  late AnimationController _bannerAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // صور العروض المختلفة
  final List<String> offerImages = [
    'asset/images/10.png',
    'asset/images/20.png',
    'asset/images/30.png',
    'asset/images/40.png',
    'asset/images/50.png',
  ];

  // نسب الخصم المرتبطة بكل صورة
  final List<int> discountPercentages = [10, 20, 30, 40, 50];

  int _selectedIndex = 0;
  int _currentBannerIndex = 0;

  @override
  void initState() {
    super.initState();

    // إعداد Animation Controllers
    _bannerAnimationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bannerAnimationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeIn,
    ));

    // بدء الأنيميشن
    _bannerAnimationController.forward();
    _fadeAnimationController.forward();
  }

  // Stream للحصول على عدد الإشعارات غير المقروءة
  Stream<int> _getUnreadNotificationsCount() {
    return FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      int count = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final isRead = data['isRead'] ?? false;

        if (!isRead && _shouldShowNotification(data)) {
          count++;
        }
      }
      return count;
    });
  }

  // دالة لفلترة الإشعارات
  bool _shouldShowNotification(Map<String, dynamic> data) {
    final userId = data['userId'] as String?;
    final targetGroups = data['targetGroups'] as List<dynamic>?;

    // إشعارات خاصة بالمستخدم الحالي
    if (userId != null && userId.isNotEmpty && userId == usersId) {
      return true;
    }

    // إشعارات عامة (userId فارغ أو null)
    if ((userId == null || userId.isEmpty) && targetGroups != null) {
      final targetGroupsList = targetGroups.cast<String>();
      return targetGroupsList.contains('clients') ||
          targetGroupsList.contains('all');
    }

    return false;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bannerAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  void _updateIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // تنفيذ البحث
  void _searchEventServices(BuildContext context) {
    final searchText = _searchController.text.trim();
    if (searchText.isEmpty) {
      return;
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventServicesPage(
            initialSearchQuery: searchText,
          ),
        ),
      );
    }
  }

  // دالة الانتقال إلى صفحة العروض
  void _navigateToOffersPage(int index) async {
    final authUtils = AuthUtils();
    if (await authUtils.verifyUserStatus(context)) {
      if (index >= 0 && index < discountPercentages.length) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OffersPage(
              discountPercentage: discountPercentages[index],
            ),
          ),
        );
      }
    }
  }

  // بناء البانر الترويجي المتحرك
  Widget _buildPromoBanner({
    required String backgroundImage,
    required String title,
    required String subtitle,
    required String buttonText,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _slideAnimation.value) * 50),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // الصورة الخلفية
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(backgroundImage),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // التدرج اللوني
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            gradientColors[0].withOpacity(0.8),
                            gradientColors[1].withOpacity(0.6),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                        ),
                      ),
                    ),

                    // المحتوى النصي
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // العنوان الرئيسي
                          AnimatedContainer(
                            duration: Duration(milliseconds: 600),
                            transform: Matrix4.translationValues(
                              (1 - _slideAnimation.value) * -100,
                              0,
                              0,
                            ),
                            child: Text(
                              title,
                              style: AppTextStyles.title(context).copyWith(
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.5),
                                    offset: Offset(1, 1),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 8),

                          // العنوان الفرعي
                          AnimatedContainer(
                            duration: Duration(milliseconds: 800),
                            transform: Matrix4.translationValues(
                              (1 - _slideAnimation.value) * -150,
                              0,
                              0,
                            ),
                            child: Text(
                              subtitle,
                              style: AppTextStyles.medium(context).copyWith(
                                color: Colors.white.withOpacity(0.9),
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    offset: Offset(1, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 15),

                          // زر العمل
                          AnimatedContainer(
                            duration: Duration(milliseconds: 1000),
                            transform: Matrix4.translationValues(
                              (1 - _slideAnimation.value) * -200,
                              0,
                              0,
                            ),
                            child: GestureDetector(
                              onTap: onTap,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white,
                                      Colors.white.withOpacity(0.9),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      buttonText,
                                      style: AppTextStyles.medium(context)
                                          .copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: gradientColors[0],
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: gradientColors[0],
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // عناصر ديكورية متحركة
                    Positioned(
                      top: 20,
                      right: 20,
                      child: AnimatedBuilder(
                        animation: _bannerAnimationController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle:
                                _bannerAnimationController.value * 2 * 3.14159,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.2),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.4),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.star,
                                color: Colors.white.withOpacity(0.7),
                                size: 20,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'مرحبا بك في Bahja',
          style: AppTextStyles.large(context).copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          StreamBuilder<int>(
            stream: _getUnreadNotificationsCount(),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;
              return IconButton( 
                icon: _buildNotificationIcon(unreadCount),
                onPressed: () async {
                  final authUtils = AuthUtils();
                  if (await authUtils.verifyUserStatus(context)) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            NotificationsPage(currentUserId: usersId),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // شريط البحث المباشر
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: screenHeight * 0.05,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [Colors.blue[800]!, Colors.blue[400]!],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 3),
                          IconButton(
                            icon: Icon(Icons.search, color: Colors.white),
                            onPressed: () => _searchEventServices(context),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: AppTextStyles.medium(context).copyWith(
                                color: Colors.white,
                              ),
                              decoration: InputDecoration(
                                hintText: 'البحث عن الخدمات...',
                                hintStyle:
                                    AppTextStyles.medium(context).copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 10),
                              ),
                              onSubmitted: (_) => _searchEventServices(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  InkWell(
                    onTap: ()  {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MapPage()),
                        );
                      
                    },
                    child: Container(
                      width: screenWidth * 0.35,
                      height: screenHeight * 0.05,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [Colors.blue[800]!, Colors.blue[400]!],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 5,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.map, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'بحث بالخريطة',
                              style: AppTextStyles.small(context).copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // محتوى البانر التفاعلي المحسن
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              height: screenHeight * 0.20,
              child: CarouselSlider(
                options: CarouselOptions(
                  height: screenHeight * 0.20,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 5),
                  autoPlayAnimationDuration: Duration(milliseconds: 1000),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: true,
                  viewportFraction: 0.95,
                  enableInfiniteScroll: true,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentBannerIndex = index;
                    });
                  },
                ),
                items: [
                  _buildPromoBanner(
                    backgroundImage:
                        'asset/images/photo_5764931256650418718_y.jpg',
                    title: '',
                    subtitle: '',
                    buttonText: 'احجز الآن',
                    gradientColors: [Colors.purple[900]!, Colors.pink[600]!],
                    onTap: () => _navigateToOffersPage(4),
                  ),
                  _buildPromoBanner(
                    backgroundImage:
                        'asset/images/photo_5767275355311294165_x.jpg',
                    title: 'ارسال الدعوات الرقمية',
                    subtitle: 'عبر الواتساب مع الباركود للمدعوين',
                    buttonText: 'ارسل الآن',
                    gradientColors: [Colors.indigo[900]!, Colors.blue[600]!],
                    onTap: () async {
                      final authUtils = AuthUtils();
                      if (await authUtils.verifyUserStatus(context)) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ElectronicInvitationsScreen()),
                        );
                      }
                    },
                  ),
                  _buildPromoBanner(
                    backgroundImage: 'asset/images/1739290484045.webp',
                    title: 'مساعد ذكي للتخطيط',
                    subtitle: 'اكتشف أفضل الخدمات بالذكاء الاصطناعي',
                    buttonText: 'جرب المساعد',
                    gradientColors: [Colors.teal[900]!, Colors.green[600]!],
                    onTap: () async {
                      final authUtils = AuthUtils();
                      if (await authUtils.verifyUserStatus(context)) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatbotScreen()),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            // مؤشرات البانر
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentBannerIndex == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentBannerIndex == index
                        ? AppColors.primary
                        : AppColors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),

            SizedBox(height: 20),

            // عنوان قسم العروض
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.local_offer,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'العروض والخصومات',
                    style: AppTextStyles.extraLarge(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            // عرض بطاقات العروض المختلفة
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: CarouselSlider(
                options: CarouselOptions(
                  autoPlay: false,
                  enlargeCenterPage: false,
                  aspectRatio: 5 / 2,
                  viewportFraction: 0.4,
                  enableInfiniteScroll: false,
                  initialPage: 0,
                  padEnds: false,
                ),
                items: List.generate(offerImages.length, (index) {
                  return Stack(
                    children: [
                      OfferCard(
                        image: offerImages[index],
                        onTap: () => _navigateToOffersPage(index),
                      ),
                      // إضافة تسمية توضيحية للعرض
                      Positioned(
                        bottom: 8,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'خصم ${discountPercentages[index]}%',
                            style: AppTextStyles.small(context).copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),

            // الأقسام الرئيسية
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EventServicesPage()),
                      );
                    },
                    child: SectionCard(
                      text: 'خدمات المناسبات',
                      imagePath:
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR2csjgmohID9JYP6wMhGdKqzEGHcqSKppkxIqY2ZUYQkkis3XB_9xhqPUNQauyma100R0&usqp=CAU',
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final authUtils = AuthUtils();
                      if (await authUtils.verifyUserStatus(context)) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatbotScreen()),
                        );
                      }
                    },
                    child: SectionCard(
                      text: 'المساعد الذكي',
                      imagePath:
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT8aA3ACg05lKStQhvQGl_LH4ISmWy7Tv4hKw&s',
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final authUtils = AuthUtils();
                      if (await authUtils.verifyUserStatus(context)) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ElectronicInvitationsScreen()),
                        );
                      }
                    },
                    child: SectionCard(
                      text: 'الدعوات الالكترونية',
                      imagePath:
                          'https://www.invitesmartapp.com/assets/images/hero/phone.png',
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final authUtils = AuthUtils();
                      if (await authUtils.verifyUserStatus(context)) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => WalletPage()),
                        );
                      }
                    },
                    child: SectionCard(
                      text: 'المحفظة الالكترونية',
                      imagePath:
                          'https://www.ar-wp.com/wp-content/uploads/2021/04/%D9%83%D9%84-%D9%85%D8%A7-%D9%8A%D8%AC%D8%A8-%D9%85%D8%B9%D8%B1%D9%81%D8%AA%D9%87-%D8%B9%D9%86-%D8%A7%D9%84%D9%85%D8%AD%D9%81%D8%B8%D8%A9-%D8%A7%D9%84%D8%A5%D9%84%D9%83%D8%AA%D8%B1%D9%88%D9%86%D9%8A%D8%A9-...jpg',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) =>
            NavigationService.onItemTapped(context, index, _updateIndex),
      ),
    );
  }

  // بناء أيقونة الإشعارات مع المؤشر
  Widget _buildNotificationIcon(int unreadCount) {
    return Stack(
      children: [
        Icon(Icons.notifications,
            size: 28, color: AppColors.primary),
        if (unreadCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: AppTextStyles.extraSmall(context).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
