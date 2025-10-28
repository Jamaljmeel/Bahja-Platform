import 'package:gam/PoliciesAndInformation/AboutScreen.dart';
import 'package:gam/PoliciesAndInformation/FavoritesScreen.dart';
import 'package:gam/PoliciesAndInformation/PrivacyPolicyScreen.dart';
import 'package:gam/PoliciesAndInformation/TermsScreen.dart';
import '../PoliciesAndInformation/Settings/settings_screen.dart';
import 'package:gam/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../WeddingInvitation/screens/create_invitation.dart';
import '../WeddingInvitation/screens/guests_screen.dart';
import '../WeddingInvitation/screens/qr_scanner_screen.dart';
import '../services/navigation_service.dart';
import '../utils/auth_utils.dart';
import '../widgets/GridMenu.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/custom_app_bar.dart';
import 'ContactUsPage .dart';
import '../utils/constants.dart';


class LearnMore extends StatefulWidget {
  @override
  _LearnMoreState createState() => _LearnMoreState();
}

class _LearnMoreState extends State<LearnMore> {
  @override
  void initState() {
    super.initState();
  }

  int _selectedIndex = 3;

  void _updateIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'لم يتمكن من فتح الرابط $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: CustomAppBars(title: 'Bahja'),
      body: Column(
        children: [
          SizedBox(height: 10),
          // زر تسجيل الدخول
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'تسجيل / تسجيل الدخول',
                    style: AppTextStyles.extraLarge(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionTitle(title: 'السياسات والمعلومات'),
                    GridMenu(items: [
                      MenuItem(
                        title: 'سياسة الخصوصية',
                        icon: Icons.privacy_tip,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PrivacyPolicyScreen()),
                        ),
                      ),
                      MenuItem(
                          title: 'المفضلة',
                          icon: Icons.favorite,
                          onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FavoritesPage()),
                              )),
                      MenuItem(
                        title: 'الإعدادات',
                        icon: Icons.settings,
                        onTap: () async {
                          final authUtils = AuthUtils();
                          if (await authUtils.verifyUserStatus(context)) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SettingsScreen()),
                            );
                          }
                        },
                      ),
                      MenuItem(
                        title: 'عن التطبيق',
                        icon: Icons.info,
                        onTap: () => showDialog(
                          context: context,
                          builder: (context) => AboutScreen(),
                        ),
                      ),
                      MenuItem(
                        title: 'الشروط والأحكام',
                        icon: Icons.rule,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TermsScreen()),
                        ),
                      ),
                      MenuItem(
                        title: 'شارك التطبيق',
                        icon: Icons.share,
                        onTap: () => _launchURL(
                            'https://play.google.com/store/apps/details?id=com.bjda.bjdacustomerapp'),
                      ),
                    ]),
                    Divider(
                        color: AppColors.borderColor(context), thickness: 1),
                    SizedBox(height: 10),
                    SectionTitle(title: 'دعوة الزفاف'),
                    GridMenu(items: [
                      MenuItem(
                        title: 'إنشاء دعوة',
                        icon: Icons.card_giftcard,
                        onTap: () async {
                          final authUtils = AuthUtils();
                          if (await authUtils.verifyUserStatus(context)) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      CreateInvitationScreen()),
                            );
                          }
                        },
                      ),
                      MenuItem(
                        title: 'الماسح الضوئي',
                        icon: Icons.qr_code,
                        onTap: () async {
                          final authUtils = AuthUtils();
                          if (await authUtils.verifyUserStatus(context)) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => QrScannerScreen()),
                            );
                          }
                        },
                      ),
                      MenuItem(
                        title: 'المدعوون',
                        icon: Icons.people,
                        onTap: () async {
                          final authUtils = AuthUtils();
                          if (await authUtils.verifyUserStatus(context)) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GuestsScreen()),
                            );
                          }
                        },
                      ),
                    ]),
                    Divider(
                        color: AppColors.borderColor(context), thickness: 1),
                    SizedBox(height: 20),
                    SectionTitle(title: 'تواصل معنا'),
                    GridMenu(items: [
                      MenuItem(
                        title: 'خدمة العملاء',
                        icon: Icons.support_agent,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ContactUsPage()),
                        ),
                      ),
                      MenuItem(
                        title: 'عندك خدمة؟ انضم إلينا',
                        icon: Icons.home_work,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => QrScannerScreen()),
                        ),
                      ),
                      MenuItem(
                        title: 'واتساب',
                        icon: FontAwesomeIcons.whatsapp,
                        onTap: () => _launchURL('https://wa.me/967774583030'),
                      ),
                    ]),
                    Divider(
                        color: AppColors.borderColor(context), thickness: 1),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) =>
            NavigationService.onItemTapped(context, index, _updateIndex),
      ),
    );
  }
}

// Widget مساعد للعناوين
class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: AppTextStyles.heading(context),
      ),
    );
  }
}
