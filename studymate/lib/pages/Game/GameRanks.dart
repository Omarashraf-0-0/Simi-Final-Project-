import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../theme/app_constants.dart';

class GameRanks extends StatefulWidget {
  const GameRanks({super.key});

  @override
  State<GameRanks> createState() => _GameRanksState();
}

class _GameRanksState extends State<GameRanks> with TickerProviderStateMixin {
  late AnimationController _pageController;
  late AnimationController _sparkleController;
  int currentPage = 0;

  // بيانات الرتب
  final List<Map<String, dynamic>> ranks = [
    {
      'name': 'NewComer',
      'xpRange': '0 - 149 XP',
      'color': const Color(0xFF808080),
      'image': 'assets/img/GameCharacters/NewCommer.png',
      'description': 'Begin your journey',
      'icon': Icons.rocket_launch_rounded,
    },
    {
      'name': 'Explorer',
      'xpRange': '150 - 349 XP',
      'color': const Color(0xFF007BFF),
      'image': 'assets/img/GameCharacters/Explorer.png',
      'description': 'Discover new paths',
      'icon': Icons.explore_rounded,
    },
    {
      'name': 'Achiever',
      'xpRange': '350 - 649 XP',
      'color': const Color(0xFF28A745),
      'image': 'assets/img/GameCharacters/Achiever.png',
      'description': 'Unlock achievements',
      'icon': Icons.emoji_events_rounded,
    },
    {
      'name': 'Challenger',
      'xpRange': '650 - 1099 XP',
      'color': const Color(0xFFFFC107),
      'image': 'assets/img/GameCharacters/Challenger.png',
      'description': 'Face the challenge',
      'icon': Icons.bolt_rounded,
    },
    {
      'name': 'Expert',
      'xpRange': '1100 - 1699 XP',
      'color': const Color(0xFFFD7E14),
      'image': 'assets/img/GameCharacters/Expert.png',
      'description': 'Master your skills',
      'icon': Icons.auto_awesome_rounded,
    },
    {
      'name': 'Mentor',
      'xpRange': '1700 - 2499 XP',
      'color': const Color(0xFF6F42C1),
      'image': 'assets/img/GameCharacters/Mentor.png',
      'description': 'Guide others',
      'icon': Icons.school_rounded,
    },
    {
      'name': 'Legend',
      'xpRange': '2500 - 3499 XP',
      'color': const Color(0xFFFFD700),
      'image': 'assets/img/GameCharacters/Legend.png',
      'description': 'Become legendary',
      'icon': Icons.stars_rounded,
    },
    {
      'name': 'El Batal',
      'xpRange': '3500+ XP',
      'color': const Color(0xFFb3141c),
      'image': 'assets/img/GameCharacters/ElBatal.png',
      'description': 'The Ultimate Hero',
      'icon': Icons.military_tech_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();

    _pageController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    // Get current user rank and navigate to it
    _navigateToCurrentRank();
  }

  String _calculateRankFromXP(int xp) {
    if (xp >= 3500) {
      return 'El Batal';
    } else if (xp >= 2500) {
      return 'Legend';
    } else if (xp >= 1700) {
      return 'Mentor';
    } else if (xp >= 1100) {
      return 'Expert';
    } else if (xp >= 650) {
      return 'Challenger';
    } else if (xp >= 350) {
      return 'Achiever';
    } else if (xp >= 150) {
      return 'Explorer';
    } else {
      return 'NewComer';
    }
  }

  void _navigateToCurrentRank() {
    final userBox = Hive.box('userBox');
    final userXp = userBox.get('xp', defaultValue: 0);
    final userTitle = _calculateRankFromXP(userXp);

    final rankIndex = ranks.indexWhere((rank) => rank['name'] == userTitle);
    if (rankIndex != -1) {
      setState(() {
        currentPage = rankIndex;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final userBox = Hive.box('userBox');
    final userXp = userBox.get('xp', defaultValue: 0);
    final userTitle = _calculateRankFromXP(userXp);

    return Scaffold(
      backgroundColor: const Color(0xFF0a0e27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0a0e27),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppConstants.textOnDark,
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              AppConstants.primaryCyan,
              AppConstants.primaryBlue,
              AppConstants.rankLegend,
            ],
          ).createShader(bounds),
          child: Text(
            'RANK SYSTEM',
            style: GoogleFonts.leagueSpartan(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // خلفية متدرجة gaming
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0a0e27),
                  const Color(0xFF1a1f3a),
                  const Color(0xFF0a0e27),
                ],
              ),
            ),
          ),

          // Animated particles
          ...List.generate(20, (index) {
            return Positioned(
              left: (index * 67.3) % size.width,
              top: (index * 89.7) % size.height,
              child: AnimatedBuilder(
                animation: _sparkleController,
                builder: (context, child) {
                  return Opacity(
                    opacity:
                        ((_sparkleController.value + (index * 0.1)) % 1.0) *
                            0.5,
                    child: Container(
                      width: 3 + (index % 3),
                      height: 3 + (index % 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ranks[currentPage]['color'],
                        boxShadow: [
                          BoxShadow(
                            color: ranks[currentPage]['color'],
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }),

          SafeArea(
            child: Column(
              children: [
                SizedBox(height: size.height * 0.02),

                // Header مع معلومات الرتبة الحالية
                Container(
                  margin: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ranks[currentPage]['color'].withOpacity(0.3),
                        ranks[currentPage]['color'].withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: ranks[currentPage]['color'].withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ranks[currentPage]['color'].withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            ranks[currentPage]['icon'],
                            color: ranks[currentPage]['color'],
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Your Current Rank',
                            style: GoogleFonts.leagueSpartan(
                              color: AppConstants.textOnDark.withOpacity(0.8),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ranks[currentPage]['color'],
                              ranks[currentPage]['color'].withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  ranks[currentPage]['color'].withOpacity(0.5),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Text(
                          userTitle,
                          style: GoogleFonts.leagueSpartan(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ranks[currentPage]['description'],
                        style: GoogleFonts.leagueSpartan(
                          color: ranks[currentPage]['color'],
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: size.height * 0.03),

                // العنوان
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppConstants.primaryCyan,
                              AppConstants.primaryBlue,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'ALL RANKS',
                        style: GoogleFonts.leagueSpartan(
                          color: AppConstants.textOnDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${currentPage + 1}/${ranks.length}',
                        style: GoogleFonts.leagueSpartan(
                          color: ranks[currentPage]['color'],
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: size.height * 0.02),

                // PageView للرتب
                Expanded(
                  child: PageView.builder(
                    itemCount: ranks.length,
                    controller: PageController(
                      viewportFraction: 0.85,
                      initialPage: currentPage,
                    ),
                    onPageChanged: (index) {
                      setState(() {
                        currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final isCurrentUserRank =
                          ranks[index]['name'] == userTitle;

                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: currentPage == index ? 1.0 : 0.9,
                            child: Opacity(
                              opacity: currentPage == index ? 1.0 : 0.6,
                              child: _buildRankCard(
                                context: context,
                                rank: ranks[index],
                                size: size,
                                isCurrentUserRank: isCurrentUserRank,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                SizedBox(height: size.height * 0.02),

                // Page indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(ranks.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: currentPage == index
                            ? ranks[index]['color']
                            : Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: currentPage == index
                            ? [
                                BoxShadow(
                                  color: ranks[index]['color'].withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : [],
                      ),
                    );
                  }),
                ),

                SizedBox(height: size.height * 0.03),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankCard({
    required BuildContext context,
    required Map<String, dynamic> rank,
    required Size size,
    required bool isCurrentUserRank,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: rank['color'].withOpacity(0.4),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          // الكارت الرئيسي
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  rank['color'].withOpacity(0.9),
                  rank['color'],
                  rank['color'].withOpacity(0.8),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Stack(
                children: [
                  // Pattern overlay
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.1,
                      child: Image.asset(
                        'assets/img/bg7.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container();
                        },
                      ),
                    ),
                  ),

                  // المحتوى
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // الأيقونة في الأعلى
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            rank['icon'],
                            color: Colors.white,
                            size: 32,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // صورة الشخصية
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              rank['image'],
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                print('Failed to load image: ${rank['image']}');
                                print('Error: $error');
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      rank['icon'],
                                      color: Colors.white,
                                      size: 100,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Image not found',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // اسم الرتبة
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                rank['name'],
                                style: GoogleFonts.leagueSpartan(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 28,
                                  letterSpacing: 2,
                                  shadows: [
                                    Shadow(
                                      offset: const Offset(0, 2),
                                      blurRadius: 8,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.stars_rounded,
                                    color: Colors.white.withOpacity(0.9),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    rank['xpRange'],
                                    style: GoogleFonts.leagueSpartan(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                rank['description'],
                                style: GoogleFonts.leagueSpartan(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // بادج "Your Rank" إذا كانت رتبة المستخدم
          if (isCurrentUserRank)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppConstants.primaryCyan,
                      AppConstants.primaryBlue,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.primaryBlue.withOpacity(0.4),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'YOUR RANK',
                      style: GoogleFonts.leagueSpartan(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
