// صفحة اختيار الموقع
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:google_fonts/google_fonts.dart';

import '../utils/app_colors.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const LocationPickerScreen({Key? key, this.initialLocation}) : super(key: key);

  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  String? _address;
  bool _isLoading = false;
  loc.Location location = loc.Location();

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    if (_selectedLocation != null) {
      _getAddressFromLatLng(_selectedLocation!);
    }
  }

  Future<void> _getAddressFromLatLng(LatLng location) async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        setState(() {
          _address = '${placemark.street}, ${placemark.locality}, ${placemark.country}';
        });
      }
    } catch (e) {
      print('خطأ في الحصول على العنوان: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      // فحص إذا كانت خدمة الموقع مفعلة
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }

      // فحص صلاحيات الوصول للموقع
      loc.PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) {
          return;
        }
      }

      // الحصول على الموقع الحالي
      loc.LocationData locationData = await location.getLocation();
      LatLng currentLocation = LatLng(locationData.latitude!, locationData.longitude!);

      setState(() {
        _selectedLocation = currentLocation;
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLng(currentLocation),
      );

      await _getAddressFromLatLng(currentLocation);
    } catch (e) {
      print('خطأ في الحصول على الموقع الحالي: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          ' موقعك بالخريطة',
          style: GoogleFonts.elMessiri(
            fontWeight: FontWeight.bold,
          ),
        ),
            backgroundColor:
          isDark ? AppColors.primaryDark : AppColors.primaryLight,
        actions: [
          if (_selectedLocation != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context, {
                  'location': _selectedLocation,
                  'address': _address,
                });
              },
              child: Text(
                'تأكيد',
                style: GoogleFonts.elMessiri(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            initialCameraPosition: CameraPosition(
              target: widget.initialLocation ?? const LatLng(33.2232, 43.6793), // بغداد كموقع افتراضي
              zoom: 15,
            ),
            onTap: (LatLng location) async {
              setState(() {
                _selectedLocation = location;
              });
              await _getAddressFromLatLng(location);
            },
            markers: _selectedLocation != null
                ? {
                    Marker(
                      markerId: const MarkerId('selected_location'),
                      position: _selectedLocation!,
                      infoWindow: InfoWindow(
                        title: 'موقع الخدمة',
                        snippet: _address ?? 'الموقع المحدد',
                      ),
                    ),
                  }
                : {},
          ),
          
          // معلومات الموقع
          if (_selectedLocation != null)
            Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.backgroundDark : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'الموقع المحدد',
                            style: GoogleFonts.elMessiri(
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: CircularProgressIndicator(),
                      )
                    else if (_address != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _address!,
                          style: GoogleFonts.elMessiri(
                            color: isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // زر الموقع الحالي
          Positioned(
            bottom: 180,
            right: 16,
            child: FloatingActionButton(
              onPressed: _getCurrentLocation,
              backgroundColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
              child: const Icon(
                Icons.my_location,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}