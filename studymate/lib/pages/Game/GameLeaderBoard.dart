import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import '../../theme/app_constants.dart';

class GameLeaderBoard extends StatefulWidget {
  const GameLeaderBoard({super.key});

  @override
  State<GameLeaderBoard> createState() => _GameLeaderBoardState();
}

class _GameLeaderBoardState extends State<GameLeaderBoard>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> users = [];
  Map<String, dynamic>? currentUser;
  bool isLoading = true;
  late AnimationController _sparkleController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _fetchUsers();
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    const url = 'https://alyibrahim.pythonanywhere.com/get_users';

    try {
      // Add timeout for faster failure
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        // Parse response
        final List<dynamic> jsonResponse = jsonDecode(response.body);

        // Get current user from Hive first (faster)
        final userBox = Hive.box('userBox');
        final username = userBox.get('username', defaultValue: '');
        final xp = userBox.get('xp', defaultValue: 0);
        final title = userBox.get('title', defaultValue: 'NewComer');
        final pfp = userBox.get('pfp', defaultValue: '');

        currentUser = {
          'username': username,
          'xp': xp,
          'title': title,
          'pfp': pfp,
        };

        // Process users list
        users = jsonResponse.cast<Map<String, dynamic>>();

        // Sort by XP (simplified)
        users.sort((a, b) => b['xp'].compareTo(a['xp']));

        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load users');
      }
    } catch (error) {
      print('Error fetching users: $error');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Helper function to get ImageProvider from base64 string (optimized)
  ImageProvider<Object> getImageProvider(String? base64String) {
    if (base64String != null && base64String.isNotEmpty) {
      try {
        final imageBytes = base64Decode(base64String);
        return MemoryImage(imageBytes);
      } catch (e) {
        return const AssetImage('assets/img/default.jpeg');
      }
    }
    return const AssetImage('assets/img/default.jpeg');
  }

  // Calculate rank dynamically based on XP (matches updated system)
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

  Color _getRankColor(String rank) {
    switch (rank) {
      case 'El Batal':
        return AppConstants.rankElBatal;
      case 'Legend':
        return AppConstants.rankLegend;
      case 'Mentor':
        return AppConstants.rankMentor;
      case 'Expert':
        return AppConstants.rankExpert;
      case 'Challenger':
        return AppConstants.rankChallenger;
      case 'Achiever':
        return AppConstants.rankAchiever;
      case 'Explorer':
        return AppConstants.rankExplorer;
      case 'NewComer':
        return AppConstants.rankNewComer;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    List<Map<String, dynamic>> topTenUsers = [];
    int currentUserRank = users.indexWhere(
            (user) => user['username'] == currentUser?['username']) +
        1;

    if (users.length > 10) {
      topTenUsers = users.sublist(0, 10);
    } else {
      topTenUsers = users;
    }

    bool isCurrentUserInTopTen = currentUserRank > 0 && currentUserRank <= 10;

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
              AppConstants.rankLegend,
              AppConstants.primaryCyan,
              AppConstants.primaryBlue,
            ],
          ).createShader(bounds),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.leaderboard_rounded,
                  color: Colors.white, size: 28),
              const SizedBox(width: 8),
              Text(
                'LEADERBOARD',
                style: AppConstants.pageTitle.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppConstants.primaryBlue,
                          AppConstants.primaryCyan,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppConstants.primaryBlue.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Loading Champions...',
                    style: AppConstants.bodyText.copyWith(
                      color: AppConstants.textOnDark,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                // Animated background particles (optimized)
                ...List.generate(12, (index) {
                  return Positioned(
                    left: (index * 71.3) % size.width,
                    top: (index * 93.7) % size.height,
                    child: AnimatedBuilder(
                      animation: _sparkleController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: ((_sparkleController.value + (index * 0.1)) %
                                  1.0) *
                              0.3,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppConstants.primaryCyan.withOpacity(0.6),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),

                // Main content (scrollable)
                CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Header Stats
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppConstants.primaryBlue.withOpacity(0.3),
                              AppConstants.primaryCyan.withOpacity(0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppConstants.primaryCyan.withOpacity(0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppConstants.primaryBlue.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              icon: Icons.people_rounded,
                              label: 'Total Players',
                              value: '${users.length}',
                              color: AppConstants.primaryCyan,
                            ),
                            Container(
                              width: 2,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    AppConstants.primaryCyan.withOpacity(0.5),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            _buildStatItem(
                              icon: Icons.military_tech_rounded,
                              label: 'Your Rank',
                              value: currentUserRank > 0
                                  ? '#$currentUserRank'
                                  : 'N/A',
                              color: _getRankColor(
                                  currentUser?['title'] ?? 'NewComer'),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Top 3 Podium
                    if (topTenUsers.length >= 3)
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: AppConstants.rankLegend.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.emoji_events_rounded,
                                    color: AppConstants.rankLegend,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'TOP CHAMPIONS',
                                    style: AppConstants.cardTitle.copyWith(
                                      color: AppConstants.textOnDark,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Second Place
                                  _buildPodiumUser(
                                    rank: 2,
                                    user: topTenUsers[1],
                                    height: 140,
                                  ),
                                  const SizedBox(width: 12),
                                  // First Place (Highest)
                                  _buildPodiumUser(
                                    rank: 1,
                                    user: topTenUsers[0],
                                    height: 180,
                                  ),
                                  const SizedBox(width: 12),
                                  // Third Place
                                  _buildPodiumUser(
                                    rank: 3,
                                    user: topTenUsers[2],
                                    height: 120,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SliverToBoxAdapter(
                      child: SizedBox(height: 16),
                    ),

                    // Other players header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 20,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
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
                              'OTHER PLAYERS',
                              style: AppConstants.cardTitle.copyWith(
                                color: AppConstants.textOnDark.withOpacity(0.8),
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(
                      child: SizedBox(height: 12),
                    ),

                    // Users List (optimized with cacheExtent)
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final user = topTenUsers[index + 3];
                          final rank = index + 4;
                          final isCurrentUser =
                              user['username'] == currentUser?['username'];

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _buildModernUserTile(
                              rank: rank,
                              user: user,
                              isCurrentUser: isCurrentUser,
                            ),
                          );
                        },
                        childCount:
                            topTenUsers.length > 3 ? topTenUsers.length - 3 : 0,
                        addAutomaticKeepAlives: false,
                        addRepaintBoundaries: true,
                      ),
                    ),

                    // Current user card if not in top 10
                    if (!isCurrentUserInTopTen && currentUserRank > 0)
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppConstants.primaryBlue.withOpacity(0.4),
                                AppConstants.primaryCyan.withOpacity(0.3),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppConstants.primaryCyan,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppConstants.primaryBlue.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: _buildModernUserTile(
                            rank: currentUserRank,
                            user: currentUser!,
                            isCurrentUser: true,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppConstants.cardTitle.copyWith(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppConstants.smallText.copyWith(
            color: AppConstants.textOnDark.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPodiumUser({
    required int rank,
    required Map<String, dynamic> user,
    required double height,
  }) {
    final userRank = _calculateRankFromXP(user['xp']);
    final rankColor = _getRankColor(userRank);
    Color podiumColor;
    IconData medalIcon;
    Color medalColor;

    if (rank == 1) {
      podiumColor = const Color(0xFFFFD700); // Gold
      medalIcon = Icons.emoji_events_rounded;
      medalColor = const Color(0xFFFFD700);
    } else if (rank == 2) {
      podiumColor = const Color(0xFFC0C0C0); // Silver
      medalIcon = Icons.military_tech_rounded;
      medalColor = const Color(0xFFC0C0C0);
    } else {
      podiumColor = const Color(0xFFCD7F32); // Bronze
      medalIcon = Icons.military_tech_rounded;
      medalColor = const Color(0xFFCD7F32);
    }

    return Column(
      children: [
        // Avatar with glow
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: rankColor.withOpacity(0.6),
                    blurRadius: rank == 1 ? 25 : 15,
                    spreadRadius: rank == 1 ? 8 : 4,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: rank == 1 ? 45 : 38,
                backgroundColor: rankColor,
                child: CircleAvatar(
                  radius: rank == 1 ? 42 : 35,
                  backgroundImage: getImageProvider(user['pfp']),
                ),
              ),
            ),
            // Medal badge
            Positioned(
              top: -5,
              right: -5,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale:
                        rank == 1 ? 1.0 + (_pulseController.value * 0.1) : 1.0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: medalColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: medalColor.withOpacity(0.6),
                            blurRadius: 12,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Icon(
                        medalIcon,
                        color: Colors.white,
                        size: rank == 1 ? 24 : 20,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Username
        SizedBox(
          width: 90,
          child: Text(
            user['username'],
            style: AppConstants.bodyText.copyWith(
              color: rankColor,
              fontWeight: FontWeight.w900,
              fontSize: rank == 1 ? 16 : 14,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 4),
        // XP with icon
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: rankColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: rankColor.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.stars_rounded,
                color: rankColor,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                '${user['xp']}',
                style: AppConstants.smallText.copyWith(
                  color: rankColor,
                  fontWeight: FontWeight.bold,
                  fontSize: rank == 1 ? 13 : 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Podium base
        Container(
          width: 90,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                podiumColor.withOpacity(0.8),
                podiumColor.withOpacity(0.5),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            border: Border.all(
              color: podiumColor.withOpacity(0.8),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: podiumColor.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '#$rank',
                style: AppConstants.pageTitle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: rank == 1 ? 32 : 26,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernUserTile({
    required int rank,
    required Map<String, dynamic> user,
    required bool isCurrentUser,
  }) {
    final userRank = _calculateRankFromXP(user['xp']);
    final rankColor = _getRankColor(userRank);

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: isCurrentUser
                ? [
                    AppConstants.primaryBlue.withOpacity(0.3),
                    AppConstants.primaryCyan.withOpacity(0.2),
                  ]
                : [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.1),
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCurrentUser
                ? AppConstants.primaryCyan.withOpacity(0.5)
                : rankColor.withOpacity(0.3),
            width: isCurrentUser ? 2 : 1,
          ),
          boxShadow: isCurrentUser
              ? [
                  BoxShadow(
                    color: AppConstants.primaryBlue.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Rank number
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      rankColor,
                      rankColor.withOpacity(0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: rankColor.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '#$rank',
                    style: AppConstants.bodyText.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: rankColor,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: rankColor.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundImage: getImageProvider(user['pfp']),
                ),
              ),
            ],
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  user['username'],
                  style: AppConstants.bodyText.copyWith(
                    color: isCurrentUser ? AppConstants.primaryCyan : rankColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isCurrentUser)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppConstants.primaryCyan,
                        AppConstants.primaryBlue,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'YOU',
                        style: AppConstants.smallText.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          subtitle: Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: rankColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.military_tech_rounded,
                  color: rankColor,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  userRank,
                  style: AppConstants.smallText.copyWith(
                    color: rankColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  rankColor.withOpacity(0.3),
                  rankColor.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: rankColor.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.stars_rounded,
                  color: rankColor,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  '${user['xp']}',
                  style: AppConstants.bodyText.copyWith(
                    color: rankColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
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
