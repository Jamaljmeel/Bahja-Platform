import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../../utils/constants.dart';
import '../models/guests_model.dart';


class GuestsWidget {
  static Widget buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    BuildContext context, [
    TextInputType? keyboardType,
  ]) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: AppColors.primary),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: AppColors.primary),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          labelStyle: AppTextStyles.small(context),
          filled: true,
          fillColor: AppColors.surfaceColor,
        ),
        style: AppTextStyles.medium(context),
        keyboardType: keyboardType,
      ),
    );
  }

  static Widget buildHeaderCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required BuildContext context,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1),
              AppColors.surfaceColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 60, color: color),
            SizedBox(height: 10),
            Text(title, style: AppTextStyles.extraLarge(context)?.copyWith(color: color,fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text(subtitle, style: AppTextStyles.medium(context)?.copyWith(color: AppColors.grey)),
          ],
        ),
      ),
    );
  }

  static Widget buildEventCard(EventModel event, VoidCallback onTap, BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.event, color: AppColors.primary, size: 24),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(event.eventName, style: AppTextStyles.large(context)?.copyWith(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text(event.eventType, style: AppTextStyles.small(context)?.copyWith(color: AppColors.grey)),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: AppColors.grey.withOpacity(0.5), size: 16),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: AppColors.grey),
                  SizedBox(width: 4),
                  Text(event.eventDate, style: AppTextStyles.small(context)?.copyWith(color: AppColors.grey)),
                  SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: AppColors.grey),
                  SizedBox(width: 4),
                  Text(event.eventTime, style: AppTextStyles.small(context)?.copyWith(color: AppColors.grey)),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: AppColors.grey),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      event.location,
                      style: AppTextStyles.small(context)?.copyWith(color: AppColors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget buildInviteeCard(InviteeModel invitee, BuildContext context, {bool showStatus = true}) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: invitee.isCheckedIn 
              ? AppColors.secondary.withOpacity(0.1)
              : AppColors.accentColor.withOpacity(0.1),
          child: Icon(
            invitee.isCheckedIn ? Icons.check : Icons.person,
            color: invitee.isCheckedIn ? AppColors.secondary : AppColors.accentColor,
          ),
        ),
        title: Text(invitee.name, style: AppTextStyles.medium(context)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${invitee.phoneNumber} • ${invitee.numberOfPeople} أشخاص',
              style: AppTextStyles.small(context)?.copyWith(color: AppColors.grey),
            ),
            if (invitee.sentAt != null)
              Text(
                'تم الإرسال: ${_formatDateTime(invitee.sentAt!)}',
                style: AppTextStyles.small(context)?.copyWith(color: AppColors.grey, fontSize: 12),
              ),
            if (invitee.respondedAt != null && invitee.isCheckedIn)
              Text(
                'وقت الحضور: ${_formatDateTime(invitee.respondedAt!)}',
                style: AppTextStyles.small(context)?.copyWith(color: AppColors.grey, fontSize: 12),
              ),
          ],
        ),
        trailing: showStatus ? Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: invitee.isCheckedIn 
                ? AppColors.secondary.withOpacity(0.1)
                : AppColors.accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            invitee.isCheckedIn ? 'حضر' : 'انتظار',
            style: AppTextStyles.small(context)?.copyWith(
              color: invitee.isCheckedIn ? AppColors.secondary : AppColors.accentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ) : null,
      ),
    );
  }

  static Widget buildEmptyState({
    required IconData icon,
    required String title,
    String? subtitle,
    required BuildContext context,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: AppColors.grey.withOpacity(0.5)),
          SizedBox(height: 16),
          Text(title, style: AppTextStyles.large(context)?.copyWith(color: AppColors.grey,fontWeight: FontWeight.bold)),
          if (subtitle != null) ...[
            SizedBox(height: 8),
            Text(subtitle, style: AppTextStyles.medium(context)?.copyWith(color: AppColors.grey)),
          ],
        ],
      ),
    );
  }

  static Widget buildAttendanceStats(int totalInvitees, int totalPeople, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.people, color: AppColors.secondary),
          SizedBox(width: 8),
          Text(
            'إجمالي الحضور: $totalInvitees مدعو',
            style: AppTextStyles.medium(context)?.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          Text(
            'الأشخاص: $totalPeople',
            style: AppTextStyles.medium(context)?.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> showContactsDialog({
    required BuildContext context,
    required List<Contact> contacts,
    required Function(String name, String phone) onContactSelected,
  }) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('اختر جهة اتصال', style: AppTextStyles.title(context)),
        backgroundColor: AppColors.surfaceColor,
        content: Container(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              final phoneNumber = contact.phones.isNotEmpty ? contact.phones.first.number : '';
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Icon(Icons.person, color: AppColors.primary),
                ),
                title: Text(contact.displayName, style: AppTextStyles.medium(context)),
                subtitle: phoneNumber.isNotEmpty 
                  ? Text(phoneNumber, style: AppTextStyles.small(context)?.copyWith(color: AppColors.grey))
                  : null,
                onTap: () {
                  if (phoneNumber.isNotEmpty) {
                    onContactSelected(contact.displayName, phoneNumber);
                    Navigator.pop(context);
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            child: Text('إغلاق', style: AppTextStyles.medium(context)?.copyWith(color: AppColors.grey)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  static Future<void> showPermissionDialog({
    required BuildContext context,
    required VoidCallback onSettings,
  }) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('إذن مطلوب', style: AppTextStyles.title(context)),
        content: Text(
          'تم رفض إذن الوصول إلى جهات الاتصال بشكل دائم. يرجى الذهاب إلى الإعدادات وتفعيل الإذن يدوياً.',
          style: AppTextStyles.medium(context),
        ),
        backgroundColor: AppColors.surfaceColor,
        actions: [
          TextButton(
            child: Text('إلغاء', style: AppTextStyles.medium(context)?.copyWith(color: AppColors.grey)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text('الإعدادات', style: AppTextStyles.medium(context)?.copyWith(color: AppColors.surfaceColor)),
            onPressed: () {
              Navigator.of(context).pop();
              onSettings();
            },
          ),
        ],
      ),
    );
  }

  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}