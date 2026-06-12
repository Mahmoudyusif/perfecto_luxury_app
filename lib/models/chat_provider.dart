import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime time;

  ChatMessage({required this.text, required this.isMe, required this.time});
}

class ChatProvider with ChangeNotifier {
  final List<ChatMessage> _messages = [];
  
  // Note: For a real app, the API Key should be handled securely.
  // This structure is ready for the owner to put their OpenAI Key.
  final String _apiKey = "YOUR_OPENAI_API_KEY_HERE"; 
  final String _apiUrl = "https://api.openai.com/v1/chat/completions";

  List<ChatMessage> get messages => _messages;
  int _totalConversations = 24;
  double _teamSatisfactionScore = 4.9;

  int get totalConversations => _totalConversations;
  double get satisfactionScore => _teamSatisfactionScore;

  bool _isArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  Future<void> sendMessage(String text) async {
    _messages.add(ChatMessage(text: text, isMe: true, time: DateTime.now()));
    notifyListeners();

    String responseText = "";
    String lowerText = text.toLowerCase();
    bool isAr = _isArabic(text);

    // --- Smart Intelligence Logic (Keyword-based) ---
    // This provides immediate professional answers even without an API Key.
    if (lowerText.contains("سعر") || lowerText.contains("بكام") || lowerText.contains("price")) {
      responseText = isAr 
          ? "تبدأ أسعارنا في بيرفيكتو من 350 ج.م وتصل إلى 3500 ج.م للقطع الحصرية. كل قطعة موجود سعرها تحت صورتها في المتجر." 
          : "Our prices at Perfecto start from 350 EGP up to 3500 EGP for exclusive pieces. You can find the price listed under each item in the store.";
    } else if (lowerText.contains("شحن") || lowerText.contains("توصيل") || lowerText.contains("delivery") || lowerText.contains("shipping")) {
      responseText = isAr 
          ? "توصيلنا سريع جداً! بنوصل خلال 2-4 أيام عمل لجميع المحافظات، والشحن مجاني للطلبات فوق 2000 ج.م." 
          : "We offer very fast delivery! 2-4 business days to all governorates. Free shipping on orders over 2000 EGP.";
    } else if (lowerText.contains("مقاس") || lowerText.contains("size") || lowerText.contains("المقاسات")) {
      responseText = isAr 
          ? "متوفر عندنا مقاسات متنوعة من S وحتى XXL. تقدري تلاقي جدول المقاسات بالتفصيل في صفحة كل منتج عشان تضمني الاختيار الصح." 
          : "We provide sizes from S to XXL. You can check the detailed size chart on each product page to ensure the perfect fit.";
    } else if (lowerText.contains("فرع") || lowerText.contains("عنوان") || lowerText.contains("location") || lowerText.contains("branch")) {
      responseText = isAr 
          ? "فروعنا في القاهرة: عباس العقاد (بجوار قويدر)، عباس العقاد 2 (أسفل زلط)، وفرع فيصل (محطة المساحة). تقدري تشوفي الخريطة في صفحة الفروع." 
          : "Our branches: Abbas El Akkad (next to Koueider), Abbas El Akkad 2 (below Zalat), and Faisal St. You can view the maps in the 'Explore' tab.";
    } else if (lowerText.contains("خصم") || lowerText.contains("offer") || lowerText.contains("discount") || lowerText.contains("كود")) {
      responseText = isAr 
          ? "تقدري تستخدمي كود PERFECTO10 وتاخدي خصم 10% على أول أوردر ليكي من التطبيق!" 
          : "You can use code PERFECTO10 to get a 10% discount on your first order through the app!";
    } else if (lowerText.contains("ازيك") || lowerText.contains("عامل") || lowerText.contains("hello") || lowerText.contains("hi")) {
      responseText = isAr 
          ? "أهلاً بكِ في عالم بيرفيكتو! أنا مساعدكِ الذكي، إزاي أقدر أساعدكِ في اختيار إطلالتكِ النهاردة؟" 
          : "Welcome to Perfecto World! I am your AI assistant. How can I help you style your look today?";
    }

    if (responseText.isNotEmpty) {
      await Future.delayed(const Duration(seconds: 1));
      _messages.add(ChatMessage(text: responseText, isMe: false, time: DateTime.now()));
      _totalConversations++;
      notifyListeners();
      return;
    }

    // Attempt to use ChatGPT API if Key is provided
    if (_apiKey != "YOUR_OPENAI_API_KEY_HERE") {
      try {
        final response = await http.post(
          Uri.parse(_apiUrl),
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'Authorization': 'Bearer $_apiKey',
          },
          body: jsonEncode({
            "model": "gpt-3.5-turbo",
            "messages": [
              {"role": "system", "content": "You are a professional luxury fashion assistant for 'Perfecto Brand' in Egypt. Your tone is elegant and sophisticated. Respond in the user's language."},
              {"role": "user", "content": text}
            ],
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          responseText = data['choices'][0]['message']['content'].trim();
          _messages.add(ChatMessage(text: responseText, isMe: false, time: DateTime.now()));
          notifyListeners();
          return;
        }
      } catch (e) {
        debugPrint("Chat GPT Error: $e");
      }
    }

    // Default Professional Fallback
    await Future.delayed(const Duration(seconds: 1));
    responseText = isAr 
        ? "شكراً لتواصلكِ معنا! أنا مساعد بيرفيكتو الذكي، تقدري تسأليني عن الفروع، الأسعار، المقاسات، أو تتبع الأوردرات." 
        : "Thank you for contacting us! I am the Perfecto assistant. You can ask me about branches, prices, sizes, or order tracking.";
    
    _messages.add(ChatMessage(text: responseText, isMe: false, time: DateTime.now()));
    _totalConversations++;
    notifyListeners();
  }
}

final chatProvider = ChatProvider();
