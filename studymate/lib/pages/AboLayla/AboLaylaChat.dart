import 'package:flutter/material.dart';

class AboLaylaChat extends StatefulWidget {
  const AboLaylaChat({super.key});

  @override
  _AboLaylaChatState createState() => _AboLaylaChatState();
}

class _AboLaylaChatState extends State<AboLaylaChat> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final List<String> _responses = [
    "Hello! How can I help you?",
    "I'm here to assist you.",
    "What do you need help with?",
  ];

  void _sendMessage() {
    if (_controller.text.isEmpty) return;

    setState(() {
      // Add user's message
      _messages.add({"sender": "user", "text": _controller.text});
      // Add bot response
      _messages.add({
        "sender": "bot",
        "text": _responses[_messages.length % _responses.length]
      });
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AboLayla Chat'),
      ),
      body: Column(
        children: [
          // Display message when the page is empty
          if (_messages.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "What can I help you with?",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Suggested actions as oblong buttons with icons/emoji
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 30,  // Increased spacing for larger gaps between buttons
                      runSpacing: 20, // Added runSpacing to ensure vertical space
                      children: [
                        _buildSuggestedButton("Create a summary", Icons.article),
                        _buildSuggestedButton("Revise me a topic", Icons.book),
                        _buildSuggestedButton("Brainstorm", Icons.lightbulb),
                        _buildSuggestedButton("Make a plan", Icons.calendar_today), // New button added
                      ],
                    ),
                  ],
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
                        if (!isUser) ...[
                          CircleAvatar(
                            backgroundImage: AssetImage(
                                'assets/img/AboLayla.jpg'), // Replace with your bot icon
                            radius: 16,
                          ),
                          const SizedBox(
                              width:
                                  12), // Added more space between avatar and message bubble
                        ],
                        Flexible(
                          child: Container(
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.7),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: isUser
                                  ? LinearGradient(
                                      colors: [
                                        const Color(0xFF004A61),
                                        const Color(0xFF165D96)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: isUser ? null : Colors.grey[300],
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(12),
                                topRight: const Radius.circular(12),
                                bottomLeft: isUser
                                    ? const Radius.circular(12)
                                    : const Radius.circular(0),
                                bottomRight: isUser
                                    ? const Radius.circular(0)
                                    : const Radius.circular(12),
                              ),
                            ),
                            child: Text(
                              message['text']!,
                              style: TextStyle(
                                color: isUser ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        if (isUser) ...[
                          const SizedBox(
                              width:
                                  12), // Added more space between avatar and message bubble
                          CircleAvatar(
                            backgroundImage: AssetImage(
                                'assets/img/TheRock.jpg'), // Replace with your user icon
                            radius: 16,
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          // Input Field and Send Button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 199, 199, 199),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            maxLines: null, // Allow multiple lines
                            minLines: 1, // Allow at least one line
                            decoration: InputDecoration(
                              hintText: 'Type your message...',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                            ),
                            style: const TextStyle(fontSize: 16),
                            keyboardType: TextInputType.multiline,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: _sendMessage,
                          color: const Color(0xFF004A61),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Method to build suggested buttons
  Widget _buildSuggestedButton(String text, IconData icon) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _messages.add({
            'sender': 'user',
            'text': text,
          });
          _messages.add({
            'sender': 'bot',
            'text': "Sure! I'll help you with: $text",
          });
        });
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        backgroundColor:
            const Color(0xFF165D96), // Use backgroundColor instead of primary
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white), // Icon representing the action
          SizedBox(width: 10), // Spacing between icon and text
          Text(
            text,
            style: TextStyle(
              fontSize: 14, // Same font size for all buttons
              color: Colors.white,
              fontWeight: FontWeight.normal, // Text not bold
            ),
          ),
        ],
      ),
    );
  }
}
