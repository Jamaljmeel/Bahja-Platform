import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import 'ServiceDetailsPage.dart';
import '../utils/constants.dart';
import '../theme/app_theme.dart';

class MapPage extends StatefulWidget {
  final double? focusLatitude;
  final double? focusLongitude;
  final String? focusTitle;

  const MapPage({
    Key? key,
    this.focusLatitude,
    this.focusLongitude,
    this.focusTitle,
  }) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Map<String, dynamic>? _selectedService;
  bool _isLoading = true;

  late CameraPosition _initialPosition;

  @override
  void initState() {
    super.initState();
    // تحديد الموقع الأولي بناءً على المعاملات
    if (widget.focusLatitude != null && widget.focusLongitude != null) {
      _initialPosition = CameraPosition(
        target: LatLng(widget.focusLatitude!, widget.focusLongitude!),
        zoom: 16,
      );
    } else {
      _initialPosition = CameraPosition(
        target: LatLng(15.3694, 44.191), // صنعاء
        zoom: 12,
      );
    }
    
    _requestLocationPermission();
    _loadServiceLocations();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      print("تم رفض صلاحية الموقع");
    }
  }

  // تحميل مواقع الخدمات من قاعدة البيانات
  Future<void> _loadServiceLocations() async {
    try {
      final QuerySnapshot servicesSnapshot = await FirebaseFirestore.instance
          .collection('service_providers')
          .where('hasOffer', isEqualTo: true)
          .get();

      Set<Marker> markers = {};
      
      for (var doc in servicesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        
        // التحقق من وجود إحداثيات
        if (data['latitude'] != null && data['longitude'] != null) {
          final lat = data['latitude'].toDouble();
          final lng = data['longitude'].toDouble();
          final companyName = data['companyName'] ?? 'خدمة غير محددة';
          final serviceType = data['service'] ?? '';
          final companyLogo = data['companyLogo'] ?? '';
          
          markers.add(
            Marker(
              markerId: MarkerId(doc.id),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(
                title: companyName,
                snippet: serviceType,
                onTap: () => _onMarkerTapped(doc.id, data),
              ),
              icon: await _getCustomMarkerIcon(),
              onTap: () => _onMarkerTapped(doc.id, data),
            ),
          );
        }
      }

      setState(() {
        _markers = markers;
        _isLoading = false;
      });

    } catch (e) {
      print('خطأ في تحميل مواقع الخدمات: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // إنشاء أيقونة مخصصة للعلامات
  Future<BitmapDescriptor> _getCustomMarkerIcon() async {
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
  }

  // عند الضغط على العلامة
  void _onMarkerTapped(String serviceId, Map<String, dynamic> serviceData) {
    setState(() {
      _selectedService = serviceData;
      _selectedService!['id'] = serviceId;
    });
    
    // عرض معلومات الخدمة في النافذة السفلية
    _showServiceBottomSheet(serviceId, serviceData);
  }

  // عرض معلومات الخدمة في نافذة سفلية
  void _showServiceBottomSheet(String serviceId, Map<String, dynamic> serviceData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.20,
        decoration: BoxDecoration(
          color: AppColors.backgroundColor(context),
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            // مقبض النافذة
            Container(
              margin: EdgeInsets.only(top: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderColor(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            SizedBox(height: 20),
            
            // محتوى النافذة
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // معلومات الشركة
                    Row(
                      children: [
                        // شعار الشركة
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: serviceData['companyLogo'] != null && 
                                   serviceData['companyLogo'].isNotEmpty
                                ? Image.network(
                                    serviceData['companyLogo'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        _buildDefaultLogo(),
                                  )
                                : _buildDefaultLogo(),
                          ),
                        ),
                        
                        SizedBox(width: 15),
                        
                        // معلومات الشركة
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                serviceData['companyName'] ?? 'غير محدد',
                                style: AppTextStyles.extraLarge(context).copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              
                              SizedBox(height: 4),
                              
                              if (serviceData['service'] != null)
                                Text(
                                  serviceData['service'],
                                  style: AppTextStyles.medium(context).copyWith(
                                    color: AppColors.textColor(context).withOpacity(0.7),
                                  ),
                                ),
                              
                              SizedBox(height: 8),
                              
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    // زر عرض التفاصيل
                    CustomButton(
                      text: 'عرض تفاصيل الخدمة',
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServiceDetailsPage(
                              providerId: serviceId,
                            ),
                          ),
                        );
                      },
                      backgroundColor: _isLoading ? AppColors.grey : AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // بناء شعار افتراضي
  Widget _buildDefaultLogo() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(
        Icons.business,
        color: AppColors.primary,
        size: 30,
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    print("تم تحميل الخريطة");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: CustomAppBar(title: 'البحث بالخريطة '),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: _initialPosition,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            compassEnabled: true,
            mapToolbarEnabled: false,
          ),
          
          // مؤشر التحميل
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                      SizedBox(height: 15),
                      Text(
                        'جاري تحميل مواقع الخدمات...',
                        style: AppTextStyles.medium(context).copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // معلومات إحصائية في الأعلى
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'تم العثور على ${_markers.length} خدمة',
                    style: AppTextStyles.medium(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}