import 'package:flutter/material.dart';
import 'chat_message.dart';
class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final isError = message.role == MessageRole.error;
    final theme = Theme.of(context);

    final backgroundColor = isUser 
        ? theme.colorScheme.primary 
        : isError 
            ? theme.colorScheme.errorContainer 
            : theme.colorScheme.surfaceVariant;
            
    final textColor = isUser 
        ? theme.colorScheme.onPrimary 
        : isError 
            ? theme.colorScheme.onErrorContainer 
            : theme.colorScheme.onSurfaceVariant;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 2),
            bottomRight: Radius.circular(isUser ? 2 : 16),
          ),
        ),
        child: Text(
          message.text.trim(),
          style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
        ),
      ),
    );
  }
}
