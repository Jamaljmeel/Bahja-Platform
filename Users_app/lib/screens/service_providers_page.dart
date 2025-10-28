import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/search_bar.dart';
import '../widgets/service_providers_card.dart';
import '../services/service_providers_view_model.dart';
import 'ServiceDetailsPage.dart';
import '../utils/constants.dart';
import '../theme/app_theme.dart';

class ServiceProvidersPage extends StatefulWidget {
  final String serviceName;
  final String initialSearchQuery;
  final ServiceProvidersViewModel _viewModel = ServiceProvidersViewModel();

  ServiceProvidersPage({
    Key? key, 
    required this.serviceName,
    this.initialSearchQuery = '',
  }) : super(key: key);

  @override
  _ServiceProvidersPageState createState() => _ServiceProvidersPageState();
}

class _ServiceProvidersPageState extends State<ServiceProvidersPage> {
  Set<String> _favoriteProviders = {};
  late String _searchQuery;
  late TextEditingController _searchController;
  
  // متغيرات الفلترة
  String? _selectedProvince;
  String? _selectedEventType;
  List<String> _provinces = [];
  List<String> _eventTypes = [];
  bool _isLoadingFilters = false;

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialSearchQuery;
    _searchController = TextEditingController(text: _searchQuery);
    _loadFavorites();
    _loadFilterData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // تحميل بيانات الفلترة
  Future<void> _loadFilterData() async {
    setState(() {
      _isLoadingFilters = true;
    });

    try {
      final provinces = await widget._viewModel.getProvinces();
      final eventTypes = await widget._viewModel.getEventTypes();
      
      setState(() {
        _provinces = provinces;
        _eventTypes = eventTypes;
      });
    } catch (e) {
      print('خطأ في تحميل بيانات الفلترة: $e');
    } finally {
      setState(() {
        _isLoadingFilters = false;
      });
    }
  }

  // تحميل قائمة المفضلات من SharedPreferences
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteProviders = prefs.getStringList('favorites')?.toSet() ?? {};
    });
  }

  // تحديث المفضلة في SharedPreferences
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

  // عرض نافذة الفلترة
  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: AppColors.backgroundColor(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // مؤشر النافذة
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderColor(context),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // عنوان النافذة
                Text(
                  'تصفية النتائج',
                  style: AppTextStyles.heading(context).copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 30),

                // فلتر المحافظة
                _buildDropdownFilter(
                  title: 'المحافظة',
                  value: _selectedProvince,
                  items: _provinces,
                  hint: 'اختر المحافظة',
                  allItemsText: 'جميع المحافظات',
                  onChanged: (value) {
                    setModalState(() {
                      _selectedProvince = value;
                    });
                  },
                ),

                const SizedBox(height: 20),

                // فلتر نوع الحفل
                _buildDropdownFilter(
                  title: 'نوع الحفل',
                  value: _selectedEventType,
                  items: _eventTypes,
                  hint: 'اختر نوع الحفل',
                  allItemsText: 'جميع أنواع الحفلات',
                  onChanged: (value) {
                    setModalState(() {
                      _selectedEventType = value;
                    });
                  },
                ),

                const SizedBox(height: 40),

                // أزرار التحكم
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setModalState(() {
                            _selectedProvince = null;
                            _selectedEventType = null;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'إعادة تعيين',
                          style: AppTextStyles.medium(context).copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            // تطبيق الفلترة
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'تطبيق',
                          style: AppTextStyles.medium(context).copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // بناء عنصر الفلترة المنسدل
  Widget _buildDropdownFilter({
    required String title,
    required String? value,
    required List<String> items,
    required String hint,
    required String allItemsText,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.large(context).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderColor(context)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(
                hint,
                style: AppTextStyles.medium(context),
              ),
              isExpanded: true,
              dropdownColor: AppColors.backgroundColor(context),
              items: [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text(
                    allItemsText,
                    style: AppTextStyles.medium(context),
                  ),
                ),
                ...items.map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: AppTextStyles.medium(context),
                  ),
                )),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // تطبيق الفلترة على النتائج
  List<QueryDocumentSnapshot> _applyFilters(List<QueryDocumentSnapshot> providers) {
    return providers.where((doc) {
      final provider = doc.data() as Map<String, dynamic>;
      
      // فلترة البحث النصي
      if (_searchQuery.isNotEmpty) {
        final companyName = provider['companyName'] as String? ?? '';
        final region = provider['region'] as String? ?? '';
        final province = provider['province'] as String? ?? '';
        
        final searchMatch = companyName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           region.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           province.toLowerCase().contains(_searchQuery.toLowerCase());
        
        if (!searchMatch) return false;
      }

      // فلترة المحافظة
      if (_selectedProvince != null) {
        final providerProvince = provider['province'] as String? ?? '';
        if (providerProvince != _selectedProvince) return false;
      }

      // فلترة نوع الحفل
      if (_selectedEventType != null) {
        final eventTypes = provider['eventTypes'] as List<dynamic>? ?? [];
        if (!eventTypes.contains(_selectedEventType)) return false;
      }

      return true;
    }).toList();
  }

  // بناء مؤشرات الفلترة النشطة
  Widget _buildActiveFilters() {
    if (_selectedProvince == null && _selectedEventType == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Wrap(
        spacing: 8,
        children: [
          if (_selectedProvince != null)
            Chip(
              label: Text(
                _selectedProvince!,
                style: AppTextStyles.small(context),
              ),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                setState(() {
                  _selectedProvince = null;
                });
              },
            ),
          if (_selectedEventType != null)
            Chip(
              label: Text(
                _selectedEventType!,
                style: AppTextStyles.small(context),
              ),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                setState(() {
                  _selectedEventType = null;
                });
              },
            ),
        ],
      ),
    );
  }

  // بناء رسالة عدم وجود نتائج
  Widget _buildNoResultsMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد نتائج مطابقة للبحث',
            style: AppTextStyles.large(context).copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'جرب تعديل معايير البحث أو الفلترة',
            style: AppTextStyles.medium(context).copyWith(
              color: AppColors.textColor(context).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: CustomAppBar(title: 'مقدمي خدمة ${widget.serviceName}'),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // شريط البحث مع زر الفلترة
              Row(
                children: [
                  Expanded(
                    child: SearchBarWidget(
                      hintText: 'ابحث عن مقدم الخدمة...',
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: _showFilterDialog,
                      icon: const Icon(
                        Icons.filter_list,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              
              // مؤشرات الفلترة النشطة
              _buildActiveFilters(),

              const SizedBox(height: 20),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: widget._viewModel.getServiceProviders(widget.serviceName),
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
                          'لا يوجد مقدمي خدمات لهذه الخدمة',
                          style: AppTextStyles.large(context).copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }

                    final allProviders = snapshot.data!.docs;
                    final filteredProviders = _applyFilters(allProviders);
                    
                    if (filteredProviders.isEmpty) {
                      return _buildNoResultsMessage();
                    }

                    return ListView.builder(
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
                            child: ServiceProvidersCard(
                              companyName: provider['companyName'],
                              location: '${provider['region']}, ${provider['province']}',
                              phone: provider['phone'],
                              companyLogo: provider['companyLogo'] ?? "",
                              // rating: provider['ratings']?.toDouble() ?? 0.0,
                              // reviewsCount: provider['reviewsCount'] ?? 0,
                              finalPrice: provider['finalPrice'] ?? 0.0,
                              priceFrom: provider['priceFrom'],
                              priceTo: provider['priceTo'],
                              discount: provider['discount'],
                              isFavorite: isFavorite,
                              onFavoriteToggle: () => _toggleFavorite(providerId),
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