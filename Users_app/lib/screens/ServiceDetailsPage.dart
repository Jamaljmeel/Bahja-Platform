import 'package:gam/screens/MapPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../booking/screens/booking_dialog.dart';
import '../chat/services/chat_service.dart';
import '../chat/screens/chat_screen.dart';
import '../services/service_details_view_model.dart';
import '../utils/auth_utils.dart';
import '../utils/constants.dart';

class ServiceDetailsPage extends StatefulWidget {
  final String providerId;
  const ServiceDetailsPage({required this.providerId, Key? key})
      : super(key: key);

  @override
  _ServiceDetailsPageState createState() => _ServiceDetailsPageState();
}

class _ServiceDetailsPageState extends State<ServiceDetailsPage> {
  late Future<DocumentSnapshot> _serviceDetailsFuture;
  final ScrollController _scrollController = ScrollController();
  bool _showFloatingButtons = false;
  ChatService chatService = ChatService();
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _serviceDetailsFuture =
        ServiceDetailsViewModel.getServiceDetails(widget.providerId);

    // إضافة استماع للتمرير لعرض/إخفاء الأزرار العائمة
    _scrollController.addListener(() {
      final showButtons = _scrollController.offset > 200;
      if (showButtons != _showFloatingButtons) {
        setState(() {
          _showFloatingButtons = showButtons;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  // تهيئة مشغل الفيديو
  void _initializeVideo(String videoUrl) {
    _videoController = VideoPlayerController.network(videoUrl);
    _videoController!.initialize().then((_) {
      setState(() {
        _isVideoInitialized = true;
      });
    }).catchError((error) {
      print('خطأ في تحميل الفيديو: $error');
    });
  }

  // عرض معرض الصور بحجم كامل
  void _showImageGallery(List<String> images, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoViewGalleryScreen(
          images: images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  // دالة محسنة لفتح رقم الهاتف مع حلول بديلة
  Future<void> _makePhoneCall(String phoneNumber) async {
    try {
      // تنظيف رقم الهاتف
      final cleanPhoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      // المحاولة الأولى: استخدام tel:
      final Uri telUri = Uri(scheme: 'tel', path: cleanPhoneNumber);

      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri);
        return;
      }

      // المحاولة الثانية: نسخ الرقم إلى الحافظة وإظهار رسالة
      await Clipboard.setData(ClipboardData(text: cleanPhoneNumber));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم نسخ رقم الهاتف: $cleanPhoneNumber'),
            action: SnackBarAction(
              label: 'اتصال',
              onPressed: () {
                // يمكن للمستخدم الذهاب يدوياً لتطبيق الهاتف
              },
            ),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('لا يمكن فتح تطبيق الهاتف')),
        );
      }
    }
  }

  // دالة محسنة لفتح البريد الإلكتروني
  Future<void> _sendEmail(String email) async {
    try {
      final Uri emailUri = Uri(scheme: 'mailto', path: email);

      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        return;
      }

      // نسخ البريد الإلكتروني إلى الحافظة كبديل
      await Clipboard.setData(ClipboardData(text: email));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم نسخ البريد الإلكتروني: $email'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('لا يمكن فتح تطبيق البريد الإلكتروني')),
        );
      }
    }
  }

  // دالة محسنة لفتح وسائل التواصل الاجتماعي مع Deep Links
  Future<void> _launchSocialMedia(String? url, String platform) async {
    if (url == null || url.isEmpty) return;

    try {
      String? appUrl;
      String webUrl = url;

      // تنظيف الرابط وإعداد Deep Links حسب المنصة
      if (platform == 'إنستغرام') {
        // استخراج username من الرابط
        String username = _extractInstagramUsername(url);
        if (username.isNotEmpty) {
          appUrl = 'instagram://user?username=$username';
          webUrl = 'https://www.instagram.com/$username';
        }
      } else if (platform == 'فيسبوك') {
        // استخراج page name أو ID من الرابط
        String pageInfo = _extractFacebookPage(url);
        if (pageInfo.isNotEmpty) {
          appUrl = 'fb://profile/$pageInfo';
          webUrl = url.startsWith('http')
              ? url
              : 'https://www.facebook.com/$pageInfo';
        }
      } else if (platform == 'يوتيوب') {
        // استخراج channel info من الرابط
        String channelInfo = _extractYouTubeChannel(url);
        if (channelInfo.isNotEmpty) {
          appUrl = 'youtube://channel/$channelInfo';
          webUrl = url.startsWith('http')
              ? url
              : 'https://www.youtube.com/channel/$channelInfo';
        }
      }

      // محاولة فتح التطبيق أولاً
      if (appUrl != null) {
        final Uri appUri = Uri.parse(appUrl);
        if (await canLaunchUrl(appUri)) {
          await launchUrl(appUri, mode: LaunchMode.externalApplication);
          return;
        }
      }

      // إذا فشل فتح التطبيق، افتح في المتصفح
      if (!webUrl.startsWith('http://') && !webUrl.startsWith('https://')) {
        webUrl = 'https://$webUrl';
      }

      final Uri webUri = Uri.parse(webUrl);
      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
        return;
      }

      // نسخ الرابط كبديل أخير
      await Clipboard.setData(ClipboardData(text: webUrl));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم نسخ رابط $platform: $webUrl'),
            duration: Duration(seconds: 4),
            action: SnackBarAction(
              label: 'فتح',
              onPressed: () {
                // يمكن للمستخدم لصق الرابط يدوياً
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في فتح $platform: ${e.toString()}')),
        );
      }
    }
  }

  // دالة لاستخراج username من رابط الإنستجرام
  String _extractInstagramUsername(String url) {
    try {
      // إزالة البروتوكول والدومين
      String cleaned =
          url.replaceAll(RegExp(r'https?://(www\.)?instagram\.com/'), '');
      // إزالة أي معاملات إضافية
      cleaned = cleaned.split('?')[0].split('/')[0];
      return cleaned;
    } catch (e) {
      return url;
    }
  }

  // دالة لاستخراج page info من رابط الفيسبوك
  String _extractFacebookPage(String url) {
    try {
      // إزالة البروتوكول والدومين
      String cleaned =
          url.replaceAll(RegExp(r'https?://(www\.)?facebook\.com/'), '');
      // إزالة أي معاملات إضافية
      cleaned = cleaned.split('?')[0].split('/')[0];
      return cleaned;
    } catch (e) {
      return url;
    }
  }

  // دالة لاستخراج channel info من رابط اليوتيوب
  String _extractYouTubeChannel(String url) {
    try {
      if (url.contains('/channel/')) {
        return url.split('/channel/')[1].split('?')[0].split('/')[0];
      } else if (url.contains('/user/')) {
        return url.split('/user/')[1].split('?')[0].split('/')[0];
      } else if (url.contains('/c/')) {
        return url.split('/c/')[1].split('?')[0].split('/')[0];
      } else {
        // إزالة البروتوكول والدومين
        String cleaned =
            url.replaceAll(RegExp(r'https?://(www\.)?youtube\.com/'), '');
        cleaned = cleaned.split('?')[0].split('/')[0];
        return cleaned;
      }
    } catch (e) {
      return url;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _serviceDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'الخدمة غير متوفرة',
                    style: AppTextStyles.extraLarge(context).copyWith(
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back),
                    label: Text('العودة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  )
                ],
              ),
            );
          }

          final serviceData =
              (snapshot.data?.data() ?? {}) as Map<String, dynamic>;
          final String serviceId = snapshot.data!.id;

          final String companyName = serviceData['companyName'] ?? 'غير متوفر';
          final String details = serviceData['details'] ?? '';
          final String? email = serviceData['email'];
          final String? phone = serviceData['phone'];
          final String? province = serviceData['province'];
          final String? region = serviceData['region'];
          final String? serviceType = serviceData['service'];
          final String? facebook = serviceData['facebook'];
          final String? instagram = serviceData['instagram'];
          final String? youtube = serviceData['youtube'];
          final String? videoUrl =
              serviceData['videoPath']; // إضافة حقل الفيديو
          final double? priceFrom = serviceData['priceFrom']?.toDouble();
          final double? priceTo = serviceData['priceTo']?.toDouble();
          final double? finalPrice = serviceData['finalPrice']?.toDouble();
          final bool hasOffer = serviceData['hasOffer'] ?? false;
          final double? discount = serviceData['discount']?.toDouble();
          final String? offerDetails = serviceData['offerDetails'];
          final String? offerStartDate = serviceData['offerStartDate'];
          final String? offerEndDate = serviceData['offerEndDate'];
          final List<String> eventTypes =
              List<String>.from(serviceData['eventTypes'] ?? []);
          final List<String> serviceImages =
              List<String>.from(serviceData['serviceImages'] ?? []);
          final String providerImage = serviceData['companyLogo'] ?? '';
          final String defaultImage = '';

          // تهيئة الفيديو إذا كان متوفراً
          if (videoUrl != null &&
              videoUrl.isNotEmpty &&
              _videoController == null) {
            _initializeVideo(videoUrl);
          }

          return Stack(
            children: [
              // محتوى الصفحة
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // قسم الصورة الرئيسية مع التفاصيل الأولية
                  SliverToBoxAdapter(
                    child: Stack(
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
                                image: NetworkImage(providerImage.isNotEmpty
                                    ? providerImage
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
                                    if (providerImage.isNotEmpty)
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundImage:
                                            NetworkImage(providerImage),
                                        backgroundColor: Colors.white,
                                      ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            companyName,
                                            style: AppTextStyles.title(context)
                                                .copyWith(
                                              color: Colors.white,
                                            ),
                                          ),
                                          if (serviceType != null)
                                            Text(
                                              serviceType,
                                              style:
                                                  AppTextStyles.medium(context)
                                                      .copyWith(
                                                color: Colors.white
                                                    .withOpacity(0.8),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (hasOffer && discount != null)
                                  Container(
                                    margin: EdgeInsets.only(top: 10),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'خصم $discount%',
                                      style: AppTextStyles.medium(context)
                                          .copyWith(
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
                    ),
                  ),

                  // بقية المحتوى
                  SliverToBoxAdapter(
                    child: Transform.translate(
                      offset: Offset(0, -30),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.backgroundColor(context),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(30),
                          ),
                        ),
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // قسم السعر
                            if (priceFrom != null ||
                                priceTo != null ||
                                finalPrice != null)
                              Card(
                                elevation: 4,
                                color: AppColors.inputFillColor(context),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                margin: EdgeInsets.only(bottom: 20),
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'التسعير',
                                        style: AppTextStyles.extraLarge(context)
                                            .copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      Divider(),
                                      if (priceFrom != null && priceTo != null)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'نطاق السعر:',
                                                style: AppTextStyles.medium(
                                                        context)
                                                    .copyWith(
                                                  color: AppColors.textColor(
                                                          context)
                                                      .withOpacity(0.7),
                                                ),
                                              ),
                                              Text(
                                                '$priceFrom - $priceTo ريال',
                                                style:
                                                    AppTextStyles.large(context)
                                                        .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if (finalPrice != null)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'السعر النهائي:',
                                                style: AppTextStyles.medium(
                                                        context)
                                                    .copyWith(
                                                  color: AppColors.textColor(
                                                          context)
                                                      .withOpacity(0.7),
                                                ),
                                              ),
                                              Text(
                                                '$finalPrice ريال',
                                                style: AppTextStyles.extraLarge(
                                                        context)
                                                    .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if (hasOffer &&
                                          discount != null &&
                                          offerDetails != null)
                                        Container(
                                          margin: EdgeInsets.only(top: 8),
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                color: Colors.red
                                                    .withOpacity(0.3)),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(Icons.local_offer,
                                                      color: Colors.red,
                                                      size: 16),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    'خصم $discount% متاح!',
                                                    style: AppTextStyles.medium(
                                                            context)
                                                        .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                offerDetails,
                                                style:
                                                    AppTextStyles.small(context)
                                                        .copyWith(
                                                  color: AppColors.textColor(
                                                          context)
                                                      .withOpacity(0.8),
                                                ),
                                              ),
                                              if (offerStartDate != null &&
                                                  offerEndDate != null)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5),
                                                  child: Text(
                                                    'ساري من $offerStartDate إلى $offerEndDate',
                                                    style: AppTextStyles.small(
                                                            context)
                                                        .copyWith(
                                                      fontStyle:
                                                          FontStyle.italic,
                                                      color:
                                                          AppColors.textColor(
                                                                  context)
                                                              .withOpacity(0.6),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),

                            // قسم الفيديو التوضيحي
                            if (videoUrl != null && videoUrl.isNotEmpty)
                              Card(
                                elevation: 4,
                                color: AppColors.inputFillColor(context),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                margin: EdgeInsets.only(bottom: 20),
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'الفيديو التوضيحي',
                                        style: AppTextStyles.extraLarge(context)
                                            .copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      Divider(),
                                      SizedBox(height: 10),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          height: 200,
                                          width: double.infinity,
                                          color: Colors.black,
                                          child: _isVideoInitialized
                                              ? Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    AspectRatio(
                                                      aspectRatio:
                                                          _videoController!
                                                              .value
                                                              .aspectRatio,
                                                      child: VideoPlayer(
                                                          _videoController!),
                                                    ),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.black
                                                            .withOpacity(0.3),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50),
                                                      ),
                                                      child: IconButton(
                                                        iconSize: 50,
                                                        icon: Icon(
                                                          _videoController!
                                                                  .value
                                                                  .isPlaying
                                                              ? Icons.pause
                                                              : Icons
                                                                  .play_arrow,
                                                          color: Colors.white,
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            if (_videoController!
                                                                .value
                                                                .isPlaying) {
                                                              _videoController!
                                                                  .pause();
                                                            } else {
                                                              _videoController!
                                                                  .play();
                                                            }
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                    Positioned(
                                                      bottom: 10,
                                                      left: 10,
                                                      right: 10,
                                                      child:
                                                          VideoProgressIndicator(
                                                        _videoController!,
                                                        allowScrubbing: true,
                                                        colors:
                                                            VideoProgressColors(
                                                          playedColor:
                                                              AppColors.primary,
                                                          bufferedColor:
                                                              AppColors.grey,
                                                          backgroundColor:
                                                              Colors.white
                                                                  .withOpacity(
                                                                      0.3),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Container(
                                                  alignment: Alignment.center,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      CircularProgressIndicator(
                                                        color:
                                                            AppColors.primary,
                                                      ),
                                                      SizedBox(height: 10),
                                                      Text(
                                                        'جاري تحميل الفيديو...',
                                                        style: AppTextStyles
                                                                .medium(context)
                                                            .copyWith(
                                                          color: Colors.white,
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
                              ),

                            // قسم معلومات الاتصال
                            Card(
                              elevation: 4,
                              color: AppColors.inputFillColor(context),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              margin: EdgeInsets.only(bottom: 20),
                              child: Container(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'معلومات الاتصال',
                                      style: AppTextStyles.extraLarge(context)
                                          .copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    Divider(),
                                    if (phone != null)
                                      _buildContactItem(
                                        FontAwesomeIcons.phone,
                                        phone,
                                        onTap: () => _makePhoneCall(phone),
                                      ),
                                    if (email != null)
                                      _buildContactItem(
                                        FontAwesomeIcons.envelope,
                                        email,
                                        onTap: () => _sendEmail(email),
                                      ),
                                    if (province != null && region != null)
                                      _buildContactItem(
                                        FontAwesomeIcons.mapMarkerAlt,
                                        '$province، $region',
                                        onTap: () => "",
                                      ),
                                  ],
                                ),
                              ),
                            ),

                            // وسائل التواصل الاجتماعي
                            if (facebook != null ||
                                instagram != null ||
                                youtube != null)
                              Card(
                                elevation: 4,
                                color: AppColors.inputFillColor(context),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                margin: EdgeInsets.only(bottom: 20),
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'تابعنا',
                                        style: AppTextStyles.extraLarge(context)
                                            .copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      Divider(),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            if (facebook != null)
                                              _buildSocialMediaButton(
                                                FontAwesomeIcons.facebook,
                                                Colors.blue[700]!,
                                                'فيسبوك',
                                                () => _launchSocialMedia(
                                                    facebook, 'فيسبوك'),
                                              ),
                                            if (instagram != null)
                                              _buildSocialMediaButton(
                                                FontAwesomeIcons.instagram,
                                                Colors.pink[700]!,
                                                'إنستغرام',
                                                () => _launchSocialMedia(
                                                    instagram, 'إنستغرام'),
                                              ),
                                            if (youtube != null)
                                              _buildSocialMediaButton(
                                                FontAwesomeIcons.youtube,
                                                Colors.red[700]!,
                                                'يوتيوب',
                                                () => _launchSocialMedia(
                                                    youtube, 'يوتيوب'),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            // عرض الخريطة الصغيرة إذا كانت الإحداثيات متوفرة
                            if (serviceData['latitude'] != null &&
                                serviceData['longitude'] != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 16),
                                  Text(
                                    'الموقع على الخريطة',
                                    style:
                                        AppTextStyles.large(context).copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  _buildSimpleMiniMap(
                                    serviceData['latitude'].toDouble(),
                                    serviceData['longitude'].toDouble(),
                                    companyName,
                                  ),
                                ],
                              ),

                            // أنواع المناسبات
                            if (eventTypes.isNotEmpty)
                              Card(
                                elevation: 4,
                                color: AppColors.inputFillColor(context),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                margin: EdgeInsets.only(bottom: 20),
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'أنواع المناسبات',
                                        style: AppTextStyles.extraLarge(context)
                                            .copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      Divider(),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: eventTypes
                                            .map((type) => Chip(
                                                  label: Text(
                                                    type,
                                                    style: AppTextStyles.small(
                                                        context),
                                                  ),
                                                  backgroundColor: AppColors
                                                      .primary
                                                      .withOpacity(0.1),
                                                ))
                                            .toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            // التفاصيل
                            if (details.isNotEmpty)
                              Card(
                                elevation: 4,
                                color: AppColors.inputFillColor(context),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                margin: EdgeInsets.only(bottom: 20),
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'نبذة عن الخدمة',
                                        style: AppTextStyles.extraLarge(context)
                                            .copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      Divider(),
                                      Text(
                                        details,
                                        style: AppTextStyles.medium(context)
                                            .copyWith(
                                          height: 1.5,
                                        ),
                                        textAlign: TextAlign.justify,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            // معرض الصور بتصميم محسن
                            if (serviceImages.isNotEmpty) ...[
                              Text(
                                'معرض الصور',
                                style:
                                    AppTextStyles.extraLarge(context).copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(height: 12),
                              _buildEnhancedGallery(serviceImages, context),
                              SizedBox(height: 20),
                            ],

                            // زر الخطوات
                            Container(
                              height: 100, // مساحة إضافية للأزرار الثابتة
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

// أزرار الإجراءات الثابتة في الأسفل
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor(context),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // زر الحجز
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(FontAwesomeIcons.calendarCheck, size: 18),
                          label: Text(
                            'حجز الخدمة',
                            style: AppTextStyles.large(context).copyWith(
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            final authUtils = AuthUtils();
                            bool isValid =
                                await authUtils.verifyUserStatus(context);

                            if (isValid) {
                              showDialog(
                                context: context,
                                builder: (context) => BookingDialog(
                                  serviceData: serviceData,
                                  providerId: widget.providerId,
                                ),
                              ).then((confirmed) {
                                if (confirmed == true) {
                                  // تم تأكيد الحجز
                                }
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 12),
                      // زر المحادثة
                      ElevatedButton.icon(
                        icon: Icon(FontAwesomeIcons.solidCommentDots, size: 18),
                        label: Text(
                          'محادثة',
                          style: AppTextStyles.large(context).copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          elevation: 2,
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: AppColors.primary),
                          ),
                        ),
                        onPressed: () async {
                          final authUtils = AuthUtils();
                          bool isValid =
                              await authUtils.verifyUserStatus(context);

                          if (isValid) {
                            // جلب أو إنشاء chatId
                            String? userId =
                                await chatService.checkLoginStatus(context);
                            if (userId == null) return;

                            String chatId = await chatService.getOrCreateChat(
                                userId, widget.providerId);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  chatId: chatId,
                                  userId: userId,
                                  providerId: widget.providerId,
                                  providerName: companyName,
                                  providerImage: providerImage,
                                  serviceId: serviceId,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // زر العودة للأعلى (يظهر عند التمرير)
              if (_showFloatingButtons)
                Positioned(
                  bottom: 100,
                  right: 16,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    elevation: 4,
                    child: Icon(Icons.arrow_upward),
                    onPressed: () {
                      _scrollController.animateTo(
                        0,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // دالة بناء عنصر اتصال محسن
  Widget _buildContactItem(IconData icon, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: FaIcon(icon, color: AppColors.primary, size: 16),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                style: AppTextStyles.medium(context),
              ),
            ),
            if (onTap != null)
              Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.grey),
          ],
        ),
      ),
    );
  }

  // دالة بناء أزرار وسائل التواصل الاجتماعي
  Widget _buildSocialMediaButton(
      IconData icon, Color color, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: FaIcon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.small(context),
          ),
        ],
      ),
    );
  }

  // دالة بناء خريطة صغيرة قابلة للضغط
  Widget _buildSimpleMiniMap(
      double latitude, double longitude, String companyName) {
    return GestureDetector(
      onTap: () {
        // الانتقال لصفحة الخريطة مع التركيز على موقع الخدمة
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapPage(
              focusLatitude: latitude,
              focusLongitude: longitude,
              focusTitle: companyName,
            ),
          ),
        );
      },
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(latitude, longitude),
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId('service_location'),
                    position: LatLng(latitude, longitude),
                  ),
                },
                zoomControlsEnabled: false,
                scrollGesturesEnabled: false,
                rotateGesturesEnabled: false,
                tiltGesturesEnabled: false,
                mapToolbarEnabled: false,
                myLocationButtonEnabled: false,
                compassEnabled: false,
                zoomGesturesEnabled: false,
              ),
              // إضافة تأثير بصري للإشارة إلى إمكانية الضغط
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                ),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.fullscreen,
                          color: Colors.white,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'عرض في الخريطة',
                          style: AppTextStyles.extraSmall(context).copyWith(
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
      ),
    );
  }

  // معرض صور محسن مع إمكانية التكبير
  Widget _buildEnhancedGallery(List<String> images, BuildContext context) {
    return Container(
      height: 200,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: images.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // عرض الصورة بالحجم الكامل
                _showImageGallery(images, index);
              },
              child: Container(
                width: 200,
                margin: EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Stack(
                    children: [
                      Image.network(
                        images[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: AppColors.borderColor(context),
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.borderColor(context),
                            child: Center(
                              child: Icon(Icons.error, color: AppColors.grey),
                            ),
                          );
                        },
                      ),
                      // أيقونة التكبير
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.zoom_in,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// شاشة عرض معرض الصور بحجم كامل
class PhotoViewGalleryScreen extends StatelessWidget {
  final List<String> images;
  final int initialIndex;

  const PhotoViewGalleryScreen({
    Key? key,
    required this.images,
    required this.initialIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                '${initialIndex + 1} من ${images.length}',
                style: AppTextStyles.large(context).copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(images[index]),
            initialScale: PhotoViewComputedScale.contained,
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 2,
            heroAttributes: PhotoViewHeroAttributes(tag: images[index]),
          );
        },
        itemCount: images.length,
        loadingBuilder: (context, event) => Center(
          child: Container(
            width: 40.0,
            height: 40.0,
            child: CircularProgressIndicator(
              color: Colors.white,
              value: event == null
                  ? 0
                  : event.cumulativeBytesLoaded /
                      (event.expectedTotalBytes ?? 1),
            ),
          ),
        ),
        backgroundDecoration: BoxDecoration(color: Colors.black),
        pageController: PageController(initialPage: initialIndex),
        onPageChanged: (index) {
          // يمكن إضافة منطق إضافي هنا إذا احتجت
        },
      ),
    );
  }
}
