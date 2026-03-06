import 'dart:convert';

import 'package:bytebox/features/ai_chat/models/chat_message.dart';
import 'package:http/http.dart' as http;

class OpenAiChatService {
  static const _defaultModel = String.fromEnvironment(
    'OPENAI_MODEL',
    defaultValue: 'gpt-4o-mini',
  );

  static const _apiKey = String.fromEnvironment('OPENAI_API_KEY');

   // Instructs the model to always answer in this fixed FAQ-style structure.
   static const _predefinedStructureInstruction = '''
You are a sales assistant for refurbished laptops.
Always answer in this exact structure, even if the user asks something different:

1) Is the laptop refurbished?
2) What warranty do I get?
3) Battery backup kitna milega?
4) Do you provide GST bill?
5) Is RAM/SSD upgrade possible?

For each point, give a short, clear answer in 1–2 lines.''';

  Future<String> chat({
    required List<ChatMessage> messages,
  }) async {
    if (_apiKey.trim().isEmpty) {
      throw Exception(
        'Missing OPENAI_API_KEY. Run the app with --dart-define=OPENAI_API_KEY=YOUR_KEY',
      );
    }

    final uri = Uri.parse('https://api.openai.com/v1/chat/completions');

    final apiMessages = <Map<String, Object?>>[
      {
        'role': 'system',
        'content': _predefinedStructureInstruction,
      },
      ...messages
          .where((m) => m.content.trim().isNotEmpty)
          .map((m) => {
                'role': _toOpenAiRole(m.role),
                'content': m.content,
              }),
    ];

    final payload = <String, Object?>{
      'model': _defaultModel,
      'temperature': 0.2,
      'messages': apiMessages,
    };

    final res = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      final body = res.body.isNotEmpty ? res.body : '(empty body)';
      throw Exception('OpenAI error ${res.statusCode}: $body');
    }

    final decoded = jsonDecode(res.body);
    final content =
        decoded['choices']?[0]?['message']?['content']?.toString().trim();
    if (content == null || content.isEmpty) {
      throw Exception('OpenAI returned an empty response.');
    }
    return content;
  }

  static String _toOpenAiRole(ChatRole role) {
    return switch (role) {
      ChatRole.system => 'system',
      ChatRole.user => 'user',
      ChatRole.assistant => 'assistant',
    };
  }
}

