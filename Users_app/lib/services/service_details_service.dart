import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../model/service_model.dart';

class ServiceDetailsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // جلب تفاصيل الخدمة
  Future<ServiceModel?> getServiceDetails(String providerId) async {
    try {
      final doc = await _firestore.collection('service_providers').doc(providerId).get();
      if (doc.exists) {
        return ServiceModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('خطأ في جلب تفاصيل الخدمة: $e');
    }
  }

  // إجراء مكالمة هاتفية
  Future<void> makePhoneCall(String phoneNumber) async {
    try {
      final cleanPhoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      final Uri telUri = Uri(scheme: 'tel', path: cleanPhoneNumber);

      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri);
        return;
      }

      // نسخ الرقم كبديل
      await Clipboard.setData(ClipboardData(text: cleanPhoneNumber));
      throw Exception('تم نسخ رقم الهاتف: $cleanPhoneNumber');
    } catch (e) {
      throw Exception('لا يمكن فتح تطبيق الهاتف');
    }
  }

  // إرسال بريد إلكتروني
  Future<void> sendEmail(String email) async {
    try {
      final Uri emailUri = Uri(scheme: 'mailto', path: email);

      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        return;
      }

      // نسخ البريد كبديل
      await Clipboard.setData(ClipboardData(text: email));
      throw Exception('تم نسخ البريد الإلكتروني: $email');
    } catch (e) {
      throw Exception('لا يمكن فتح تطبيق البريد الإلكتروني');
    }
  }

  // فتح وسائل التواصل الاجتماعي
  Future<void> launchSocialMedia(String? url, String platform) async {
    if (url == null || url.isEmpty) return;

    try {
      String? appUrl;
      String webUrl = url;

      // إعداد Deep Links حسب المنصة
      switch (platform) {
        case 'إنستغرام':
          String username = _extractInstagramUsername(url);
          if (username.isNotEmpty) {
            appUrl = 'instagram://user?username=$username';
            webUrl = 'https://www.instagram.com/$username';
          }
          break;
        case 'فيسبوك':
          String pageInfo = _extractFacebookPage(url);
          if (pageInfo.isNotEmpty) {
            appUrl = 'fb://profile/$pageInfo';
            webUrl = url.startsWith('http') ? url : 'https://www.facebook.com/$pageInfo';
          }
          break;
        case 'يوتيوب':
          String channelInfo = _extractYouTubeChannel(url);
          if (channelInfo.isNotEmpty) {
            appUrl = 'youtube://channel/$channelInfo';
            webUrl = url.startsWith('http') ? url : 'https://www.youtube.com/channel/$channelInfo';
          }
          break;
      }

      // محاولة فتح التطبيق أولاً
      if (appUrl != null) {
        final Uri appUri = Uri.parse(appUrl);
        if (await canLaunchUrl(appUri)) {
          await launchUrl(appUri, mode: LaunchMode.externalApplication);
          return;
        }
      }

      // فتح في المتصفح
      if (!webUrl.startsWith('http://') && !webUrl.startsWith('https://')) {
        webUrl = 'https://$webUrl';
      }

      final Uri webUri = Uri.parse(webUrl);
      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
        return;
      }

      // نسخ الرابط كبديل
      await Clipboard.setData(ClipboardData(text: webUrl));
      throw Exception('تم نسخ رابط $platform: $webUrl');
    } catch (e) {
      throw Exception('خطأ في فتح $platform: ${e.toString()}');
    }
  }

  // استخراج اسم المستخدم من رابط الإنستغرام
  String _extractInstagramUsername(String url) {
    try {
      String cleaned = url.replaceAll(RegExp(r'https?://(www\.)?instagram\.com/'), '');
      cleaned = cleaned.split('?')[0].split('/')[0];
      return cleaned;
    } catch (e) {
      return url;
    }
  }

  // استخراج معلومات الصفحة من رابط الفيسبوك
  String _extractFacebookPage(String url) {
    try {
      String cleaned = url.replaceAll(RegExp(r'https?://(www\.)?facebook\.com/'), '');
      cleaned = cleaned.split('?')[0].split('/')[0];
      return cleaned;
    } catch (e) {
      return url;
    }
  }

  // استخراج معلومات القناة من رابط اليوتيوب
  String _extractYouTubeChannel(String url) {
    try {
      if (url.contains('/channel/')) {
        return url.split('/channel/')[1].split('?')[0].split('/')[0];
      } else if (url.contains('/user/')) {
        return url.split('/user/')[1].split('?')[0].split('/')[0];
      } else if (url.contains('/c/')) {
        return url.split('/c/')[1].split('?')[0].split('/')[0];
      } else {
        String cleaned = url.replaceAll(RegExp(r'https?://(www\.)?youtube\.com/'), '');
        cleaned = cleaned.split('?')[0].split('/')[0];
        return cleaned;
      }
    } catch (e) {
      return url;
    }
  }
}