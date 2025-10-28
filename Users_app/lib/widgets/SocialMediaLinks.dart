import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';
import '../theme/app_theme.dart';

class SocialMediaLinks extends StatelessWidget {
  final String? facebook;
  final String? instagram;
  final String? youtube;

  const SocialMediaLinks({Key? key, this.facebook, this.instagram, this.youtube}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          'تابعنا على وسائل التواصل:',
          style: AppTextStyles.medium(context).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            if (facebook != null) _socialButton(Icons.facebook, facebook!, context),
            if (instagram != null) _socialButton(Icons.camera_alt, instagram!, context),
            if (youtube != null) _socialButton(Icons.play_circle_fill, youtube!, context),
          ],
        ),
      ],
    );
  }

  Widget _socialButton(IconData icon, String url, BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      icon: Icon(icon, size: 30, color: theme.primaryColor),
      onPressed: () async {
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
    );
  }
}

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
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: _launchURL,
      child: CircleAvatar(
        backgroundColor: theme.cardColor,
        child: Icon(icon, color: theme.primaryColor),
      ),
    );
  }
}