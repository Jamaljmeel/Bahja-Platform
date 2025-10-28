import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class ChatInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSending;
  final Function(String) onSendMessage;
  final VoidCallback onEmojiPressed;

  const ChatInputWidget({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.isSending,
    required this.onSendMessage,
    required this.onEmojiPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor(context),
        boxShadow: [
          BoxShadow(
            color: AppColors.borderColor(context).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          _buildSendButton(theme, context),
          const SizedBox(width: 8),
          _buildInputField(context),
        ],
      ),
    );
  }

  Widget _buildSendButton(ThemeData theme, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [theme.primaryColor, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: isSending
              ? null
              : () {
                  if (controller.text.trim().isNotEmpty) {
                    onSendMessage(controller.text.trim());
                    controller.clear();
                  }
                },
          child: Container(
            padding: const EdgeInsets.all(12),
            child: isSending
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(
                          AppColors.backgroundColor(context)),
                    ),
                  )
                : Icon(Icons.send, 
                    color: AppColors.backgroundColor(context)),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.inputFillColor(context),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: AppColors.borderColor(context).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            IconButton(
              icon: Icon(Icons.emoji_emotions_outlined,
                  color: AppColors.grey),
              onPressed: onEmojiPressed,
            ),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                textDirection: TextDirection.rtl,
                style: AppTextStyles.large(context),
                decoration: InputDecoration(
                  hintText: 'اكتب رسالتك هنا...',
                  hintStyle: AppTextStyles.large(context).copyWith(
                    color: AppColors.grey,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16),
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                onSubmitted: (text) {
                  if (text.trim().isNotEmpty) {
                    onSendMessage(text.trim());
                    controller.clear();
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}