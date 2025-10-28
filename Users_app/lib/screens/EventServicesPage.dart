import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/section_card.dart';
import 'service_providers_page.dart';
import '../utils/constants.dart';

class EventServicesPage extends StatefulWidget {
  final String initialSearchQuery;

  EventServicesPage({
    Key? key,
    this.initialSearchQuery = '',
  }) : super(key: key);

  @override
  _EventServicesPageState createState() => _EventServicesPageState();
}

class _EventServicesPageState extends State<EventServicesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialSearchQuery;
    _searchController = TextEditingController(text: _searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: CustomAppBar(title: 'خدمات المناسبات'),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search Bar
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.inputFillColor(context),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.borderColor(context).withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: AppColors.primary),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'البحث عن الخدمات',
                          border: InputBorder.none,
                          hintStyle: AppTextStyles.medium(context).copyWith(
                            color: AppColors.textColor(context).withOpacity(0.6),
                          ),
                        ),
                        style: AppTextStyles.medium(context).copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Services Grid
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('services').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'حدث خطأ: ${snapshot.error}',
                          style: AppTextStyles.medium(context).copyWith(color: Colors.red),
                        ),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          'لا توجد خدمات متاحة',
                          style: AppTextStyles.large(context),
                        ),
                      );
                    }

                    final allServices = snapshot.data!.docs;
                    
                    // فلترة الخدمات حسب نص البحث
                    final filteredServices = _searchQuery.isEmpty 
                      ? allServices 
                      : allServices.where((doc) {
                          final service = doc.data() as Map<String, dynamic>;
                          final serviceName = service['name'] as String? ?? '';
                          return serviceName.toLowerCase().contains(_searchQuery.toLowerCase());
                        }).toList();
                    
                    if (filteredServices.isEmpty) {
                      return Center(
                        child: Text(
                          'لا توجد نتائج مطابقة للبحث',
                          style: AppTextStyles.large(context).copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: filteredServices.length,
                      itemBuilder: (context, index) {
                        final service = filteredServices[index].data() as Map<String, dynamic>;
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ServiceProvidersPage(
                                    serviceName: service['name'],
                                  ),
                                ),
                              );
                            },
                            child: SectionCard(
                              text: service['name'],
                              imagePath: service['imageUrl'],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
