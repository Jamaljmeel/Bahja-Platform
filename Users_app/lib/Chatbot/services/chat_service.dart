// services/chat_service.dart
import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/services.dart' hide TextInput;
import '../models/chat_message_model.dart';

class ChatService {
  static ChatService? _instance;
  DialogFlowtter? _dialogFlowtter;
  bool _isInitialized = false;

  ChatService._internal();

  static ChatService get instance {
    _instance ??= ChatService._internal();
    return _instance!;
  }

  bool get isInitialized => _isInitialized;

  Future<bool> initialize() async {
    try {
      // طريقة 1: تحميل من ملف assets
      _dialogFlowtter = await DialogFlowtter.fromFile(
        path: 'asset/dialogflow/dialog_flow_auth.json', // مسار الملف
      );
      
      _isInitialized = true;
      print('DialogFlow initialized successfully');
      return true;
    } catch (e) {
      print('Error initializing DialogFlow: $e');
      _isInitialized = false;
      
      // محاولة إنشاء chatbot محلي كـ fallback
      print('Falling back to local chatbot');
      return true; // إرجاع true للسماح باستخدام الـ fallback
    }
  }

  Future<ChatMessage?> sendMessage(String text) async {
    try {
      if (_dialogFlowtter != null && _isInitialized) {
        DetectIntentResponse response = await _dialogFlowtter!.detectIntent(
          queryInput: QueryInput(text: TextInput(text: text)),
        );

        if (response.message != null) {
          return ChatMessage.fromDialogFlowMessage(response.message!);
        }
      }
      
      // Fallback: استخدام ردود محلية
      return _getLocalResponse(text);
      
    } catch (e) {
      print('Error sending message: $e');
      // إذا فشل DialogFlow، استخدم الردود المحلية
      return _getLocalResponse(text);
    }
  }

  ChatMessage _getLocalResponse(String userMessage) {
    String response = _generateLocalResponse(userMessage.toLowerCase());
    return ChatMessage.botMessage(response);
  }

  String _generateLocalResponse(String message) {
    // ردود بسيطة محلية
    if (message.contains('مرحبا') || message.contains('السلام') || message.contains('أهلا')) {
      return 'مرحباً بك! كيف يمكنني مساعدتك اليوم؟';
    } else if (message.contains('كيف حالك') || message.contains('كيفك')) {
      return 'أنا بخير، شكراً لسؤالك! كيف يمكنني مساعدتك؟';
    } else if (message.contains('شكرا') || message.contains('شكراً')) {
      return 'العفو! أتمنى أن أكون قد ساعدتك.';
    } else if (message.contains('وداعا') || message.contains('مع السلامة')) {
      return 'وداعاً! أتمنى لك يوماً سعيداً.';
    } else if (message.contains('ما اسمك') || message.contains('من أنت')) {
      return 'أنا المساعد الذكي، هنا لمساعدتك في أي استفسار.';
    } else if (message.contains('مساعدة') || message.contains('ساعدني')) {
      return 'بالطبع! أخبرني كيف يمكنني مساعدتك.';
    } else if (message.contains('الطقس') || message.contains('الجو')) {
      return 'عذراً، لا أستطيع الوصول إلى معلومات الطقس حالياً. هل يمكنني مساعدتك في شيء آخر؟';
    } else if (message.contains('الوقت') || message.contains('الساعة')) {
      final now = DateTime.now();
      return 'الوقت الحالي هو ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    } else {
      return 'شكراً لرسالتك. كيف يمكنني مساعدتك بشكل أفضل؟';
    }
  }

  ChatMessage getWelcomeMessage() {
    return ChatMessage.botMessage(
      'مرحباً! أنا المساعد الذكي، كيف يمكنني مساعدتك اليوم؟'
    );
  }

  void dispose() {
    if (_dialogFlowtter != null) {
      _dialogFlowtter!.dispose();
      _isInitialized = false;
    }
  }
}