import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_colors.dart';

class SocialIcon extends StatelessWidget {
  final IconData icon;
  final String url;

  const SocialIcon({Key? key, required this.icon, required this.url}) : super(key: key);

  Future<void> _launchURL() async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('❌ لا يمكن فتح الرابط: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: _launchURL,
      child: CircleAvatar(
        backgroundColor: isDark 
            ? AppColors.inputFillDark
            : AppColors.inputFillLight,
        child: Icon(
          icon, 
          color: isDark ? AppColors.primaryDark : AppColors.primaryLight
        ),
      ),
    );
  }
}