import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_fonts/google_fonts.dart';

class AboLaylaChat extends StatefulWidget {
  const AboLaylaChat({super.key, required this.selectedLanguage});

  final String selectedLanguage;

  @override
  _AboLaylaChatState createState() => _AboLaylaChatState();
}

class _AboLaylaChatState extends State<AboLaylaChat> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: "AIzaSyCtRyYUAupQxyE3gjwNcL0YmbA0HqttxSE",
  );

  bool isFirstPrompt = true;

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final userMessage = _controller.text;

    setState(() {
      _messages.add({"sender": "user", "text": userMessage});
      _controller.clear();
    });

    try {
      // Construct the conversation context
      String conversationContext = _messages
          .map((msg) =>
              "${msg['sender'] == 'user' ? 'User' : 'Bot'}: ${msg['text']}")
          .join("\n");

      String modifiedMessage;

      if (isFirstPrompt) {
        if (widget.selectedLanguage == 'مصري') {
          modifiedMessage =
              "$conversationContext\nUser: $userMessage\nBot: Answer this question in Egyptian Baladi, and start with (يا امبيسا). You are talking with a college student.";
        } else {
          modifiedMessage =
              "$conversationContext\nUser: $userMessage\nBot: Answer this question in English casually, and start with (Hey there). You're talking with a college student. Make it friendly and supportive.";
        }
        isFirstPrompt = false;
      } else {
        if (widget.selectedLanguage == 'مصري') {
          modifiedMessage =
              "$conversationContext\nUser: $userMessage\nBot: Reply normally in Egyptian Baladi.";
        } else {
          modifiedMessage =
              "$conversationContext\nUser: $userMessage\nBot: Reply normally in English.";
        }
      }

      final content = [Content.text(modifiedMessage)];
      final response = await model.generateContent(content);

      setState(() {
        _messages
            .add({"sender": "bot", "text": response.text ?? "No response"});
      });
    } catch (e) {
      setState(() {
        _messages.add({
          "sender": "bot",
          "text": "Oops! Something went wrong. Please try again later."
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF165D96),
        title: const Text('AboLayla Chat', style: TextStyle(fontFamily: 'League Spartan', fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'lib/assets/img/AboLayla.jpg',
                // fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              if (_messages.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      widget.selectedLanguage == 'مصري'
                          ? "إزاي أقدر أساعدك؟"
                          : "Hey there!\nWhat can I help you with?",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF165D96),
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isUser = message['sender'] == 'user';
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                        child: Row(
                          mainAxisAlignment: isUser
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            if (!isUser)
                              CircleAvatar(
                                backgroundImage:
                                    AssetImage('lib/assets/img/AboLayla.jpg'),
                                radius: 16,
                              ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Container(
                                constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width *
                                            0.7),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      isUser ? Colors.blue : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  message['text']!,
                                  style: TextStyle(
                                    color:
                                        isUser ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        maxLines: 5,
                        minLines: 1,
                        textDirection: widget.selectedLanguage == 'مصري'
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        style: widget.selectedLanguage == 'مصري'
                            ? GoogleFonts.cairo(fontSize: 16.0)
                            : null,
                        decoration: InputDecoration(
                          hintText: widget.selectedLanguage == 'مصري'
                              ? 'اكتب رسالتك...'
                              : 'Type your message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: _sendMessage,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
