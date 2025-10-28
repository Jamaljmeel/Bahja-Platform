import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Admin_app/constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _senderController = TextEditingController();
  final _messageController = TextEditingController();
  final Map<String, bool> _targetGroups = {
    'providers': true,
    'clients': true,
  };
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _setupFirebaseMessaging();
  }

  @override
  void dispose() {
    _senderController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _setupFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen((message) {
      print('Notification received: ${message.notification?.title}');
      print('Notification body: ${message.notification?.body}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: kBgColor,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            'إرسال إشعارات',
            style: GoogleFonts.elMessiri(
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
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // بطاقة إدخال البيانات
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            'إرسال إشعار جديد',
                            style: GoogleFonts.elMessiri(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: kBgColor,
                            ),
                          ),
                          SizedBox(height: 20),

                          // حقل عنوان الرسالة
                          TextFormField(
                            controller: _senderController,
                            decoration: InputDecoration(
                              labelText: 'عنوان الرسالة',
                              labelStyle: GoogleFonts.elMessiri(),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: kBgColor, width: 2),
                              ),
                              prefixIcon: Icon(Icons.title, color: kBgColor),
                            ),
                            style: GoogleFonts.elMessiri(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يجب إدخال عنوان الرسالة';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 15),

                          // حقل نص الرسالة
                          TextFormField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              labelText: 'نص الرسالة',
                              labelStyle: GoogleFonts.elMessiri(),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: kBgColor, width: 2),
                              ),
                              prefixIcon: Icon(Icons.message, color: kBgColor),
                            ),
                            style: GoogleFonts.elMessiri(),
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يجب إدخال نص الرسالة';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // بطاقة اختيار المجموعات المستهدفة
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'المجموعات المستهدفة',
                            style: GoogleFonts.elMessiri(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: kBgColor,
                            ),
                          ),
                          SizedBox(height: 10),
                          ..._targetGroups.keys.map(
                            (group) => CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                group == 'providers'
                                    ? 'مقدمو الخدمات'
                                    : 'العملاء',
                                style: GoogleFonts.elMessiri(),
                              ),
                              value: _targetGroups[group],
                              onChanged: (value) {
                                setState(() {
                                  _targetGroups[group] = value!;
                                });
                              },
                              activeColor: kBgColor,
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 30),

                  // زر الإرسال
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSending ? null : _sendNotifications,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBgColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: _isSending
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'إرسال الإشعار',
                              style: GoogleFonts.elMessiri(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendNotifications() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSending = true);
      FocusScope.of(context).unfocus();

      try {
        final List<String> topics = [];
        if (_targetGroups['providers'] == true) topics.add('providers');
        if (_targetGroups['clients'] == true) topics.add('clients');

        if (topics.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'الرجاء اختيار مجموعة واحدة على الأقل',
                style: GoogleFonts.elMessiri(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        for (final topic in topics) {
          await PushNotificationService.sendNotificationToTopic(
            topic: topic,
            title: _senderController.text,
            body: _messageController.text,
            data: null,
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم إرسال الإشعارات بنجاح',
              style: GoogleFonts.elMessiri(color: Colors.white),
            ),
            backgroundColor: kSecondaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        _senderController.clear();
        _messageController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء الإرسال: $e',
              style: GoogleFonts.elMessiri(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isSending = false);
      }
    }
  }
}

class PushNotificationService {
  static Future<String> getAccessToken() async {
    final serviceAcountJson = {

    };

    List<String> scopes = [

    ];

    http.Client client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAcountJson), scopes);

    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAcountJson),
      scopes,
      client,
    );

    client.close();
    return credentials.accessToken.data;
  }

  static Future<void> sendNotificationToTopic({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final String serverAccessTokenKey = await getAccessToken();
    String endPoint =
        'https://fcm.googleapis.com/v1/projects/gam-app-313a5/messages:send';

    final Map<String, dynamic> message = {
      'message': {
        'topic': topic,
        'notification': {'title': title, 'body': body},
        if (data != null) 'data': data,
      }
    };

    final response = await http.post(
      Uri.parse(endPoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverAccessTokenKey',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode != 200) {
      throw Exception('فشل إرسال الإشعار إلى $topic: ${response.statusCode}');
    }

    await FirebaseFirestore.instance.collection('notifications').add({
      'title': title,
      'body': body,
      'timestamp': FieldValue.serverTimestamp(),
      'targetGroups': [topic],
      'isRead': false,
    });
  }
}

getmessage() {
  FirebaseMessaging.onMessage.listen((message) {
    print(message.notification?.title);
    print(message.notification?.body);
  });
}
