import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_app_bar.dart';

class NotificationsPage extends StatelessWidget {
  final String currentUserId;

  const NotificationsPage({Key? key, required this.currentUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: CustomAppBar(title: 'الاشعارات '),
      body: Container(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        child: Column(
          children: [

            Expanded(
              child: _buildNotificationsList(isDark),
            ),
          ],
        ),
      ),
    );
  }
  //
  // Widget _buildHeader(bool isDark) {
  //   return Container(
  //     padding: const EdgeInsets.all(16.0),
  //     decoration: BoxDecoration(
  //       color: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
  //       border: Border(
  //         bottom: BorderSide(
  //           color: isDark ? AppColors.borderDark : AppColors.borderLight,
  //           width: 1,
  //         ),
  //       ),
  //     ),
  //     child: Row(
  //       children: [
  //         Container(
  //           padding: EdgeInsets.all(8),
  //           decoration: BoxDecoration(
  //             color: isDark ? AppColors.primaryDark.withOpacity(0.1) : AppColors.primaryLight.withOpacity(0.1),
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //           child: Icon(
  //             Icons.notifications_active,
  //             color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
  //             size: 24,
  //           ),
  //         ),
  //         const SizedBox(width: 12),
  //         Text(
  //           'إشعاراتك',
  //           style: GoogleFonts.elMessiri(
  //             fontSize: 18,
  //             fontWeight: FontWeight.bold,
  //             color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // دالة لفلترة الإشعارات
  bool _shouldShowNotification(Map<String, dynamic> data) {
    final userId = data['userId'] as String?;
    final targetGroups = data['targetGroups'] as List<dynamic>?;
    
    // إشعارات خاصة بالمستخدم الحالي
    if (userId != null && userId.isNotEmpty && userId == currentUserId) {
      return true;
    }
    
    // إشعارات عامة (userId فارغ أو null)
    if ((userId == null || userId.isEmpty) && targetGroups != null) {
      final targetGroupsList = targetGroups.cast<String>();
      return targetGroupsList.contains('providers') || targetGroupsList.contains('all');
    }
    
    return false;
  }

  Widget _buildNotificationsList(bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator(isDark);
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString(), isDark);
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyNotifications(isDark);
        }

        // فلترة الإشعارات محلياً
        final allDocs = snapshot.data!.docs;
        final filteredDocs = allDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return _shouldShowNotification(data);
        }).toList();

        if (filteredDocs.isEmpty) {
          return _buildEmptyNotifications(isDark);
        }

        return RefreshIndicator(
          color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
          backgroundColor: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
          onRefresh: () async {
            // إعادة تحديث البيانات
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filteredDocs.length,
            separatorBuilder: (context, index) => SizedBox(height: 8),
            itemBuilder: (context, index) {
              final doc = filteredDocs[index];
              final data = doc.data() as Map<String, dynamic>;
              final docId = doc.id;
              return _buildNotificationItem(data, docId, isDark);
            },
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> data, String docId, bool isDark) {
    final timestamp = data['timestamp'] as Timestamp?;
    final dateTime = timestamp?.toDate();
    final timeAgo = dateTime != null 
        ? DateFormat('yyyy/MM/dd - hh:mm a').format(dateTime)
        : '';
    final isRead = data['isRead'] ?? false;
    final isImportant = data['isImportant'] ?? false;
    final userId = data['userId'] as String?;
    final targetGroups = data['targetGroups'] as List<dynamic>?;
    
    // تحديد نوع الإشعار
    String notificationType = '';
    if (userId != null && userId.isNotEmpty) {
      notificationType = 'خاص';
    } else if (targetGroups != null) {
      final groups = targetGroups.cast<String>();
      if (groups.contains('all')) {
        notificationType = 'عام للجميع';
      } else if (groups.contains('providers')) {
        notificationType = 'عام لمقدمي الخدمات';
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead 
              ? (isDark ? AppColors.borderDark : AppColors.borderLight)
              : (isDark ? AppColors.primaryDark : AppColors.primaryLight),
          width: isRead ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isImportant 
                    ? Colors.red.withOpacity(0.1)
                    : (isDark ? AppColors.primaryDark.withOpacity(0.1) : AppColors.primaryLight.withOpacity(0.1)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isImportant ? Icons.priority_high : 
                (userId != null && userId.isNotEmpty) ? Icons.person : Icons.public,
                color: isImportant 
                    ? Colors.red.shade600
                    : (isDark ? AppColors.primaryDark : AppColors.primaryLight),
                size: 20,
              ),
            ),
            if (!isRead)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          data['title'] ?? 'بدون عنوان',
          style: GoogleFonts.elMessiri(
            fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
            fontSize: 16,
            color: isImportant 
                ? Colors.red.shade700
                : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              data['body'] ?? 'لا يوجد محتوى',
              style: GoogleFonts.elMessiri(
                color: isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            if (notificationType.isNotEmpty) ...[
              const SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.primaryDark : AppColors.primaryLight).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  notificationType,
                  style: GoogleFonts.elMessiri(
                    color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              timeAgo,
              style: GoogleFonts.elMessiri(
                color: isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: !isRead
            ? Icon(
                Icons.circle,
                color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                size: 8,
              )
            : null,
        onTap: () => _markAsRead(docId),
      ),
    );
  }

  Widget _buildLoadingIndicator(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'جاري تحميل الإشعارات...',
            style: GoogleFonts.elMessiri(
              color: isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error, bool isDark) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(24),
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.shade400,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ في تحميل الإشعارات',
              style: GoogleFonts.elMessiri(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.elMessiri(
                color: isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                // إعادة تحميل الصفحة
              },
              child: Text(
                'حاول مرة أخرى',
                style: GoogleFonts.elMessiri(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyNotifications(bool isDark) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(24),
        padding: EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.primaryDark.withOpacity(0.1) : AppColors.primaryLight.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_off_outlined,
                size: 64,
                color: isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد إشعارات جديدة',
              style: GoogleFonts.elMessiri(
                fontSize: 18,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'سيظهر هنا أي إشعارات جديدة تتلقاها',
              style: GoogleFonts.elMessiri(
                color: isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // دوال للتعامل مع قراءة الإشعارات
  void _markAsRead(String docId) {
    FirebaseFirestore.instance
        .collection('notifications')
        .doc(docId)
        .update({'isRead': true});
  }
}