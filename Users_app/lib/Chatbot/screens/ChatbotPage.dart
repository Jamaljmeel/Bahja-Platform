import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../models/chat_message_model.dart';
import '../services/chat_service.dart';
import '../widgets/chat_bubble_widget.dart';
import '../widgets/chat_input_widget.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final ChatService _chatService = ChatService.instance;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _initializeChatbot();
  }

// screens/chatbot_screen.dart - تحديث دالة _initializeChatbot
Future<void> _initializeChatbot() async {
  try {
    bool initialized = await _chatService.initialize();
    // حتى لو فشل DialogFlow، سنستخدم الـ fallback
    await Future.delayed(const Duration(milliseconds: 500));
    _addMessage(_chatService.getWelcomeMessage());
  } catch (e) {
    print('Error initializing chatbot: $e');
    // حتى في حالة الخطأ، أضف رسالة ترحيب
    _addMessage(ChatMessage.botMessage(
      'مرحباً! أنا أعمل في الوضع المحدود. كيف يمكنني مساعدتك؟'
    ));
  } finally {
    setState(() => _isLoading = false);
  }
}

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.medium(context),
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
      _addMessage(ChatMessage.userMessage(text));
    });

    _scrollToBottom();
    _focusNode.unfocus();

    try {
      ChatMessage? response = await _chatService.sendMessage(text);
      if (response != null && mounted) {
        setState(() {
          _addMessage(response);
        });
      }
    } catch (e) {
      print('Error sending message: $e');
      if (mounted) {
        _showErrorSnackbar('حدث خطأ في إرسال الرسالة');
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _addMessage(ChatMessage message) {
    _messages.add(message);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearMessages() {
    setState(() {
      _messages.clear();
      _addMessage(_chatService.getWelcomeMessage());
    });
  }

  void _onEmojiPressed() {
    // TODO: Add emoji picker functionality
    print('Emoji button pressed');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor(context),
        appBar: _buildAppBar(theme, context),
        body: _isLoading
            ? _buildLoadingState(theme)
            : Column(
                children: [
                  Expanded(
                    child: _buildMessagesArea(isDarkMode),
                  ),
                  ChatInputWidget(
                    controller: _controller,
                    focusNode: _focusNode,
                    isSending: _isSending,
                    onSendMessage: _sendMessage,
                    onEmojiPressed: _onEmojiPressed,
                  ),
                ],
              ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, BuildContext context) {
    return AppBar(
      backgroundColor: theme.primaryColor,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(
          Icons.arrow_circle_right,
          color: AppColors.backgroundColor(context),
          size: 30,
        ),
      ),
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.backgroundColor(context),
            child: Icon(
              Icons.smart_toy,
              color: theme.primaryColor,
              size: 20,
            ),
            radius: 16,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'المساعد الذكي',
                style: AppTextStyles.heading(context).copyWith(
                  color: AppColors.backgroundColor(context),
                ),
              ),
              Container(
                width: 110,
                alignment: Alignment.centerRight,
                child: Text(
                  'متصل الآن',
                  style: AppTextStyles.small(context).copyWith(
                    color: AppColors.backgroundColor(context),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: AppColors.backgroundColor(context)),
          onSelected: (value) {
            if (value == 'clear') {
              _clearMessages();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'clear',
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  const Icon(Icons.delete, color: Colors.red),
                  const SizedBox(width: 8),
                  Text('مسح المحادثة', style: AppTextStyles.medium(context)),
                ],
              ),
            ),
          ],
        ),
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(theme.primaryColor),
      ),
    );
  }

  Widget _buildMessagesArea(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: _messages.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              padding: const EdgeInsets.only(top: 20, bottom: 10),
              itemBuilder: (context, index) {
                return ChatBubbleWidget(
                  message: _messages[index],
                  isDarkMode: isDarkMode,
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.smart_toy,
            size: 100,
            color: Theme.of(context).primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          Text(
            'كيف يمكنني مساعدتك اليوم؟',
            style: AppTextStyles.large(context).copyWith(
              color: AppColors.grey,
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}