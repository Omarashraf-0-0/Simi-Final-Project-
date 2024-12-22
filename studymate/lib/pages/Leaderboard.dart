import 'package:flutter/material.dart';

void main() {
  runApp(LeaderboardApp());
}

class LeaderboardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LeaderboardPage(),
    );
  }
}

class LeaderboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E2A),
      appBar: AppBar(
        backgroundColor: Color(0xFF1E1E2A),
        elevation: 0,
        title: Text('Leaderboard', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Top 3 Users Section
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Second Place
                _buildTopUser(
                  rank: 2,
                  username: 'Jackson',
                  score: 1847,
                  avatarColor: Colors.blue,
                ),
                // First Place
                _buildTopUser(
                  rank: 1,
                  username: 'Eiden',
                  score: 2430,
                  avatarColor: Colors.amber,
                  isCrownVisible: true,
                ),
                // Third Place
                _buildTopUser(
                  rank: 3,
                  username: 'Emma Aria',
                  score: 1674,
                  avatarColor: Colors.green,
                ),
              ],
            ),
          ),

          // Other Users List
          Expanded(
            child: ListView(
              children: [
                _buildUserTile('Sebastian', 1124, true),
                _buildUserTile('Jason', 875, false),
                _buildUserTile('Natalie', 774, true),
                _buildUserTile('Serenity', 723, true),
                _buildUserTile('Hannah', 559, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopUser({
    required int rank,
    required String username,
    required int score,
    required Color avatarColor,
    bool isCrownVisible = false,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: rank == 1 ? 50 : 40,
              backgroundColor: avatarColor,
              child: CircleAvatar(
                radius: rank == 1 ? 46 : 36,
                backgroundImage: AssetImage('assets/avatar_placeholder.png'), // Replace with actual image path
              ),
            ),
            if (isCrownVisible)
              Positioned(
                top: 0,
                child: Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: 32,
                ),
              ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          username,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        Text(
          score.toString(),
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildUserTile(String username, int score, bool isIncreasing) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage('lib/assets/img/pfp.jpg'), // Replace with actual image path
      ),
      title: Text(
        username,
        style: TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        '@username',
        style: TextStyle(color: Colors.white70),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            score.toString(),
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(width: 8),
          Icon(
            isIncreasing ? Icons.arrow_upward : Icons.arrow_downward,
            color: isIncreasing ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }
}
