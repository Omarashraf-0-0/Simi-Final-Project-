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

  bool isFirstPrompt = true; // Flag to check if it's the first prompt

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final userMessage = _controller.text;

    setState(() {
      // Add user's message to the chat
      _messages.add({"sender": "user", "text": userMessage});
      _controller.clear();
    });

    try {
      // Modify the message based on whether it's the first prompt
      String modifiedMessage = userMessage;

      if (isFirstPrompt) {
        // Special prompt for the first message
        modifiedMessage =
            "$userMessage : Answer this question in Egyptian Baladi, and start with (يا امبيسا) you are talking with a college student. if the message I just gave you mentioned the word (تامر) then say that we just made ابو ليله in just 2 hours ago, and tell Dr.Tamer to look at our faces around him and see how they are embarrassed and don’t mention that the message said (تامر). Make it funny, but if the message did not say the word (تامر) then just reply to the message normally in Egyptian Balady. Don’t mention that you skipped, just answer the message";
        
        // Set the flag to false after the first prompt
        isFirstPrompt = false;
      } else {
        // Regular conversation handling for subsequent messages
        modifiedMessage = "$userMessage: Answer normally in Egyptian Baladi.";
      }

      // Fetch Gemini response
      final content = [Content.text(modifiedMessage)];
      final response = await model.generateContent(content);

      setState(() {
        // Add Gemini's response to the chat
        _messages.add({"sender": "bot", "text": response.text ?? "No response"});
      });
    } catch (e) {
      setState(() {
        // Add error message if the API fails
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
        title: const Text('AboLayla Chat'),
      ),
      body: Stack(
        children: [
          // Background Image with low opacity
          Positioned.fill(
            child: Opacity(
              opacity: 0.1, // Adjust the opacity here
              child: Image.asset(
                'lib/assets/img/AboLayla.jpg',
                // fit: BoxFit.cover, // Make the image cover half of the screen
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
                          ? "إزاي أقدر أساعدك؟"  // Egyptian Arabic
                          : "Ahh, What can I help you with?", // English
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
                                backgroundImage: AssetImage(
                                    'lib/assets/img/AboLayla.jpg'), // Replace with your bot icon
                                radius: 16,
                              ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Container(
                                constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width * 0.7),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isUser ? Colors.blue : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  message['text']!,
                                  style: TextStyle(
                                    color: isUser ? Colors.white : Colors.black87,
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
                        maxLines: 5, // Limit the number of lines
                        minLines: 1, // Minimum number of lines
                        textDirection: widget.selectedLanguage == 'مصري'
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        style: widget.selectedLanguage == 'مصري'
                            ? GoogleFonts.cairo(fontSize: 16.0) // Apply Cairo font for Arabic
                            : null, // Default font for English
                        decoration: InputDecoration(
                          hintText: widget.selectedLanguage == 'مصري'
                              ? 'اكتب رسالتك...' // Arabic hint text
                              : 'Type your message...', // English hint text
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        keyboardType: TextInputType.multiline,
                        maxLength: null, // Allow unlimited characters
                        scrollPadding: EdgeInsets.all(20.0), // Add some space around the scrollable field
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
