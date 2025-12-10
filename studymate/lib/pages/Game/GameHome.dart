import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'GameRanks.dart';

class GameHome extends StatefulWidget {
  const GameHome({super.key});

  @override
  State<GameHome> createState() => _GameHomeState();
}

class _GameHomeState extends State<GameHome> {
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
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'El Batal Game',
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
                image: AssetImage('lib/assets/img/bg5.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // تراكب بلون نصف شفاف لمزيد من الوضوح
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          // المحتوى الأمامي
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // عنوان الترحيب
                Text(
                  'Welcome to',
                  style: GoogleFonts.leagueSpartan(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: white,
                  ),
                ),
                Text(
                  'El Batal Gamification',
                  style: GoogleFonts.leagueSpartan(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: redAccent,
                    shadows: [
                      Shadow(
                        offset: Offset(2.0, 2.0),
                        blurRadius: 4.0,
                        color: black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.04),
                // صورة الشخصية أو اللعبة
                Center(
                  child: Container(
                    width: size.width * 0.8,
                    height: size.height * 0.4,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                            'lib/assets/img/GameCharacters/ElBatal.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.04),
                // زر "Explore"
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GameRanks()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: redAccent,
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      'Explore',
                      style: GoogleFonts.leagueSpartan(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: white,
                      ),
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
}
