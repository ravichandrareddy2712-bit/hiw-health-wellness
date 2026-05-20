import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/ai_config.dart';

/// Service to check if a message is a greeting using Groq AI
class GreetingDetectionService {
  static const String _model = "llama-3.3-70b-versatile";
  
  /// Ask Groq AI if the message is a greeting or a real question
  /// Returns true if greeting, false if question
  static Future<bool> isGreeting(String userMessage) async {
    final apiKey = AIConfig.groqKey;
    
    if (apiKey.isEmpty) {
      // Fallback to simple check if no API key
      return _simpleGreetingCheck(userMessage);
    }
    
    try {
      final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
      
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
              "content": """You are a greeting detector. Your ONLY job is to determine if a user's message is a greeting/pleasantry or a real question.

Greetings include: hi, hello, hey, good morning, thanks, thank you, bye, see you, hlo, hii, sup, what's up, how are you, etc.

Real questions are anything asking for information, help, or requiring a substantive response.

Respond with ONLY ONE WORD:
- "GREETING" if it's a greeting/pleasantry
- "QUESTION" if it's a real question

Examples:
User: "hi" → GREETING
User: "hlo" → GREETING
User: "thanks" → GREETING
User: "how are you" → GREETING
User: "what is protein" → QUESTION
User: "help me with my diet" → QUESTION"""
            },
            {
              "role": "user",
              "content": userMessage
            }
          ],
          "temperature": 0.1, // Low temperature for consistent classification
          "max_tokens": 10,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          final answer = data['choices'][0]['message']['content'].toString().trim().toUpperCase();
          return answer.contains('GREETING');
        }
      }
      
      // Fallback to simple check on error
      return _simpleGreetingCheck(userMessage);
      
    } catch (e) {
      print("GREETING DETECTION ERROR: $e");
      return _simpleGreetingCheck(userMessage);
    }
  }
  
  /// Simple fallback greeting check
  static bool _simpleGreetingCheck(String text) {
    final lower = text.toLowerCase().trim();
    const greetings = [
      'hi', 'hello', 'hey', 'hlo', 'hii', 'good morning', 'good afternoon',
      'good evening', 'good night', 'how are you', "what's up", 'sup',
      'yo', 'hola', 'greetings', 'howdy', 'thanks', 'thank you', 'bye',
      'goodbye', 'see you', 'see ya', 'later', 'cheers'
    ];
    return greetings.any((g) => lower == g || lower.startsWith('$g ') || lower.endsWith(' $g'));
  }
}
