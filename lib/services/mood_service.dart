import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/ai_config.dart';

/// Dedicated service for mood check interactions with empathetic responses
class MoodService {
  static const String _model = "llama-3.3-70b-versatile";
  
  /// Ask mood check question with empathetic, supportive responses
  static Future<String> askMoodCheck(String userMessage) async {
    // 🆕 Use main Groq key (same API, no need for separate key)
    final apiKey = AIConfig.groqKey;
    
    if (apiKey.isEmpty) {
      return "⚠️ Groq API Key not configured. Please set it in AIConfig.dart";
    }
    
    return _makeRequest(userMessage, apiKey);
  }
  
  static Future<String> _makeRequest(String message, String apiKey) async {
    final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": _model,
          "messages": [
            {
              "role": "system",
              "content": """You are a wise and comforting emotional support AI for the HIW (Health Is Wealth) app. 
Your goal is to provide immediate, simple comfort and practical remedies.

Guidelines:
1. Warmly validate the user's feelings.
2. Ask a gentle, empathetic question to understand WHY they are feeling this way or what exactly is bothering them.
3. Do NOT just jump straight into giving suggestions or remedies without first understanding their situation and the context.
4. Keep the entire response empathetic, conversational, and concise.
5. Once you understand the specific situation from their replies, you can then suggest 1-2 small, practical steps."""
            },
            {
              "role": "user",
              "content": message
            }
          ],
          "temperature": 0.8, // Higher temperature for more warm, human-like responses
          "max_tokens": 512,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('⚠️ MOOD SERVICE: HTTP request timeout');
          throw Exception('Request timeout');
        },
      );
      
      if (response.statusCode == 401) {
        return "⚠️ Invalid Mood Check API Key. Please check your key in AIConfig.dart";
      }
      
      if (response.statusCode != 200) {
        print("MOOD SERVICE ERROR: ${response.statusCode}");
        print("BODY: ${response.body}");
        return "⚠️ Mood support is temporarily unavailable. Error ${response.statusCode}.";
      }
      
      final data = jsonDecode(response.body);
      if (data['choices'] != null && data['choices'].isNotEmpty) {
        return data['choices'][0]['message']['content'].toString().trim();
      }
      
      return "I'm here for you. How can I help? 💙";
      
    } catch (e) {
      print("MOOD SERVICE EXCEPTION: $e");
      return "⚠️ Connection error. Please try again.";
    }
  }
}
