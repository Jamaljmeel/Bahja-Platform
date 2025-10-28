import 'package:flutter/material.dart';
import 'package:services_providers/models/service_model.dart';
import 'package:services_providers/screens/bookingpage.dart';
import 'package:services_providers/screens/NotificationsPage.dart';
import 'package:services_providers/screens/ProfilePage.dart';
import 'package:services_providers/chat/screens/chatspage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:services_providers/widgets/custom_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/service_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/service_item.dart';
import '../utils/app_colors.dart';
import 'AddServicePage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String providerId = FirebaseAuth.instance.currentUser?.uid ?? "";
  final ServiceProvider _serviceProvider = ServiceProvider();
  int _currentIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeContent(),
      BookingsPage(),
      ChatsPage(),
      // NotificationsPage(currentUserId: providerId,),
      ProfileManagementPage(),
    ];
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
    if (userId != null && userId.isNotEmpty && userId == providerId) {
      return true;
    }
    
    // إشعارات عامة (userId فارغ أو null)
    if ((userId == null || userId.isEmpty) && targetGroups != null) {
      final targetGroupsList = targetGroups.cast<String>();
      return targetGroupsList.contains('providers') || targetGroupsList.contains('all');
    }
    
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: CustomAppBar(title: 'خدماتي ',
            actions: [
          StreamBuilder<int>(
            stream: _getUnreadNotificationsCount(),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;
              return IconButton( 
                icon: _buildNotificationIcon(unreadCount,isDark),
                onPressed: ()  {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            NotificationsPage(currentUserId: providerId),
                      ),
                    );
                  }
              );
            },
          ),
        ],
      ),
      drawer: CustomDrawer(
        onItemTapped: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      body: _pages[_currentIndex],
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddServicePage()),
                );
              },
              icon: Icon(Icons.add, color: Colors.white),
              label: Text(
                'إضافة خدمة',
                style: GoogleFonts.elMessiri(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            )
          : null,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: StreamBuilder<int>(
          stream: _getUnreadNotificationsCount(),
          builder: (context, snapshot) {
            final unreadCount = snapshot.data ?? 0;
            
            return BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
              elevation: 8,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'الرئيسية',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today),
                  label: 'الحجوزات',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.forum),
                  label: 'الدردشة',
                ),
                // BottomNavigationBarItem(
                //   icon: _buildNotificationIcon(unreadCount, isDark),
                //   label: 'الإشعارات',
                // ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'حسابي',
                ),
              ],
              selectedItemColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
              unselectedItemColor: isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
              selectedLabelStyle: GoogleFonts.elMessiri(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
              ),
              unselectedLabelStyle: GoogleFonts.elMessiri(
                fontSize: 12,
                color: isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
              ),
              selectedIconTheme: IconThemeData(
                color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                size: 24,
              ),
              unselectedIconTheme: IconThemeData(
                color: isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
                size: 22,
              ),
            );
          },
        ),
      ),
    );
  }

  // بناء أيقونة الإشعارات مع المؤشر
  Widget _buildNotificationIcon(int unreadCount, bool isDark) {
    return Stack(
      children: [
        Icon(Icons.notifications),
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
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
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

// محتوى الصفحة الرئيسية
class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final ServiceProvider _serviceProvider = ServiceProvider();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userId = FirebaseAuth.instance.currentUser!.uid;
    
    return Container(
      color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      child: StreamBuilder<List<Service>>(
        stream: _serviceProvider.getServicesByUserId(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                strokeWidth: 3,
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'حدث خطأ: ${snapshot.error}',
                    style: GoogleFonts.elMessiri(
                      fontSize: 16,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.business_center_outlined,
                      size: 64,
                      color: isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'لا توجد خدمات مضافة',
                    style: GoogleFonts.elMessiri(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'قم بإضافة خدمتك الأولى باستخدام الزر أدناه',
                    style: GoogleFonts.elMessiri(
                      fontSize: 14,
                      color: isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddServicePage()),
                      );
                    },
                    icon: Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    label: Text(
                      'إضافة خدمة جديدة',
                      style: GoogleFonts.elMessiri(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 3,
                    ),
                  ),
                ],
              ),
            );
          }
          
          final services = snapshot.data!;
          return RefreshIndicator(
            color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
            backgroundColor: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
            onRefresh: () async {
              // إعادة تحميل البيانات
              setState(() {});
            },
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ServiceItem(service: service),
                );
              },
            ),
          );
        },
      ),
    );
  }
}