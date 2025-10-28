import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';
import '../widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String userId;
  final String providerId;
  final String providerName;
  final String providerImage;
  final String serviceId; // ✅ إضافة معرف الخدمة

  const ChatScreen({
    required this.chatId,
    required this.userId,
    required this.providerId,
    required this.providerName,
    required this.providerImage,
    required this.serviceId, // ✅

    Key? key,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // تحريك الشاشة تلقائيًا إلى آخر رسالة عند الدخول
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    // ✅ استخدام `serviceId` لضمان عدم تداخل المحادثات
    // String chatId = '${widget.userId}_${widget.providerId}_${widget.serviceId}';
    Message message = Message(
      messageId: '',
      senderId: widget.userId,
      receiverId: widget.providerId,
      text: _messageController.text.trim(),
      timestamp: DateTime.now(),
    );

    await _chatService.sendMessage(widget.chatId, message, widget.serviceId);
    _messageController.clear();

    // تحريك الشاشة إلى آخر رسالة بعد الإرسال
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
final theme = Theme.of(context);
    final customColors = AppThemes.customColors(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: theme.colorScheme.secondaryContainer,
              backgroundImage: widget.providerImage.isNotEmpty
                  ? NetworkImage(widget.providerImage)
                  : null,
              child: widget.providerImage.isEmpty
                  ? Icon(Icons.person,
                      size: 30, color: theme.colorScheme.onSecondaryContainer)
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              widget.providerName,
              style: AppTextStyles.medium(context).copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _chatService.getMessages(widget.chatId, widget.serviceId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final bool isMe = message.senderId == widget.userId;

                    return ChatBubble(
                      text: message.text,
                      isMe: isMe,
                      time: DateFormat('hh:mm a').format(message.timestamp),
                      date: DateFormat('dd/MM/yyyy').format(message.timestamp),
                      showDate: index == 0 ||
                          DateFormat('dd/MM/yyyy')
                                  .format(messages[index - 1].timestamp) !=
                              DateFormat('dd/MM/yyyy')
                                  .format(message.timestamp),
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(theme, customColors),
        ],
      ),
    );
  }

  Widget _buildMessageInput(ThemeData theme, AppThemeExtensions customColors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
               color: customColors.inputFillColor,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: customColors.borderColor),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "اكتب رسالتك...",
                        border: InputBorder.none,
                        hintStyle: AppTextStyles.small(context).copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                      style: AppTextStyles.medium(context),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: theme.primaryColor),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
