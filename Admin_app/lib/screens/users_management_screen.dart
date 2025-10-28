import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Admin_app/constants.dart';
import 'package:Admin_app/providers/admin_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/user_row.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Color(0xFFF8FAFD),
        appBar: AppBar(
          backgroundColor: kBgColor,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            'إدارة المستخدمين',
            style: GoogleFonts.elMessiri(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: _isLoading
                  ? _buildLoadingIndicator()
                  : _errorMessage != null
                      ? _buildErrorState()
                      : StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return _buildErrorState(
                                  message: 'حدث خطأ في جلب البيانات');
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return _buildLoadingIndicator();
                            }

                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return _buildEmptyState();
                            }

                            try {
                              final users =
                                  snapshot.data!.docs.where((userDoc) {
                                if (_searchQuery.isEmpty) return true;

                                final userData =
                                    userDoc.data() as Map<String, dynamic>? ??
                                        {};
                                final email = userData['email']
                                        ?.toString()
                                        .toLowerCase() ??
                                    '';
                                final typeUser = userData['typeUser']
                                        ?.toString()
                                        .toLowerCase() ??
                                    '';

                                return email.contains(_searchQuery) ||
                                    typeUser.contains(_searchQuery);
                              }).toList();

                              if (users.isEmpty) {
                                return _buildNoResults();
                              }

                              return ListView.separated(
                                padding: EdgeInsets.all(16),
                                physics: BouncingScrollPhysics(),
                                itemCount: users.length,
                                separatorBuilder: (context, index) =>
                                    SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final userDoc = users[index];
                                  final userData =
                                      userDoc.data() as Map<String, dynamic>? ??
                                          {};

                                  return UserCard(
                                    userId: userDoc.id,
                                    email: userData['email']?.toString() ??
                                        'بريد غير معروف',
                                    typeUser:
                                        userData['typeUser']?.toString() ??
                                            'نوع غير معروف',
                                    isSuspended:
                                        userData['isSuspended'] as bool? ??
                                            false,
                                  );
                                },
                              );
                            } catch (e) {
                              return _buildErrorState(
                                  message: 'حدث خطأ في معالجة البيانات');
                            }
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'ابحث عن مستخدم...',
            hintStyle: GoogleFonts.elMessiri(),
            prefixIcon: Icon(Icons.search, color: kBgColor),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
          onChanged: (value) =>
              setState(() => _searchQuery = value.toLowerCase()),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(kBgColor),
          ),
          SizedBox(height: 16),
          Text(
            'جاري تحميل بيانات المستخدمين...',
            style: GoogleFonts.elMessiri(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState({String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 50, color: Colors.red),
          SizedBox(height: 16),
          Text(
            message ?? _errorMessage ?? 'حدث خطأ غير متوقع',
            style: GoogleFonts.elMessiri(
              fontSize: 16,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() {
              _errorMessage = null;
              _isLoading = false;
            }),
            child: Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Text(
            'لا يوجد مستخدمين مسجلين حالياً',
            style: GoogleFonts.elMessiri(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
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
            style: GoogleFonts.elMessiri(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'حاول استخدام كلمات بحث مختلفة',
            style: GoogleFonts.elMessiri(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final String userId;
  final String email;
  final String typeUser;
  final bool isSuspended;

  const UserCard({
    required this.userId,
    required this.email,
    required this.typeUser,
    required this.isSuspended,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: kBgColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    typeUser == 'admin'
                        ? Icons.admin_panel_settings
                        : Icons.person,
                    color: kBgColor,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        email,
                        style: GoogleFonts.elMessiri(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'نوع المستخدم: $typeUser',
                        style: GoogleFonts.elMessiri(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSuspended)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'موقف',
                      style: GoogleFonts.elMessiri(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.block, size: 18),
                    label: Text(
                      isSuspended ? 'إلغاء التوقيف' : 'توقيف',
                      style: GoogleFonts.elMessiri(),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isSuspended ? Colors.green : kBgColor,
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: isSuspended ? Colors.green : kBgColor,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      try {
                        final userDoc = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .get();

                        if (!userDoc.exists) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('المستخدم غير موجود'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        final userData =
                            userDoc.data() as Map<String, dynamic>? ?? {};
                        final String? token = userData['fcmToken'];
                        final bool newStatus = !isSuspended;

                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .update({'isSuspended': newStatus});

                        if (token != null && token.isNotEmpty) {
                          final title = 'تنبيه من الإدارة';
                          final body = newStatus
                              ? 'تم توقيف حسابك مؤقتًا من قبل الإدارة.'
                              : 'تم تفعيل حسابك من جديد.';

                          await sendPushNotification(
                            token: token,
                            title: title,
                            body: body,
                          );

                          await FirebaseFirestore.instance
                              .collection('notifications')
                              .add({
                            'userId': userId,
                            'title': title,
                            'body': body,
                            'timestamp': FieldValue.serverTimestamp(),
                            'isRead': false,
                          });
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('حدث خطأ أثناء التعديل'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.delete, size: 18),
                    label: Text(
                      'حذف',
                      style: GoogleFonts.elMessiri(),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      try {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text('تأكيد الحذف',
                                textAlign: TextAlign.right,
                                style: GoogleFonts.elMessiri().copyWith()),
                            content: Text('هل أنت متأكد من حذف هذا المستخدم؟',
                                textAlign: TextAlign.right,
                                style: GoogleFonts.elMessiri().copyWith()),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: Text('إلغاء',
                                    style: GoogleFonts.elMessiri().copyWith()),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: Text('حذف',
                                    style: GoogleFonts.elMessiri()
                                        .copyWith(color: Colors.red)),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          final userDoc = await FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .get();

                          if (!userDoc.exists) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('المستخدم غير موجود'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          final userData =
                              userDoc.data() as Map<String, dynamic>? ?? {};
                          final String? token = userData['fcmToken'];

                          const title = 'تنبيه من الإدارة';
                          const body = 'تم حذف حسابك من قبل الإدارة.';

                          if (token != null && token.isNotEmpty) {
                            await sendPushNotification(
                              token: token,
                              title: title,
                              body: body,
                            );

                            await FirebaseFirestore.instance
                                .collection('notifications')
                                .add({
                              'userId': userId,
                              'title': title,
                              'body': body,
                              'timestamp': FieldValue.serverTimestamp(),
                              'isRead': false,
                            });
                          }

                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .delete();
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('حدث خطأ أثناء الحذف'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
