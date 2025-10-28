import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../theme/app_theme.dart';

class OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;

  const OnboardingPage({
    required this.image,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(image, fit: BoxFit.cover),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withOpacity(0.6), Colors.black.withOpacity(0.4)],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: AppTextStyles.title(context).copyWith(
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black38, blurRadius: 15, offset: Offset(3, 3))],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                subtitle,
                style: AppTextStyles.medium(context).copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}