import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/ServiceDetailsPage.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/service_providers_card.dart';

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<String> _favoriteProviders = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  // 🔹 تحميل قائمة المفضلات من SharedPreferences
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteProviders = prefs.getStringList('favorites') ?? []; // تأكد أن المفتاح مطابق للصفحة الأخرى
    });
  }

  // 🔹 إزالة عنصر من المفضلة
  Future<void> _removeFromFavorites(String providerId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteProviders.remove(providerId);
    });
    await prefs.setStringList('favorites', _favoriteProviders);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'المفضلة'),
      body: _favoriteProviders.isEmpty
          ? Center(
              child: Text(
                'لا يوجد خدمات مفضلة',
                style: GoogleFonts.elMessiri(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            )
          : FutureBuilder<List<DocumentSnapshot>>(
            // تنتظر اكتمال كل طلبات Firebase.
              future: Future.wait(
                _favoriteProviders.map(
                  (providerId) => FirebaseFirestore.instance.collection('service_providers').doc(providerId).get(),
                ),
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('حدث خطأ في تحميل البيانات'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('لا يوجد خدمات مفضلة'));
                }

                final providers = snapshot.data!;

                return ListView.builder(
                  itemCount: providers.length,
                  itemBuilder: (context, index) {
                    final provider = providers[index].data() as Map<String, dynamic>?;
                    final providerId = providers[index].id;

                    if (provider == null) return SizedBox(); // تجنب الأخطاء في حال عدم وجود بيانات

                    return GestureDetector(
                      onTap: () {
                        // ✅ الانتقال إلى صفحة التفاصيل عند الضغط على الخدمة
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServiceDetailsPage(providerId: providerId),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ServiceProvidersCard(
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
                          isFavorite: true,
                          onFavoriteToggle: () => _removeFromFavorites(providerId), // عند الضغط، احذف من المفضلة
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
