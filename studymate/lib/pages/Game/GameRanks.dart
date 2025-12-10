import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameRanks extends StatefulWidget {
  const GameRanks({super.key});

  @override
  State<GameRanks> createState() => _GameRanksState();
}

class _GameRanksState extends State<GameRanks> {
  // بيانات الرتب
  final List<Map<String, dynamic>> ranks = [
    {
      'name': 'NewComer',
      'xpRange': '0 to 99 XP',
      'color': const Color(0xFF808080),
      'image': 'assets/img/GameCharacters/NewCommer.png',
    },
    {
      'name': 'Explorer',
      'xpRange': '100 to 299 XP',
      'color': const Color(0xFF007BFF),
      'image': 'assets/img/GameCharacters/Explorer.png',
    },
    {
      'name': 'Achiever',
      'xpRange': '300 to 599 XP',
      'color': const Color(0xFF28A745),
      'image': 'assets/img/GameCharacters/Achiever.png',
    },
    {
      'name': 'Challenger',
      'xpRange': '600 to 999 XP',
      'color': const Color(0xFFFFC107),
      'image': 'assets/img/GameCharacters/Challenger.png',
    },
    {
      'name': 'Expert',
      'xpRange': '1000 to 1499 XP',
      'color': const Color(0xFFFD7E14),
      'image': 'assets/img/GameCharacters/Expert.png',
    },
    {
      'name': 'Mentor',
      'xpRange': '1500 to 2199 XP',
      'color': const Color(0xFF6F42C1),
      'image': 'assets/img/GameCharacters/Mentor.png',
    },
    {
      'name': 'Legend',
      'xpRange': '2200 to 2999 XP',
      'color': const Color(0xFFFFD700),
      'image': 'assets/img/GameCharacters/Legend.png',
    },
    {
      'name': 'El Batal',
      'xpRange': '3000+ XP',
      'color': const Color(0xFFb3141c),
      'image': 'assets/img/GameCharacters/ElBatal.png',
    },
  ];

  // ألوان البراندينج
  final Color blue1 = const Color(0xFF1c74bb);
  final Color blue2 = const Color(0xFF165d96);
  final Color cyan1 = const Color(0xFF18bebc);
  final Color cyan2 = const Color(0xFF139896);
  final Color redAccent = const Color(0xFFb3141c);
  final Color black = const Color(0xFF000000);
  final Color white = const Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    // حجم الشاشة للتصميم المتجاوب
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: black,
      appBar: AppBar(
        backgroundColor: blue2,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Rank List',
          style: GoogleFonts.leagueSpartan(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: white,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // خلفية متحركة أو صورة
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/img/bg7.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // تراكب بلون نصف شفاف لمزيد من الوضوح
          Container(
            color: Colors.black.withOpacity(0.7),
          ),
          // المحتوى الأمامي
          Column(
            children: [
              SizedBox(height: size.height * 0.02),
              Center(
                child: Column(
                  children: [
                    Text(
                      "Achieve greatness as the ultimate Batal",
                      style: GoogleFonts.leagueSpartan(
                        color: redAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: const Offset(2.0, 2.0),
                            blurRadius: 3.0,
                            color: black.withOpacity(0.5),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Stay focused, stay determined",
                      style: GoogleFonts.leagueSpartan(
                        color: white,
                        fontSize: 16,
                        shadows: [
                          Shadow(
                            offset: const Offset(1.0, 1.0),
                            blurRadius: 2.0,
                            color: black.withOpacity(0.5),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.02),
              Expanded(
                child: PageView.builder(
                  itemCount: ranks.length,
                  controller: PageController(viewportFraction: 0.8),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: size.width * 0.02),
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    ranks[index]['color'].withOpacity(0.7),
                                    ranks[index]['color'],
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        ranks[index]['color'].withOpacity(0.5),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(size.width * 0.05),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Image.asset(
                                        ranks[index]['image'],
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    SizedBox(height: size.height * 0.02),
                                    Text(
                                      ranks[index]['name'],
                                      style: GoogleFonts.leagueSpartan(
                                        color: white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                      ),
                                    ),
                                    SizedBox(height: size.height * 0.01),
                                    Text(
                                      ranks[index]['xpRange'],
                                      style: GoogleFonts.leagueSpartan(
                                        color: white.withOpacity(0.8),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.02),
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
