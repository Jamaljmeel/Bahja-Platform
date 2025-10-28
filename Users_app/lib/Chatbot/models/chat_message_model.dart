class ChatMessage {
  final String text;
  final bool isUserMessage;
  final DateTime time;
  final String? messageId;

  ChatMessage({
    required this.text,
    required this.isUserMessage,
    required this.time,
    this.messageId,
  });

  factory ChatMessage.fromDialogFlowMessage(dynamic message, {bool isUserMessage = false}) {
    String text = '';
    if (message.text?.text?.isNotEmpty == true) {
      text = message.text!.text!.first;
    }
    
    return ChatMessage(
      text: text,
      isUserMessage: isUserMessage,
      time: DateTime.now(),
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  factory ChatMessage.userMessage(String text) {
    return ChatMessage(
      text: text,
      isUserMessage: true,
      time: DateTime.now(),
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  factory ChatMessage.botMessage(String text) {
    return ChatMessage(
      text: text,
      isUserMessage: false,
      time: DateTime.now(),
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }
}