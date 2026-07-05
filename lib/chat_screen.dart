import 'dart:async';
import 'dart:developer' as developer;
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'chat_message.dart';
import 'messages_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  
  final List<ChatMessage> _messages = [];
  
  late final ChatGPT _chatGPT;
  StreamSubscription? _subscription;
  bool _isTyping = false;
  
  final String _apiKey = "YourApiKey";

  @override
  void initState() {
    super.initState();
    _chatGPT = ChatGPT.instance.builder(_apiKey);
  }

  @override
  void dispose() {
    _chatGPT.genImgClose();
    _subscription?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    _focusNode.unfocus();

    setState(() {
      _messages.insert(0, ChatMessage(text: text, role: MessageRole.user));
      _isTyping = true;
    });

    _scrollToBottom();
    await _translateAndInsert(text);
  }

  Future<void> _translateAndInsert(String text) async {
    try {
      final request = CompleteReq(
        prompt: text, 
        model: kTranslateModelV3, 
        max_tokens: 200,
      );

      final response = await _chatGPT.onCompleteStream(request: request).first;
      
      if (response != null && response.choices.isNotEmpty) {
        _insertBotMessage(response.choices.first.text, MessageRole.bot);
      }
    } catch (e) {
      developer.log("API Error", error: e);
      _insertBotMessage("Sorry, I encountered an error. Please try again.", MessageRole.error);
    }
  }

  void _insertBotMessage(String text, MessageRole role) {
    if (!mounted) return;
    
    setState(() {
      _messages.insert(0, ChatMessage(text: text, role: role));
      _isTyping = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildTextInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: "Message ChatGPT...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton(
              elevation: 0,
              onPressed: _isTyping ? null : _sendMessage,
              child: const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ChatGPT"),
        centerTitle: true,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return MessageBubble(message: _messages[index]);
              },
            ),
          ),
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Lottie.asset("assets/dots.json", width: 60, height: 40),
              ),
            ),
          _buildTextInput(),
        ],
      ),
    );
  }
}
