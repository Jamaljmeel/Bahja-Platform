import 'package:gam/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/custom_app_bar.dart';
import '../theme/app_theme.dart';

class NotificationsPage extends StatelessWidget {
  final String currentUserId;

  const NotificationsPage({Key? key, required this.currentUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: CustomAppBar(title: 'الاشعارات '),
      body: Container(
        color: AppColors.backgroundColor(context),
        child: Column(
          children: [
            Expanded(
              child: _buildNotificationsList(),
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowNotification(Map<String, dynamic> data) {
    final userId = data['userId'] as String?;
    final targetGroups = data['targetGroups'] as List<dynamic>?;
    
    if (userId != null && userId.isNotEmpty && userId == currentUserId) {
      return true;
    }
    
    if ((userId == null || userId.isEmpty) && targetGroups != null) {
      final targetGroupsList = targetGroups.cast<String>();
      return targetGroupsList.contains('clients') || targetGroupsList.contains('all');
    }
    
    return false;
  }

  Widget _buildNotificationsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator(context);
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString(), context);
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyNotifications(context);
        }

        final allDocs = snapshot.data!.docs;
        final filteredDocs = allDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return _shouldShowNotification(data);
        }).toList();

        if (filteredDocs.isEmpty) {
          return _buildEmptyNotifications(context);
        }

        return RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.inputFillColor(context),
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
              return _buildNotificationItem(data, docId, context);
            },
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> data, String docId, BuildContext context) {
    final timestamp = data['timestamp'] as Timestamp?;
    final dateTime = timestamp?.toDate();
    final timeAgo = dateTime != null 
        ? DateFormat('yyyy/MM/dd - hh:mm a').format(dateTime)
        : '';
    final isRead = data['isRead'] ?? false;
    final isImportant = data['isImportant'] ?? false;
    final userId = data['userId'] as String?;
    final targetGroups = data['targetGroups'] as List<dynamic>?;
    
    String notificationType = '';
    if (userId != null && userId.isNotEmpty) {
      notificationType = 'خاص';
    } else if (targetGroups != null) {
      final groups = targetGroups.cast<String>();
      if (groups.contains('all')) {
        notificationType = 'عام للجميع';
      } else if (groups.contains('clients')) {
        notificationType = 'اشعار عام للمستخدمين';
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputFillColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead 
              ? AppColors.borderColor(context)
              : AppColors.primary,
          width: isRead ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                    : AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isImportant ? Icons.priority_high : 
                (userId != null && userId.isNotEmpty) ? Icons.person : Icons.public,
                color: isImportant 
                    ? Colors.red.shade600
                    : AppColors.primary,
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
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          data['title'] ?? 'بدون عنوان',
          style: AppTextStyles.large(context).copyWith(
            fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
            color: isImportant 
                ? Colors.red.shade700
                : AppColors.textColor(context),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              data['body'] ?? 'لا يوجد محتوى',
              style: AppTextStyles.medium(context).copyWith(
                height: 1.4,
              ),
            ),
            if (notificationType.isNotEmpty) ...[
              const SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  notificationType,
                  style: AppTextStyles.extraSmall(context).copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              timeAgo,
              style: AppTextStyles.small(context),
            ),
          ],
        ),
        trailing: !isRead
            ? Icon(
                Icons.circle,
                color: AppColors.primary,
                size: 8,
              )
            : null,
        onTap: () => _markAsRead(docId),
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'جاري تحميل الإشعارات...',
            style: AppTextStyles.large(context),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error, BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(24),
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.inputFillColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderColor(context),
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
              style: AppTextStyles.extraLarge(context).copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: AppTextStyles.medium(context),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
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
                style: AppTextStyles.medium(context).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyNotifications(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(24),
        padding: EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.inputFillColor(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_off_outlined,
                size: 64,
                color: AppColors.textColor(context),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد إشعارات جديدة',
              style: AppTextStyles.extraLarge(context).copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'سيظهر هنا أي إشعارات جديدة تتلقاها',
              style: AppTextStyles.medium(context),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _markAsRead(String docId) {
    FirebaseFirestore.instance
        .collection('notifications')
        .doc(docId)
        .update({'isRead': true});
  }
}