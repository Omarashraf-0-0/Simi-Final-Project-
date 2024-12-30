import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class AboLaylaChat extends StatefulWidget {
  const AboLaylaChat({
    super.key,
    required this.selectedLanguage,
    required this.selectedCourse,
    required this.selectedCourseId,
  });

  final String selectedLanguage;
  final String selectedCourse;
  final String selectedCourseId;

  @override 
  _AboLaylaChatState createState() => _AboLaylaChatState();
}

class _AboLaylaChatState extends State<AboLaylaChat> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final model = GenerativeModel(
    model: 'gemini-1.5-flash', // Use the appropriate model
    apiKey: "AIzaSyCtRyYUAupQxyE3gjwNcL0YmbA0HqttxSE",    // Replace with your actual API key
  );
  final ScrollController _scrollController = ScrollController();

  bool isFirstPrompt = true;
  bool isTyping = false;

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final userMessage = _controller.text;

    setState(() {
      _messages.add({"sender": "user", "text": userMessage});
      _controller.clear();
      isTyping = true;
    });

    // Scroll to bottom after adding user's message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    try {
      String conversationContext = _messages
          .where((msg) => msg['sender'] != 'typing') // Exclude typing indicator
          .map((msg) =>
              "${msg['sender'] == 'user' ? 'User' : 'Bot'}: ${msg['text']}")
          .join("\n");

      String modifiedMessage;

      if (isFirstPrompt) {
        if (widget.selectedLanguage == 'مصري') {
          modifiedMessage =
              "$conversationContext\nUser: $userMessage\nBot: أنت تتحدث مع طالب جامعي في مادة ${widget.selectedCourse}. أجب على سؤاله باللغة المصرية العامية، وابدأ بـ (يا امبيسا). استخدم التنسيق مثل القوائم والرموز عند الحاجة.";
        } else {
          modifiedMessage =
              "$conversationContext\nUser: $userMessage\nBot: You are talking with a college student about ${widget.selectedCourse}. Answer the question in casual English, starting with 'Hey there'. Be friendly and supportive. Use markdown formatting such as bullet points, numbered lists, code blocks when appropriate.";
        }
        isFirstPrompt = false;
      } else {
        if (widget.selectedLanguage == 'مصري') {
          modifiedMessage =
              "$conversationContext\nUser: $userMessage\nBot: أجب بشكل طبيعي باللغة المصرية في سياق مادة ${widget.selectedCourse}. استخدم التنسيق مثل القوائم والرموز عند الحاجة.";
        } else {
          modifiedMessage =
              "$conversationContext\nUser: $userMessage\nBot: Reply normally in English about ${widget.selectedCourse}. Use markdown formatting such as bullet points, numbered lists, code blocks when appropriate.";
        }
      }

      // Add typing indicator message to list
      setState(() {
        _messages.add({'sender': 'bot', 'text': 'typing', 'isTyping': true});
      });

      // Scroll to bottom after adding typing indicator
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });

      final content = [Content.text(modifiedMessage)];
      final response = await model.generateContent(content);

      // Remove typing indicator and add bot's response
      setState(() {
        _messages.removeWhere((msg) => msg['isTyping'] == true);
        _messages.add({"sender": "bot", "text": response.text ?? "No response"});
        isTyping = false;
      });

      // Scroll to bottom after adding bot's response
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      print('Error occurred: $e');
      // Remove typing indicator and show error message
      setState(() {
        _messages.removeWhere((msg) => msg['isTyping'] == true);
        _messages.add({
          "sender": "bot",
          "text": "Oops! Something went wrong. Please try again later."
        });
        isTyping = false;
      });

      // Scroll to bottom after adding error message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose(); // Dispose the scroll controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AboLayla Chat',
            style: TextStyle(
                fontFamily: 'League Spartan',
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        backgroundColor: Color(0xFF165D96),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset('lib/assets/img/AboLayla.jpg'),
            ),
          ),
          Column(
            children: [
              if (_messages.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      widget.selectedLanguage == 'مصري'
                          ? "إزاي أقدر أساعدك في ${widget.selectedCourse}؟"
                          : "Hey there!\nWhat can I help you with in ${widget.selectedCourse}?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF165D96),
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isUser = message['sender'] == 'user';
                      if (message['isTyping'] == true) {
                        // Typing indicator
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 10.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundImage:
                                    AssetImage('lib/assets/img/AboLayla.jpg'),
                                radius: 16,
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TypingIndicator(),
                              ),
                            ],
                          ),
                        );
                      }
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
                            if (!isUser) const SizedBox(width: 12),
                            Flexible(
                              child: Container(
                                constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width * 0.7),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      isUser ? Colors.blue : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: MarkdownBody(
                                  data: message['text']!,
                                  styleSheet: MarkdownStyleSheet(
                                    p: TextStyle(
                                      color: isUser
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                    code: TextStyle(
                                      color: isUser
                                          ? Colors.white
                                          : Colors.black87,
                                      backgroundColor: Colors.transparent,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (isUser) const SizedBox(width: 12),
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
                        onSubmitted: (_) => _sendMessage(),
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

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({Key? key}) : super(key: key);

  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController? _dotController;
  int _dotCount = 3;

  @override
  void initState() {
    super.initState();
    _dotController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..repeat();
  }

  @override
  void dispose() {
    _dotController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dotController!,
      builder: (context, child) {
        int dots =
            1 + (_dotController!.value * (_dotCount - 1)).floor().toInt();
        return Text(
          '.' * dots,
          style: TextStyle(fontSize: 30, color: Colors.grey),
        );
      },
    );
  }
}