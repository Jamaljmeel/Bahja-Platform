import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:services_providers/services/edit_service_controller.dart';
import 'package:services_providers/services/service_provider.dart';
import '../models/service_model.dart';
import '../screens/EditServicePage.dart';
import '../utils/dialog_utils.dart';
import '../utils/app_colors.dart';

class ServiceItem extends StatelessWidget {
  final Service service;

  const ServiceItem({required this.service});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      color: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                   service.companyLogo ??"",
                    width: 250,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 10),
              ],
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                service.companyName,
                style: GoogleFonts.elMessiri(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
            ),
            _buildInfoRow(context, Icons.work, 'الخدمة', service.service),
            _buildInfoRow(context, Icons.location_on, 'المحافظة', service.province),
            _buildInfoRow(context, Icons.phone, 'الهاتف', service.phone),
            _buildInfoRow(context, Icons.attach_money, 'السعر من', '${service.priceFrom} إلى ${service.priceTo}'),
            if (service.finalPrice != null)
              _buildInfoRow(context, Icons.discount, 'السعر بعد الخصم', '${service.finalPrice}'),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.green),
                  tooltip: 'تعديل الخدمة',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditServicePage(service: service),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    bool confirmDelete = await showConfirmationDialog(
                      context,
                      'تأكيد الحذف',
                      'هل أنت متأكد من أنك تريد حذف هذه الخدمة؟',
                    );

                    if (confirmDelete) {
                      try {
                        await ServiceProvider().deleteService(service.id);
                        showMessageDialog(context, 'نجاح', 'تم حذف الخدمة بنجاح.');
                      } catch (e) {
                        showMessageDialog(context, 'خطأ', 'حدث خطأ أثناء حذف الخدمة: $e');
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            icon, 
            size: 18, 
            color: isDark ? AppColors.primaryDark : AppColors.primaryLight
          ),
          SizedBox(width: 8),
          Text(
            '$label: ',
            style: GoogleFonts.elMessiri(
              fontSize: 16, 
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.elMessiri(
                fontSize: 16,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}