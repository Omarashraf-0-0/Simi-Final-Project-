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

class _AboLaylaChatState extends State<AboLaylaChat>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final String baseUrl = 'https://alyibrahim.pythonanywhere.com';
  late String sessionId; // Unique session ID for conversation tracking
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool isTyping = false;

  @override
  void initState() {
    super.initState();
    // Generate unique session ID per user+course combination
    sessionId =
        'user_${DateTime.now().millisecondsSinceEpoch}_course_${widget.selectedCourseId}';

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
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
      final response = await http
          .post(
        Uri.parse('$baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'co_id': int.parse(widget.selectedCourseId),
          'session_id': sessionId, // Enable conversation history
          'question': userMessage,
          'language': widget.selectedLanguage == 'مصري' ? 'مصري' : 'English',
        }),
      )
          .timeout(
        const Duration(
            seconds: 35), // 35s to allow for PDF processing on first request
        onTimeout: () {
          throw Exception(
              'Request timeout - server is processing PDFs, please wait...');
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
          if (_messages
              .where((m) => m['sender'] == 'bot' && m['isTyping'] != true)
              .isEmpty) {
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
          errorMessage =
              "Oops! 😅\nSomething went wrong. Please try again in a moment.";
        }

        if (e.toString().contains('timeout')) {
          if (widget.selectedLanguage == 'مصري') {
            errorMessage =
                "استنى شوية يا صاحبي... 🔄\nأول مرة بنحمل المادة دي، ممكن ياخد 30 ثانية. حاول تاني دلوقتي!";
          } else {
            errorMessage =
                "Hold on! 🔄\nFirst time loading this course takes ~30 seconds. Try again now!";
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
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF1c74bb);
    const Color secondaryColor = Color(0xFF165d96);
    const Color accentColor = Color(0xFF18bebc);
    const Color backgroundColor = Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Modern Gradient AppBar
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: primaryColor,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryColor, secondaryColor, accentColor],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 28,
                            backgroundImage:
                                const AssetImage('assets/img/AboLayla.jpg'),
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.selectedLanguage == 'مصري'
                                    ? 'أبو ليلى'
                                    : 'Abo Layla',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  widget.selectedCourse,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: Colors.greenAccent,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.greenAccent
                                              .withOpacity(0.5),
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Online',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 10.5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Messages Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 250,
                ),
                child: _messages.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      primaryColor.withOpacity(0.1),
                                      accentColor.withOpacity(0.1)
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 60,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                widget.selectedLanguage == 'مصري'
                                    ? "إزاي أقدر أساعدك\nفي ${widget.selectedCourse}؟"
                                    : "How can I help you\nwith ${widget.selectedCourse}?",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                widget.selectedLanguage == 'مصري'
                                    ? 'اسأل أي سؤال وأنا هساعدك'
                                    : 'Ask me anything and I\'ll help you',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isUser = message['sender'] == 'user';

                          if (message['isTyping'] == true) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: accentColor.withOpacity(0.3),
                                        width: 2,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 18,
                                      backgroundImage: const AssetImage(
                                          'assets/img/AboLayla.jpg'),
                                      backgroundColor: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const TypingIndicator(),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              mainAxisAlignment: isUser
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!isUser) ...[
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: accentColor.withOpacity(0.3),
                                        width: 2,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 18,
                                      backgroundImage: const AssetImage(
                                          'assets/img/AboLayla.jpg'),
                                      backgroundColor: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                Flexible(
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.75,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      gradient: isUser
                                          ? const LinearGradient(
                                              colors: [
                                                primaryColor,
                                                secondaryColor
                                              ],
                                            )
                                          : null,
                                      color: isUser ? null : Colors.white,
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(20),
                                        topRight: const Radius.circular(20),
                                        bottomLeft:
                                            Radius.circular(isUser ? 20 : 4),
                                        bottomRight:
                                            Radius.circular(isUser ? 4 : 20),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isUser
                                              ? primaryColor.withOpacity(0.3)
                                              : Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: MarkdownBody(
                                      data: message['text']!,
                                      styleSheet: MarkdownStyleSheet(
                                        p: TextStyle(
                                          color: isUser
                                              ? Colors.white
                                              : Colors.black87,
                                          fontSize: 15,
                                          height: 1.4,
                                        ),
                                        code: TextStyle(
                                          color: isUser
                                              ? Colors.white
                                              : Colors.black87,
                                          backgroundColor: isUser
                                              ? Colors.white.withOpacity(0.2)
                                              : Colors.grey.shade100,
                                          fontSize: 14,
                                        ),
                                        strong: TextStyle(
                                          color: isUser
                                              ? Colors.white
                                              : primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
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
            ),
          ),
        ],
      ),

      // Bottom Input Field
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: primaryColor.withOpacity(0.1),
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      maxLines: 5,
                      minLines: 1,
                      textDirection: widget.selectedLanguage == 'مصري'
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      style: widget.selectedLanguage == 'مصري'
                          ? GoogleFonts.cairo(fontSize: 15.0)
                          : const TextStyle(fontSize: 15.0),
                      decoration: InputDecoration(
                        hintText: widget.selectedLanguage == 'مصري'
                            ? 'اكتب رسالتك...'
                            : 'Type your message...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [primaryColor, accentColor],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _sendMessage,
                      customBorder: const CircleBorder(),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
        int dots = 1 + (_dotController.value * (_dotCount - 1)).floor().toInt();
        return Text(
          '.' * dots,
          style: const TextStyle(fontSize: 30, color: Colors.grey),
        );
      },
    );
  }
}
