import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';
import '../widgets/chat_bubble.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/message_input_field.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String userId;
  final String providerId;
  final String userName;
  final String serviceId; // ✅ إضافة معرف الخدمة

  const ChatScreen({
    required this.chatId,
    required this.userId,
    required this.providerId,
    required this.userName,
    required this.serviceId,
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    Message message = Message(
      messageId: '',
      senderId: widget.serviceId,
      receiverId: widget.userId,
      text: _messageController.text.trim(),
      timestamp: DateTime.now(),
    );

    await _chatService.sendMessage(widget.chatId, message, widget.serviceId);
    _messageController.clear();
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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [Colors.blueGrey.shade900, Colors.blueGrey.shade700]
                  : [Colors.blue[800]!, Colors.blue[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: isDark ? Colors.blueGrey[700] : Colors.blue[100],
              child: Icon(
                Icons.person,
                size: 20,
                color: isDark ? Colors.white : Colors.blue[800],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.userName,
              style: GoogleFonts.elMessiri(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        elevation: 4,
        backgroundColor: Colors.transparent,
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
                    final bool isMe = message.senderId == widget.providerId;

                    return ChatBubble(
                      text: message.text,
                      isMe: isMe,
                      time: DateFormat('hh:mm a').format(message.timestamp),
                      date: DateFormat('dd/MM/yyyy').format(message.timestamp),
                      showDate: index == 0 ||
                          DateFormat('dd/MM/yyyy').format(messages[index - 1].timestamp) !=
                              DateFormat('dd/MM/yyyy').format(message.timestamp),
                    );
                  },
                );
              },
            ),
          ),
             MessageInputField(
      controller: _messageController,
      onSend: _sendMessage,
      isDark: isDark,
          ),
        ],
      ),
    );
  }
}
