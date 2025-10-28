import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/search_bar.dart';
import '../widgets/service_providers_card.dart';
import 'ServiceDetailsPage.dart';
import '../utils/constants.dart';
import '../theme/app_theme.dart';

class OffersPage extends StatefulWidget {
  final int discountPercentage;

  OffersPage({
    Key? key, 
    required this.discountPercentage,
  }) : super(key: key);

  @override
  _OffersPageState createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  Set<String> _favoriteProviders = {};
  String _searchQuery = '';
  late TextEditingController _searchController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 🔹 تحميل قائمة المفضلات من SharedPreferences
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteProviders = prefs.getStringList('favorites')?.toSet() ?? {};
    });
  }

  // 🔹 تحديث المفضلة في SharedPreferences
  Future<void> _toggleFavorite(String providerId) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      if (_favoriteProviders.contains(providerId)) {
        _favoriteProviders.remove(providerId);
      } else {
        _favoriteProviders.add(providerId);
      }
    });

    await prefs.setStringList('favorites', _favoriteProviders.toList());
  }

  // 🔹 استعلام مقدمي الخدمات حسب نسبة الخصم المحددة
  Stream<QuerySnapshot> _getServiceProvidersByDiscount() {
    // استعلام مباشر في صفحة العروض
    return _firestore.collection('service_providers')
        .where('discount', isEqualTo: widget.discountPercentage)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: CustomAppBar(title: 'عروض خصم ${widget.discountPercentage}%'),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.backgroundColor(context),
              AppColors.backgroundColor(context).withOpacity(0.8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // بانر العروض المميز
            Container(
              width: double.infinity,
              height: screenHeight * 0.15,
              margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.blue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // زخارف البانر
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -30,
                    bottom: -30,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  // محتوى البانر
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'احصل على خصم ${widget.discountPercentage}% اليوم!',
                          style: AppTextStyles.heading(context).copyWith(
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(
                          Icons.local_offer,
                          color: Colors.white,
                          size: 28,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      
            // قائمة مقدمي الخدمات
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getServiceProvidersByDiscount(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      )
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline, color: Colors.red, size: 48),
                          SizedBox(height: 16),
                          Text(
                            'حدث خطأ: ${snapshot.error}',
                            style: AppTextStyles.large(context).copyWith(
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_offer_outlined, 
                            color: AppColors.primary, 
                            size: 64
                          ),
                          SizedBox(height: 16),
                          Text(
                            'لا يوجد مقدمي خدمات بخصم ${widget.discountPercentage}% حالياً',
                            style: AppTextStyles.large(context).copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'يرجى المحاولة لاحقاً أو تصفح باقي أقسام التطبيق',
                            style: AppTextStyles.medium(context).copyWith(
                              color: AppColors.textColor(context).withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  final allProviders = snapshot.data!.docs;
                  
                  // فلترة مقدمي الخدمة حسب نص البحث
                  final filteredProviders = _searchQuery.isEmpty 
                    ? allProviders 
                    : allProviders.where((doc) {
                        final provider = doc.data() as Map<String, dynamic>;
                        final companyName = provider['companyName'] as String? ?? '';
                        final region = provider['region'] as String? ?? '';
                        final province = provider['province'] as String? ?? '';
                        
                        return companyName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                              region.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                              province.toLowerCase().contains(_searchQuery.toLowerCase());
                      }).toList();
                  
                  if (filteredProviders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off, color: AppColors.primary, size: 48),
                          SizedBox(height: 16),
                          Text(
                            'لا توجد نتائج مطابقة للبحث',
                            style: AppTextStyles.large(context).copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView.builder(
                      itemCount: filteredProviders.length,
                      itemBuilder: (context, index) {
                        final provider = filteredProviders[index].data() as Map<String, dynamic>;
                        final providerId = filteredProviders[index].id;
                        final isFavorite = _favoriteProviders.contains(providerId);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ServiceDetailsPage(providerId: providerId),
                                ),
                              );
                            },
                            child: Stack(
                              children: [
                                ServiceProvidersCard(
                                  companyName: provider['companyName'],
                                  location: '${provider['region']}, ${provider['province']}',
                                  phone: provider['phone'],
                                  companyLogo: provider['companyLogo'] ?? 'asset/images/event-management-4.jpeg',
                                  // rating: provider['ratings']?.toDouble() ?? 0.0,
                                  // reviewsCount: provider['reviewsCount'] ?? 0,
                                  finalPrice: provider['finalPrice'],
                                  priceFrom: provider['priceFrom'],
                                  priceTo: provider['priceTo'],
                                  discount: provider['discount'],
                                  isFavorite: isFavorite,
                                  onFavoriteToggle: () => _toggleFavorite(providerId),
                                ),
                                // ملصق العرض
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      'خصم ${widget.discountPercentage}%',
                                      style: AppTextStyles.small(context).copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}