enum MessageRole { user, bot, error }

class ChatMessage {
  final String text;
  final MessageRole role;

  const ChatMessage({
    required this.text,
    required this.role,
  });
}
