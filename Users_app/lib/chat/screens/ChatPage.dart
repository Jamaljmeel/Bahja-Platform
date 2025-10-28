import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/navigation_service.dart';
import '../../utils/constants.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/custom_app_bar.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';
import '../widgets/chat_list_item.dart';
import 'chat_screen.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({Key? key}) : super(key: key);

  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  final ChatService _chatService = ChatService();
  int _selectedIndex = 1;
  String? userId; // معرف المستخدم

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    userId = _chatService.getCurrentUserId(); // الحصول على معرف المستخدم
    if (userId == null || userId!.isEmpty) {
      print("❌ خطأ: لم يتم العثور على معرف المستخدم.");
    } else {
      print("✅ معرف المستخدم: $userId");
      setState(() {}); // تحديث الواجهة بعد الحصول على المعرف
    }
  }

  void _updateIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBars(title: 'الدردشات'),
      body: userId == null || userId!.isEmpty
          ? Center(
              child: Text(
                "❌ لم يتم العثور على معرف المستخدم",
                style: AppTextStyles.medium(context),
              ),
            )
          : StreamBuilder<List<Chat>>(
              stream: _chatService.getUserChats(userId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "❌ خطأ: ${snapshot.error}",
                      style: AppTextStyles.medium(context),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'لا توجد محادثات حالية',
                      style: AppTextStyles.medium(context).copyWith(
                        color: theme.hintColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                // جلب تفاصيل مقدمي الخدمة للمحادثات
                return FutureBuilder<List<Map<String, String>>>(
                  future: _getProviderDetailsForChats(snapshot.data!),
                  builder: (context, providerDetailsSnapshot) {
                    if (providerDetailsSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (providerDetailsSnapshot.hasError) {
                      return Center(
                          child: Text(
                        "❌ خطأ في جلب بيانات مقدم الخدمة",
                        style: AppTextStyles.medium(context).copyWith(
                          color: theme.hintColor,
                        ),
                        textAlign: TextAlign.center,
                      ));
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        Chat chat = snapshot.data![index];
                        Map<String, String> providerDetails =
                            providerDetailsSnapshot.data![index];

                        return ChatListItem(
                          chat: chat.copyWith(
                            providerName: providerDetails['companyName'] ??
                                'مقدم خدمة غير معروف',
                            providerImage: providerDetails['companyLogo'] ?? '',
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  chatId: chat.chatId,
                                  userId: userId!,
                                  providerId: chat.providerId,
                                  serviceId: chat.serviceId,
                                  providerName:
                                      providerDetails['companyName'] ??
                                          'مقدم خدمة غير معروف',
                                  providerImage:
                                      providerDetails['companyLogo'] ?? '',
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
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) =>
            NavigationService.onItemTapped(context, index, _updateIndex),
      ),
    );
  }

  // دالة لتحميل بيانات مقدم الخدمة لكل محادثة
  Future<List<Map<String, String>>> _getProviderDetailsForChats(
      List<Chat> chats) async {
    List<Map<String, String>> providerDetailsList = [];

    for (Chat chat in chats) {
      Map<String, String>? providerDetails =
          await _chatService.getProviderDetails(chat.serviceId);
      providerDetailsList.add(providerDetails ??
          {'companyName': 'مقدم خدمة غير معروف', 'companyLogo': ''});
    }

    return providerDetailsList;
  }
}
