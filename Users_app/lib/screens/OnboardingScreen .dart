import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/constants.dart';
import '../widgets/Onboarding_widget.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> slides = [
    {
      'image': 'asset/images/logo2.jpg',
      'title': 'مرحبًا بك في Bahja!',
      'subtitle': 'اكتشف أفضل مزودي الخدمات لحفلك بأسعار تنافسية.',
    },
    {
      'image': 'asset/images/photo_5767275355311294165_x.jpg',
      'title': 'دعوات الحفلات الرقمية',
      'subtitle': 'ارسل دعواتك عبر الواتساب مع الباركود للمدعوين',
    },
    {
      'image': 'asset/images/1739290484072.jpg',
      'title': 'مساعد ذكي لتنظيم حفلك',
      'subtitle': 'مساعدك الذكي لاختصار وقتك واختيار افضل!',
    },
  ];

  void _nextPage() {
    if (_currentPage < slides.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(
          context, '/home'); // الانتقال إلى الصفحة الرئيسية
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skip() {
    Navigator.pushReplacementNamed(
        context, '/home'); // الانتقال مباشرة إلى الصفحة الرئيسية
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: slides.length,
            onPageChanged: (int page) {
              setState(() => _currentPage = page);
            },
            itemBuilder: (context, index) {
              return OnboardingPage(
                image: slides[index]['image']!,
                title: slides[index]['title']!,
                subtitle: slides[index]['subtitle']!,
              );
            },
          ),

          // **زر التخطي في الأعلى**
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: _skip,
              child: Text(
                'تخطي',
                style: AppTextStyles.medium(context).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // **أسهم التنقل**
          Positioned(
            left: 20,
            child: _currentPage > 0
                ? IconButton(
                    icon: Icon(Icons.arrow_back_ios,
                        color: Colors.white, size: 30),
                    onPressed: _prevPage,
                  )
                : SizedBox(),
          ),

          Positioned(
            right: 20,
            child: IconButton(
              icon: Icon(
                _currentPage == slides.length - 1
                    ? Icons.check
                    : Icons.arrow_forward_ios,
                color: Colors.white,
                size: 30,
              ),
              onPressed: _nextPage,
            ),
          ),

          // **مؤشرات النقاط**
          Positioned(
            bottom: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                slides.length,
                (index) => AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 12 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color:
                        _currentPage == index ? Colors.white : Colors.white54,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
