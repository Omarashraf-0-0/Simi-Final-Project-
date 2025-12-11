import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  final ScrollController _scrollController = ScrollController();
  final String baseUrl = 'https://alyibrahim.pythonanywhere.com';
  late String sessionId; // Unique session ID for conversation tracking

  bool isTyping = false;

  @override
  void initState() {
    super.initState();
    // Generate unique session ID per user+course combination
    sessionId = 'user_${DateTime.now().millisecondsSinceEpoch}_course_${widget.selectedCourseId}';
  }

  Future<void> _sendMessage() async {
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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    // Add typing indicator
    setState(() {
      _messages.add({'sender': 'bot', 'text': 'typing', 'isTyping': true});
    });

    // Scroll to show typing indicator
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    try {
      // Call your server's /chat endpoint with session tracking
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'co_id': int.parse(widget.selectedCourseId),
          'session_id': sessionId, // Enable conversation history
          'question': userMessage,
          'language': widget.selectedLanguage == 'مصري' ? 'مصري' : 'English',
        }),
      ).timeout(
        const Duration(seconds: 35), // 35s to allow for PDF processing on first request
        onTimeout: () {
          throw Exception('Request timeout - server is processing PDFs, please wait...');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'success') {
          String answer = data['answer'];
          List sources = data['sources'] ?? [];
          bool cacheUsed = data['cache_used'] ?? false;
          String modelUsed = data['model_used'] ?? 'unknown';
          
          // Add friendly greeting if it's the first message
          if (_messages.where((m) => m['sender'] == 'bot' && m['isTyping'] != true).isEmpty) {
            if (widget.selectedLanguage == 'مصري') {
              answer = "يا امبيسا! 🎓\n\n$answer";
            } else {
              answer = "Hey there! 🎓\n\n$answer";
            }
          }
          
          // Add processing info for debug (optional, can remove later)
          String debugInfo = cacheUsed ? '⚡ (Cached)' : '🔄 (Fresh)';
          if (modelUsed == 'ai') {
            debugInfo += ' 🤖 AI';
          }

          // Remove typing indicator and add response
          setState(() {
            _messages.removeWhere((msg) => msg['isTyping'] == true);
            _messages.add({
              "sender": "bot",
              "text": answer,
              "sources": sources,
              "debug": debugInfo,
            });
            isTyping = false;
          });
        } else {
          throw Exception(data['message'] ?? 'Unknown error');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }

      // Scroll to bottom after adding response
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      print('Error occurred: $e');
      
      // Remove typing indicator and show error
      setState(() {
        _messages.removeWhere((msg) => msg['isTyping'] == true);
        
        String errorMessage;
        if (widget.selectedLanguage == 'مصري') {
          errorMessage = "عذراً يا صاحبي! 😅\nحصل مشكلة. حاول تاني بعد شوية.";
        } else {
          errorMessage = "Oops! 😅\nSomething went wrong. Please try again in a moment.";
        }
        
        if (e.toString().contains('timeout')) {
          if (widget.selectedLanguage == 'مصري') {
            errorMessage = "استنى شوية يا صاحبي... 🔄\nأول مرة بنحمل المادة دي، ممكن ياخد 30 ثانية. حاول تاني دلوقتي!";
          } else {
            errorMessage = "Hold on! 🔄\nFirst time loading this course takes ~30 seconds. Try again now!";
          }
        }
        
        _messages.add({
          "sender": "bot",
          "text": errorMessage,
        });
        isTyping = false;
      });

      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
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
    const Color primaryColor = Color(0xFF165D96);
    const String fontFamily = 'League Spartan';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AboLayla Chat',
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset('assets/img/AboLayla.jpg'),
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
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
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
                                    AssetImage('assets/img/AboLayla.jpg'),
                                radius: 16,
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const TypingIndicator(),
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
                                    AssetImage('assets/img/AboLayla.jpg'),
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
                      icon: const Icon(Icons.send),
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
  const TypingIndicator({super.key});

  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _dotController;

  final int _dotCount = 3;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat();
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dotController,
      builder: (context, child) {
        int dots =
            1 + (_dotController.value * (_dotCount - 1)).floor().toInt();
        return Text(
          '.' * dots,
          style: const TextStyle(fontSize: 30, color: Colors.grey),
        );
      },
    );
  }
}