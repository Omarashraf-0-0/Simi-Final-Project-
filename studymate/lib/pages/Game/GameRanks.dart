import 'package:flutter/material.dart';

class GameRanks extends StatefulWidget {
  const GameRanks({super.key});

  @override
  State<GameRanks> createState() => _GameRanksState();
}

class _GameRanksState extends State<GameRanks> {
  final List<Map<String, dynamic>> ranks = [
    {
      'name': 'NewComer',
      'xpRange': '0 to 99 XP',
      'color': Color(0xFF808080),
      'image': 'lib/assets/img/GameCharacters/NewCommer.png',
    },
    {
      'name': 'Explorer',
      'xpRange': '100 to 299 XP',
      'color': Color(0xFF007BFF),
      'image': 'lib/assets/img/GameCharacters/Explorer.png',
    },
    {
      'name': 'Achiever',
      'xpRange': '300 to 599 XP',
      'color': Color(0xFF28A745),
      'image': 'lib/assets/img/GameCharacters/Achiever.png',
    },
    {
      'name': 'Challenger',
      'xpRange': '600 to 999 XP',
      'color': Color(0xFFFFC107),
      'image': 'lib/assets/img/GameCharacters/Challenger.png',
    },
    {
      'name': 'Expert',
      'xpRange': '1000 to 1499 XP',
      'color': Color(0xFFFD7E14),
      'image': 'lib/assets/img/GameCharacters/Expert.png',
    },
    {
      'name': 'Mentor',
      'xpRange': '1500 to 2199 XP',
      'color': Color(0xFF6F42C1),
      'image': 'lib/assets/img/GameCharacters/Mentor.png',
    },
    {
      'name': 'Legend',
      'xpRange': '2200 to 2999 XP',
      'color': Color(0xFFFFD700),
      'image': 'lib/assets/img/GameCharacters/Legend.png',
    },
    {
      'name': 'El Batal',
      'xpRange': '3000+ XP',
      'color': Color(0xFFb3141c),
      'image': 'lib/assets/img/GameCharacters/ElBatal.png',
    },
    
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1C1C2B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF165D96),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Rank List',
          style: TextStyle(
            fontFamily: 'League Spartan',
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background with gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 0, 25, 45),
                  Color(0xFF30457A),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Text(
                      "Achieve greatness as the ultimate Batal",
                      style: TextStyle(
                        fontFamily: 'League Spartan',
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(2.0, 2.0),
                            blurRadius: 3.0,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Stay focused, stay determined",
                      style: TextStyle(
                        fontFamily: 'League Spartan',
                        color: Colors.white,
                        fontSize: 16,
                        shadows: [
                          Shadow(
                            offset: Offset(1.0, 1.0),
                            blurRadius: 2.0,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: PageView.builder(
                  itemCount: ranks.length,
                  controller: PageController(viewportFraction: 0.9),
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    ranks[index]['color'].withOpacity(0.5),
                                    ranks[index]['color'],
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: ranks[index]['color'].withOpacity(0.5),
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Image.asset(
                                  ranks[index]['image'],
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 65, vertical: 10),
                            decoration: BoxDecoration(
                              color: ranks[index]['color'].withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: ranks[index]['color'].withOpacity(0.5),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  ranks[index]['name'],
                                  style: TextStyle(
                                    fontFamily: 'League Spartan',
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  ranks[index]['xpRange'],
                                  style: TextStyle(
                                    fontFamily: 'League Spartan',
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}