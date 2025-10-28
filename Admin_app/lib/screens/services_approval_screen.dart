import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Admin_app/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/admin_provider.dart';

class ServicesApprovalScreen extends StatefulWidget {
  const ServicesApprovalScreen({super.key});

  @override
  State<ServicesApprovalScreen> createState() => _ServicesApprovalScreenState();
}

class _ServicesApprovalScreenState extends State<ServicesApprovalScreen> {
  final Map<String, bool> _expandedCards = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openPdf(BuildContext context, String? pdfUrl) async {
    if (pdfUrl == null || pdfUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'لا يوجد سجل تجاري متاح لهذه الخدمة',
            style: GoogleFonts.elMessiri(),
          ),
        ),
      );
      return;
    }

    try {
      if (await canLaunch(pdfUrl)) {
        await launch(pdfUrl);
      } else {
        throw 'تعذر فتح الرابط';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ أثناء محاولة فتح الملف: $e',
            style: GoogleFonts.elMessiri(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.secondary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: kBgColor,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            'مراجعة الخدمات',
            style: GoogleFonts.elMessiri().copyWith(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              SizedBox(height: 16),
              // Search and filter bar
              _buildSearchFilterBar(kBgColor),
              SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('service_providers')
                      .where('hasOffer', isEqualTo: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoadingIndicator(kBgColor);
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return _buildEmptyState(kBgColor);
                    }

                    // تطبيق البحث على البيانات
                    final filteredServices = snapshot.data!.docs.where((doc) {
                      if (_searchQuery.isEmpty) return true;

                      final data = doc.data() as Map<String, dynamic>;
                      final companyName =
                          data['companyName']?.toString().toLowerCase() ?? '';
                      final serviceType =
                          data['serviceType']?.toString().toLowerCase() ?? '';
                      final details =
                          data['details']?.toString().toLowerCase() ?? '';

                      return companyName.contains(_searchQuery) ||
                          serviceType.contains(_searchQuery) ||
                          details.contains(_searchQuery);
                    }).toList();

                    if (filteredServices.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'لا توجد نتائج مطابقة للبحث',
                              style: GoogleFonts.tajawal(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'حاول استخدام كلمات بحث مختلفة',
                              style: GoogleFonts.tajawal(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.only(bottom: 20),
                      itemCount: filteredServices.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        var service = filteredServices[index];
                        var data = service.data() as Map<String, dynamic>;
                        String serviceId = service.id;
                        bool isExpanded = _expandedCards[serviceId] ?? false;

                        return _buildServiceCard(
                          context: context,
                          data: data,
                          serviceId: serviceId,
                          isExpanded: isExpanded,
                          accentColor: accentColor,
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

  Widget _buildSearchFilterBar(Color kBgColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث عن خدمة...',
                hintStyle: GoogleFonts.elMessiri(),
                border: InputBorder.none,
                suffixIcon: _searchQuery.isEmpty
                    ? Icon(Icons.search, color: kBgColor)
                    : IconButton(
                        icon: Icon(Icons.close, color: kBgColor),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: kBgColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(Icons.filter_list, color: kBgColor),
              onPressed: () {
                // TODO: Implement filter functionality
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required BuildContext context,
    required Map<String, dynamic> data,
    required String serviceId,
    required bool isExpanded,
    required Color accentColor,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        initiallyExpanded: isExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            _expandedCards[serviceId] = expanded;
          });
        },
        tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: kBgColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getServiceIcon(data['serviceType']),
            color: kBgColor,
            size: 30,
          ),
        ),
        title: Text(
          data['companyName'] ?? 'اسم غير معروف',
          style: GoogleFonts.elMessiri(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          data['serviceType'] ?? 'خدمة غير محددة',
          style: GoogleFonts.elMessiri(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: Icon(
          isExpanded ? Icons.expand_less : Icons.expand_more,
          color: kBgColor,
        ),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(height: 1, color: Colors.grey[200]),
                SizedBox(height: 12),
                // Service description
                Text(
                  'وصف الخدمة',
                  style: GoogleFonts.elMessiri(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  data['details'] ?? 'لا يوجد وصف متاح',
                  style: GoogleFonts.tajawal(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 16),

                // Service details
                _buildDetailItem(Icons.location_on, "العنوان",
                    data['locationAddress'], kBgColor),
                _buildDetailItem(Icons.map, "المنطقة",
                    "${data['province']} - ${data['region']}", kBgColor),
                _buildDetailItem(
                    Icons.phone, "رقم الهاتف", data['phone'], kBgColor),
                _buildDetailItem(
                    Icons.event,
                    "أنواع الفعاليات",
                    (data['eventTypes'] as List<dynamic>?)?.join("، ") ??
                        'غير متوفر',
                    kBgColor),

                // السجل التجاري
                SizedBox(height: 16),
                _buildDetailItem(
                  Icons.description,
                  "السجل التجاري",
                  data['businessLicenseUrl'] != null
                      ? "اضغط لعرض السجل التجاري"
                      : "غير متوفر",
                  kBgColor,
                  onTap: () => _openPdf(context, data['businessLicenseUrl']),
                ),
                SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        context: context,
                        color: kBgColor,
                        icon: Icons.check,
                        text: "قبول",
                        onPressed: () {
                          Provider.of<AdminProvider>(context, listen: false)
                              .approveService(serviceId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'تم قبول الخدمة بنجاح',
                                style: GoogleFonts.elMessiri(),
                              ),
                              backgroundColor: kBgColor,
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        context: context,
                        color: Colors.red[400]!,
                        icon: Icons.close,
                        text: "رفض",
                        onPressed: () {
                          Provider.of<AdminProvider>(context, listen: false)
                              .rejectService(serviceId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'تم رفض الخدمة بنجاح',
                                style: GoogleFonts.elMessiri(),
                              ),
                              backgroundColor: Colors.red[400],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    IconData icon,
    String label,
    String? value,
    Color iconColor, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.tajawal(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    value ?? 'غير متوفر',
                    style: GoogleFonts.tajawal(
                      fontSize: 14,
                      color: onTap != null && value != 'غير متوفر'
                          ? Colors.blue
                          : Colors.grey[700],
                      decoration: onTap != null && value != 'غير متوفر'
                          ? TextDecoration.underline
                          : TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required Color color,
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.tajawal(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
          SizedBox(height: 16),
          Text(
            'جاري تحميل البيانات...',
            style: GoogleFonts.tajawal(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_turned_in,
            size: 80,
            color: primaryColor.withOpacity(0.3),
          ),
          SizedBox(height: 20),
          Text(
            'لا توجد خدمات تحتاج مراجعة',
            style: GoogleFonts.tajawal(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'جميع الخدمات الحالية تمت مراجعتها',
            style: GoogleFonts.tajawal(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getServiceIcon(String? serviceType) {
    switch (serviceType) {
      case 'تجهيزات':
        return Icons.event_seat;
      case 'تصوير':
        return Icons.camera_alt;
      case 'أطعمة':
        return Icons.restaurant;
      case 'ديكور':
        return Icons.brush;
      default:
        return Icons.help_outline;
    }
  }
}
