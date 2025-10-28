import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:Admin_app/components/customlogoauth.dart';
import 'package:Admin_app/constants.dart';
import 'package:Admin_app/screens/cloud_messaging.dart';
import 'package:Admin_app/providers/stats_provider.dart';
import 'package:Admin_app/screens/ContactUs_Screen.dart';
import 'package:Admin_app/screens/approved_services_screen.dart';
import 'package:Admin_app/screens/bookings_management_screen.dart';
import 'package:Admin_app/screens/Bookings_PieChart.dart';
import 'package:Admin_app/screens/login_admin_screen.dart';
import 'package:Admin_app/screens/services_approval_screen.dart';
import 'package:Admin_app/screens/services_screen.dart';
import 'package:Admin_app/screens/users_management_screen.dart';
import 'package:Admin_app/widgets/stats_charts.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../widgets/stats_card.dart';
import 'package:Admin_app/screens/Bookings_PieChart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: kBgColor,
        title: Text(
          'لوحة التحكم',
          style: GoogleFonts.elMessiri(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),

        // أيقونة الإشعار في اليسار
        // leading: StreamBuilder<int>(
        //   stream: adminProvider.getNewComplaintsCount(),
        //   builder: (context, snapshot) {
        //     final hasNew = snapshot.hasData && snapshot.data! > 0;
        //     return IconButton(
        //       onPressed: () {
        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(builder: (context) => MessagesScreen()),
        //         );
        //       },
        //       icon: Stack(
        //         alignment: Alignment.topLeft,
        //         children: [
        //           const Icon(Iconsax.notification,
        //               color: Colors.white, size: 26),
        //           if (hasNew)
        //             Container(
        //               width: 10,
        //               height: 10,
        //               decoration: BoxDecoration(
        //                 color: Colors.red,
        //                 shape: BoxShape.circle,
        //               ),
        //             ),
        //         ],
        //       ),
        //     );
        //   },
        // ),
      ),
      endDrawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(
                  //   'مدير التطبيق',
                  //   style: GoogleFonts.tajawal(
                  //     fontSize: 24,
                  //     fontWeight: FontWeight.bold,
                  //     color: kDarkColor,
                  //   ),
                  // ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Stats Cards Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: GridView(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: size.width > 600 ? 4 : 2,
                  childAspectRatio: size.width > 600 ? 1.2 : 1.05,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                children: [
                  _buildUserStats(adminProvider),
                  _buildBookingsStats(adminProvider),
                  _buildRevenueStats(adminProvider),
                  _buildComplaintsStats(adminProvider),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Charts Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Revenue Chart
                  _buildSectionTitle('الإيرادات الشهرية'),
                  const SizedBox(height: 10),
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(15),
                    child: const StatsProvider(),
                  ),

                  const SizedBox(height: 25),

                  // Bookings Chart
                  _buildSectionTitle('توزيع الحجوزات'),
                  const SizedBox(height: 10),
                  Container(
                    height: 280,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 15,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    //  padding: const EdgeInsets.all(15),
                    child: const Bookingsscreen(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.center,
      child: Text(
        title,
        style: GoogleFonts.elMessiri(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: kDarkColor,
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: kBgColor,
      width: MediaQuery.of(context).size.width * 0.75,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer Header
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: kSecondaryColor.withOpacity(0.9),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CustomLogoAuth(),
                  const SizedBox(height: 10),
                  Text(
                    "مديـــر التطبـيق",
                    style: GoogleFonts.elMessiri(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    "admin@gmail.com",
                    style: GoogleFonts.elMessiri(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Drawer Menu Items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Column(
                children: [
                  _buildDrawerItem(
                    context,
                    icon: Iconsax.home,
                    title: 'لوحة التحكم',
                    onTap: () {
                      // بدلاً من فتح شاشة جديدة، نغلق الدراور فقط
                      Navigator.pop(context);

                      // إذا كنا بالفعل في لوحة التحكم، لا نفعل شيئاً
                      if (ModalRoute.of(context)?.settings.name !=
                          '/dashboard') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DashboardScreen(),
                            settings: const RouteSettings(name: '/dashboard'),
                          ),
                        );
                      }
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Iconsax.profile_2user,
                    title: 'ادارة المستخدمين',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UsersManagementScreen()),
                    ),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Iconsax.box,
                    title: 'ادارة الخدمات',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ApprovedServicesScreen()),
                    ),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Iconsax.category,
                    title: 'ادارة أنواع الخدمات',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ServiceManagementScreen()),
                    ),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Iconsax.task_square,
                    title: 'مراجعة الخدمات',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ServicesApprovalScreen()),
                    ),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Iconsax.calendar,
                    title: ' الحجوزات',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BookingsManagementScreen()),
                    ),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Iconsax.warning_2,
                    title: 'إدارة الشكاوى',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MessagesScreen()),
                    ),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Iconsax.notification,
                    title: 'الإشعارات العامة',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NotificationPage()),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Divider(color: Colors.white.withOpacity(0.3), height: 1),
                  const SizedBox(height: 10),
                  _buildDrawerItem(
                    context,
                    icon: Iconsax.logout,
                    title: 'تسجيل الخروج',
                    color: Colors.red[500],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AdminLoginByUsername()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Color? color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.white),
      title: Text(
        title,
        style: GoogleFonts.elMessiri(
          color: color ?? Colors.white,
          fontSize: 15,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
      minLeadingWidth: 30,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      hoverColor: Colors.white.withOpacity(0.1),
    );
  }

  Widget _buildUserStats(AdminProvider provider) {
    return StreamBuilder<int>(
      stream: provider.getUsersCount(),
      builder: (context, snapshot) {
        final value = snapshot.hasData ? '${snapshot.data}' : '...';
        return StatsCard(
          title: 'المستخدمين',
          value: value,
          icon: Iconsax.profile_2user,
          //color: Colors.blue,
        );
      },
    );
  }

  Widget _buildBookingsStats(AdminProvider provider) {
    return StreamBuilder<int>(
      stream: provider.getBookingsCount(),
      builder: (context, snapshot) {
        final value = snapshot.hasData ? '${snapshot.data}' : '...';
        return StatsCard(
          title: 'الحجوزات',
          value: value,
          icon: Iconsax.calendar,
          //color: Colors.green,
        );
      },
    );
  }

  Widget _buildRevenueStats(AdminProvider provider) {
    return StreamBuilder<double>(
      stream: provider.getRevenue(),
      builder: (context, snapshot) {
        final value =
            snapshot.hasData ? '\$${snapshot.data!.toStringAsFixed(0)}' : '...';
        return StatsCard(
          title: 'الإيرادات',
          value: value,
          icon: Iconsax.dollar_circle,
          //color: Colors.purple,
        );
      },
    );
  }

  Widget _buildComplaintsStats(AdminProvider provider) {
    return StreamBuilder<int>(
      stream: provider.getComplaintsCount(),
      builder: (context, snapshot) {
        final value = snapshot.hasData ? '${snapshot.data}' : '...';
        return StatsCard(
          title: 'الشكاوى',
          value: value,
          icon: Iconsax.warning_2,
          // color: Colors.orange,
        );
      },
    );
  }
}
