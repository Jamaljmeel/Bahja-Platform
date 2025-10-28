import 'package:flutter/material.dart';
import 'package:services_providers/chat/screens/chat_screen.dart';
import '../services/chat_service.dart';
import '../widgets/chat_list_item.dart';
import '../models/chat_model.dart';

class ChatsPage extends StatefulWidget {
  // final String providerId;

  // const ChatsPage({Key? key, required this.providerId}) : super(key: key);

  

  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  final ChatService _chatService = ChatService();

  String? providerId; // معرف المستخدم

  @override
  void initState() {
    super.initState();
    _loadproviderId();
  }

  Future<void> _loadproviderId() async {
    providerId = _chatService.getCurrentproviderId();
    if (providerId == null || providerId!.isEmpty) {
      print("❌ خطأ: لم يتم العثور على معرف المستخدم.");
    } else {
      print("✅ معرف المستخدم: $providerId");
    setState(() {}); // تحديث الواجهة بعد الحصول على المعرف
    }
  }

// @override
// void initState() {
//   super.initState();
//   print("✅ ChatsPage مفتوحة لمقدم الخدمة: ${widget.providerId}");
// }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('الدردشات')),
      body: providerId == null || providerId!.isEmpty
          ? const Center(child: Text("❌ لم يتم العثور على معرف المستخدم"))
          : StreamBuilder<List<Chat>>(
              stream: _chatService.getProviderChats(providerId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                  if (snapshot.hasError) {
                  return Center(child: Text("❌ خطأ: ${snapshot.error}"));
                }

                if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
                  return const Center(child: Text("🚀 لا توجد محادثات بعد"));
                }

                

                // جلب تفاصيل مقدمي الخدمة للمحادثات
                return FutureBuilder<List<Map<String, String>>>(
                  future: _getuserDetailsForChats(snapshot.data!),
                  builder: (context, userDetailsSnapshot) {
                    if (userDetailsSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (userDetailsSnapshot.hasError) {
                      return Center(child: Text("❌ خطأ في جلب بيانات المستخدمين"));
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                      Chat chat = snapshot.data![index];
                      Map<String, String> userDetails = userDetailsSnapshot.data![index];

                    return ChatListItem(
                       chat: chat.copyWith(
                       userName: userDetails['userName'] ?? 'المستخدم غير معروف',
                         ),
                       onTap: () {
                    // انتقل إلى صفحة الدردشة عند الضغط على عنصر القائمة
                    Navigator.push(
                      context,
                        MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  chatId: chat.chatId,
                                  userId: providerId!,
                                  providerId: chat.userId,
                                  serviceId: chat.serviceId,
                                  userName: userDetails['userName'] ?? '',
                                ),
                              ),
                    );
                  },
                );
              },
            );
          },
         ); 
        },
      ),
    );
  }
    // دالة لتحميل بيانات مقدم الخدمة لكل محادثة
  Future<List<Map<String, String>>> _getuserDetailsForChats(List<Chat> chats) async {
    List<Map<String, String>> userDetailsList = [];

    for (Chat chat in chats) {
      Map<String, String>? userDetails = await _chatService.getUserDetails(chat.userId);
      userDetailsList.add(userDetails ?? {'userName': 'المستخدم غير معروف',});
    }

    return userDetailsList;
  }
}
