import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:Admin_app/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:iconsax/iconsax.dart';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class MessagesScreen extends StatefulWidget {
  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class _MessagesScreenState extends State<MessagesScreen> {
  final CollectionReference _messagesRef =
      FirebaseFirestore.instance.collection('ContactUs');

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: kBgColor,
          title: Text(
            'رسائل العملاء',
            style: GoogleFonts.elMessiri(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream:
              _messagesRef.orderBy('timestamp', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'حدث خطأ في تحميل البيانات',
                  style: GoogleFonts.elMessiri(),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 60, color: Colors.grey[400]),
                    SizedBox(height: 16),
                    Text(
                      'لا توجد رسائل حالياً',
                      style: GoogleFonts.elMessiri(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 16),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var message = snapshot.data!.docs[index];
                final Timestamp timestamp = message['timestamp'];
                final DateTime dateTime = timestamp.toDate();

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: MessageCard(
                    messageKey: message.id,
                    phone: message['phone'] ?? '',
                    type: message['category'] ?? '',
                    content: message['message'] ?? '',
                    fcmToken: message['fcmToken'] ?? '',
                    timestamp: dateTime,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class MessageCard extends StatefulWidget {
  final String messageKey;
  final String phone;
  final String type;
  final String content;
  final String fcmToken;
  final DateTime timestamp;
  final List<Map<String, dynamic>>? responses;

  const MessageCard({
    required this.messageKey,
    required this.phone,
    required this.type,
    required this.content,
    required this.fcmToken,
    required this.timestamp,
    this.responses,
  });

  @override
  _MessageCardState createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  final TextEditingController _responseController = TextEditingController();
  bool _isExpanded = false;
  List<Map<String, dynamic>> _responses = [];

  @override
  void initState() {
    super.initState();
    _loadResponses();
  }

  Future<void> _loadResponses() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('ContactUs')
        .doc(widget.messageKey)
        .collection('responses')
        .orderBy('timestamp', descending: false)
        .get();

    setState(() {
      _responses = snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    label: Text(
                      widget.type,
                      style: GoogleFonts.elMessiri(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: _getCategoryColor(widget.type),
                    shape: StadiumBorder(),
                  ),
                  Expanded(
                    child: Text(
                      widget.phone,
                      style: GoogleFonts.elMessiri(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kDarkColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('yyyy/MM/dd - hh:mm a').format(widget.timestamp),
                    style: GoogleFonts.elMessiri(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Iconsax.calendar, size: 16, color: Colors.grey),
                ],
              ),
              SizedBox(height: 12),
              Text(
                widget.content,
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  height: 1.5,
                ),
                maxLines: _isExpanded ? null : 3,
                overflow: _isExpanded ? null : TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 8),
              if (_isExpanded) ...[
                Divider(height: 24),
                if (_responses.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الردود:',
                        style: GoogleFonts.elMessiri(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      SizedBox(height: 8),
                      ..._responses
                          .map((response) => _buildResponseItem(response)),
                    ],
                  ),
                SizedBox(height: 16),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Iconsax.send1, color: kBgColor),
                      onPressed: _sendResponse,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _responseController,
                        decoration: InputDecoration(
                          hintText: 'اكتب ردك هنا...',
                          hintStyle: GoogleFonts.elMessiri(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: kBgColor),
                          ),
                        ),
                        maxLines: 3,
                        minLines: 1,
                        style: GoogleFonts.elMessiri(),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    icon: Icon(Iconsax.trash, color: Colors.red),
                    label: Text(
                      'حذف الرسالة',
                      style: GoogleFonts.elMessiri(color: Colors.red),
                    ),
                    onPressed: _deleteMessage,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
              ],
              if (!_isExpanded)
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'اضغط لعرض التفاصيل',
                    style: GoogleFonts.elMessiri(
                      color: kBgColor,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResponseItem(Map<String, dynamic> response) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            response['response'] ?? '',
            style: GoogleFonts.tajawal(
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.right,
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                DateFormat('yyyy/MM/dd - hh:mm a')
                    .format((response['timestamp'] as Timestamp).toDate()),
                style: GoogleFonts.tajawal(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
              SizedBox(width: 4),
              Icon(Iconsax.calendar, size: 14, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'شكوى':
        return kBgColor;
      case 'استفسار':
        return Colors.blue;
      case 'مقترح':
        return Colors.green;
      default:
        return kPrimaryColor;
    }
  }

//دالة الردود
  void _sendResponse() async {
    final responseText = _responseController.text.trim();
    if (responseText.isEmpty) return;

    final docRef = FirebaseFirestore.instance
        .collection('ContactUs')
        .doc(widget.messageKey);

    final messageSnapshot = await docRef.get();

    if (!messageSnapshot.exists) {
      print('الرسالة غير موجودة');
      return;
    }

    final messageData = messageSnapshot.data()!;
    final String userId = messageData['usersId'];

    // حفظ الرد في Subcollection
    await docRef.collection('responses').add({
      'response': responseText,
      'timestamp': FieldValue.serverTimestamp(),
      'sender': 'admin',
    });

    // إرسال الإشعار إن وُجد FCM token
    if (widget.fcmToken.isNotEmpty) {
      await sendPushNotification(
        token: widget.fcmToken,
        title: "رد على رسالتك",
        body: responseText,
      );
    }

    // حفظ الإشعار في Firestore
    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': userId,
      'title': 'رد على رسالتك',
      'body': responseText,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    _responseController.clear();
    await _loadResponses();
  }

  void _deleteMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          textAlign: TextAlign.right,
          'تأكيد الحذف',
          style: GoogleFonts.elMessiri(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          textAlign: TextAlign.right,
          'هل أنت متأكد من حذف هذه الرسالة؟',
          style: GoogleFonts.elMessiri(),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        actions: [
          TextButton(
            child: Text(
              'إلغاء',
              style: GoogleFonts.elMessiri(),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(
              'حذف',
              style: GoogleFonts.elMessiri(color: Colors.red),
            ),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('ContactUs')
                  .doc(widget.messageKey)
                  .delete();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

//دالة لارسال اشعار بالردود
/*Future<void> sendReplyToMessage({
  required String messageId,
  required String replyText,
}) async {
  final messageDoc =
      await _firestore.collection('ContactUs').doc(messageId).get();

  if (!messageDoc.exists) return;

  // استخراج بيانات الرسالة الأصلية
  final messageData = messageDoc.data()!;
  final String userId = messageData['userId'];

  // حفظ الرد في Subcollection داخل الرسالة (اختياري)
  await _firestore
      .collection('ContactUs')
      .doc(messageId)
      .collection('responses')
      .add({
    'reply': replyText,
    'timestamp': FieldValue.serverTimestamp(),
    'sender': 'admin',
  });

  // جلب توكن المستخدم
  final userDoc = await _firestore.collection('users').doc(userId).get();
  final String? token = userDoc['fcmToken'];

  // إرسال الإشعار
  if (token != null && token.isNotEmpty) {
    await sendPushNotification(
      token: token,
      title: 'رد على رسالتك',
      body: replyText,
    );
  }

  // حفظ الإشعار في Firestore
  await _firestore.collection('notifications').add({
    'userId': userId,
    'title': 'رد على رسالتك',
    'body': replyText,
    'timestamp': FieldValue.serverTimestamp(),
    'isRead': false,
  });
}*/

// مسار ملف JSON لمفتاح حساب الخدمة
final String serviceAccountPath = 'assets/service-account.json';
//دالة لارسال الاشعار
Future<void> sendPushNotification({
  required String token,
  required String title,
  required String body,
}) async {
  final String jsonString = await rootBundle.loadString(serviceAccountPath);
  final Map<String, dynamic> serviceAccountJson = json.decode(jsonString);

  final accountCredentials =
      ServiceAccountCredentials.fromJson(serviceAccountJson);

  // النطاق الخاص بـ FCM
  final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  // المصادقة باستخدام حساب الخدمة
  final authClient = await clientViaServiceAccount(accountCredentials, scopes);

  final projectId = serviceAccountJson['project_id'];
  final url = 'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

  final message = {
    "message": {
      "token": token,
      "notification": {
        "title": title,
        "body": body,
      },
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "type": "reply",
      }
    }
  };

  final response = await authClient.post(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(message),
  );

  if (response.statusCode == 200) {
    print('Notification sent successfully.');
  } else {
    print('Failed to send notification: ${response.statusCode}');
    print(response.body);
  }

  authClient.close();
}
