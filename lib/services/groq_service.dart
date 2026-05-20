import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/ai_config.dart';

class GroqService {
  static const String _model = "llama-3.3-70b-versatile"; // High performance Groq model
  
  static Future<String> ask(String question, {String? systemPrompt}) async {
    // 1. Check Hardcoded Key first
    if (AIConfig.groqKey.isNotEmpty) {
      return _makeRequest(question, AIConfig.groqKey, systemPrompt: systemPrompt);
    }

    // 2. Fallback to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('groq_api_key');

    if (apiKey == null || apiKey.isEmpty) {
      return "⚠️ Groq API Key not found! Please set it in code (AIConfig.dart) or in settings to talk to Foodity.";
    }

    return _makeRequest(question, apiKey, systemPrompt: systemPrompt);
  }

  static Future<String> _makeRequest(String question, String apiKey, {String? systemPrompt}) async {
    final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
    
    final String prompt = systemPrompt ?? 
        "You are Foodity, a specialized Food and Health AI helper for the HIW (Health Is Wealth) app. "
        "Answer ONLY questions related to food, nutrition, safety, and health. "
        "If a user asks about anything else, politely refuse: "
        "'Apologies, I am Foodity, your food and health assistant. I cannot assist with that.' "
        "IMPORTANT EXCEPTION: If the user is just greeting you (e.g., 'yo', 'hi', 'hello', 'good morning') or sending wishes, "
        "RECOGNIZE it as a greeting/wish. DO NOT apologize or refuse. Instead, reply with a friendly, natural return greeting "
        "and ask how you can help them with their food and health goals. "
        "Keep all responses professional, concise, and motivating.";

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
              "content": prompt
            },
            {
              "role": "user",
              "content": question
            }
          ],
          "temperature": 0.7,
          "max_tokens": 1024,
        }),
      );

      if (response.statusCode == 401) {
        return "⚠️ Invalid Groq API Key. Please check your key in settings.";
      }

      if (response.statusCode != 200) {
        print("GROQ ERROR: ${response.statusCode}");
        print("BODY: ${response.body}");
        return "⚠️ Foodity is temporarily unavailable. Error ${response.statusCode}.";
      }

      final data = jsonDecode(response.body);
      if (data['choices'] != null && data['choices'].isNotEmpty) {
        return data['choices'][0]['message']['content'].toString().trim();
      }
      
      return "🤔 Foodity is thinking, but couldn't find the right words.";
      
    } catch (e) {
      print("GROQ EXCEPTION: $e");
      return "⚠️ Connection error to Groq Cloud.";
    }
  }
}
