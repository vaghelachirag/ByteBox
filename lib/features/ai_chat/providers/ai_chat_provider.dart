import 'package:bytebox/features/ai_chat/models/chat_message.dart';
import 'package:bytebox/features/ai_chat/services/openai_chat_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AiChatState {
  final List<ChatMessage> messages;
  final bool isSending;
  final String? error;

  const AiChatState({
    required this.messages,
    required this.isSending,
    required this.error,
  });

  factory AiChatState.initial() {
    return AiChatState(
      messages: [
        ChatMessage(
          id: _newId(),
          role: ChatRole.system,
          content:
              'You are a helpful Q&A assistant. Answer clearly and concisely.',
          createdAt: DateTime.now(),
        ),
        ChatMessage(
          id: _newId(),
          role: ChatRole.assistant,
          content: 'Ask me anything.',
          createdAt: DateTime.now(),
        ),
      ],
      isSending: false,
      error: null,
    );
  }

  AiChatState copyWith({
    List<ChatMessage>? messages,
    bool? isSending,
    String? error,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      error: error,
    );
  }
}

class AiChatNotifier extends StateNotifier<AiChatState> {
  final OpenAiChatService _service;

  AiChatNotifier(this._service) : super(AiChatState.initial());

  Future<void> sendUserMessage(String text) async {
    final prompt = text.trim();
    if (prompt.isEmpty) return;
    if (state.isSending) return;

    final userMsg = ChatMessage(
      id: _newId(),
      role: ChatRole.user,
      content: prompt,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isSending: true,
      error: null,
    );

    try {
      final reply = await _service.chat(messages: state.messages);
      final assistantMsg = ChatMessage(
        id: _newId(),
        role: ChatRole.assistant,
        content: reply,
        createdAt: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, assistantMsg],
        isSending: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: e.toString(),
      );
    }
  }

  void clearConversation() {
    state = AiChatState.initial();
  }
}

final _openAiChatServiceProvider = Provider<OpenAiChatService>((ref) {
  return OpenAiChatService();
});

final aiChatProvider = StateNotifierProvider<AiChatNotifier, AiChatState>((ref) {
  return AiChatNotifier(ref.watch(_openAiChatServiceProvider));
});

String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

