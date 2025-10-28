import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../model/service_model.dart';
import '../utils/constants.dart';

class ServiceHeader extends StatelessWidget {
  final ServiceModel service;

  const ServiceHeader({
    Key? key,
    required this.service,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // صورة الغلاف مع تأثير التعتيم
        ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black, Colors.transparent],
            ).createShader(
                Rect.fromLTRB(0, 180, rect.width, rect.height));
          },
          blendMode: BlendMode.dstIn,
          child: Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(service.companyLogo.isNotEmpty
                    ? service.companyLogo
                    : 'https://images.icon-icons.com/2518/PNG/512/photo_icon_151153.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        // تراكب معلومات الشركة
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (service.companyLogo.isNotEmpty)
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(service.companyLogo),
                        backgroundColor: Colors.white,
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.companyName,
                            style: AppTextStyles.title(context).copyWith(
                              color: Colors.white,
                            ),
                          ),
                          if (service.serviceType != null)
                            Text(
                              service.serviceType!,
                              style: AppTextStyles.medium(context).copyWith(
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (service.hasOffer && service.discount != null)
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'خصم ${service.discount}%',
                      style: AppTextStyles.medium(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}