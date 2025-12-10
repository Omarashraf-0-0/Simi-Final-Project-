import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import '../../theme/app_constants.dart';

class GameLeaderBoard extends StatefulWidget {
  const GameLeaderBoard({super.key});

  @override
  State<GameLeaderBoard> createState() => _GameLeaderBoardState();
}

class _GameLeaderBoardState extends State<GameLeaderBoard> {
  List<Map<String, dynamic>> users = [];
  Map<String, dynamic>? currentUser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    const url =
        'https://alyibrahim.pythonanywhere.com/get_users'; // Replace with your actual Flask server URL

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        users = jsonResponse.cast<Map<String, dynamic>>();

        // Fetch current user from Hive
        final userBox = Hive.box('userBox');
        final currentUserData = userBox.isNotEmpty
            ? userBox.toMap()
            : {'username': '', 'xp': 0, 'title': 'NewComer', 'pfp': ''};

        currentUser = {
          'username': currentUserData['username'],
          'xp': currentUserData['xp'],
          'title': currentUserData['title'],
          'pfp': currentUserData['pfp'],
        };

        // Sort users by XP and then alphabetically if XP is equal
        users.sort((a, b) {
          int xpComparison = b['xp'].compareTo(a['xp']);
          if (xpComparison != 0) {
            return xpComparison;
          } else {
            return a['username'].compareTo(b['username']);
          }
        });

        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load users');
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Helper function to get ImageProvider from base64 string
  ImageProvider<Object> getImageProvider(String? base64String) {
    if (base64String != null && base64String.isNotEmpty) {
      try {
        Uint8List imageBytes = base64Decode(base64String);
        return MemoryImage(imageBytes);
      } catch (e) {
        // Handle the exception as needed
        print('Error decoding base64 image: $e');
        return AssetImage('assets/img/default.jpeg');
      }
    } else {
      return AssetImage('assets/img/default.jpeg');
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
      backgroundColor: AppConstants.backgroundDarkCard,
      appBar: AppConstants.buildAppBar(
        title: 'Leaderboard',
        leading: AppConstants.buildBackButton(context),
        backgroundColor: AppConstants.backgroundDarkCard,
        centerTitle: true,
      ),
      body: isLoading
          ? AppConstants.buildLoadingIndicator()
          : Column(
              children: [
                // Top 3 Users Section
                if (topTenUsers.length >= 3)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Second Place
                        _buildTopUser(
                          rank: 2,
                          user: topTenUsers[1],
                          isCrownVisible: false,
                        ),
                        // First Place
                        _buildTopUser(
                          rank: 1,
                          user: topTenUsers[0],
                          isCrownVisible: true,
                        ),
                        // Third Place
                        _buildTopUser(
                          rank: 3,
                          user: topTenUsers[2],
                          isCrownVisible: false,
                        ),
                      ],
                    ),
                  ),
                // Users List
                Expanded(
                  child: ListView.builder(
                    itemCount: topTenUsers.length - 3,
                    itemBuilder: (context, index) {
                      final user = topTenUsers[index + 3];
                      final rank = index + 4;
                      final isCurrentUser =
                          user['username'] == currentUser?['username'];

                      return _buildUserTile(
                        rank: rank,
                        user: user,
                        isCurrentUser: isCurrentUser,
                      );
                    },
                  ),
                ),
                if (!isCurrentUserInTopTen && currentUserRank > 0)
                  _buildUserTile(
                    rank: currentUserRank,
                    user: currentUser!,
                    isCurrentUser: true,
                  ),
              ],
            ),
    );
  }

  Widget _buildTopUser({
    required int rank,
    required Map<String, dynamic> user,
    bool isCrownVisible = false,
  }) {
    final rankColor = _getRankColor(user['title']);
    final avatarRadius = rank == 1 ? 50.0 : 40.0;
    IconData? rankIcon;
    Color? iconColor;

    if (rank == 1) {
      rankIcon = Icons.emoji_events;
      iconColor = Colors.amber;
    } else if (rank == 2) {
      rankIcon = Icons.military_tech;
      iconColor = Colors.grey[350];
    } else if (rank == 3) {
      rankIcon = Icons.military_tech;
      iconColor = const Color(0xFFCD7F32); // Bronze color
    }

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: avatarRadius,
              backgroundColor: rankColor,
              child: CircleAvatar(
                radius: avatarRadius - 4,
                backgroundImage: getImageProvider(user['pfp']),
              ),
            ),
            if (rankIcon != null)
              Positioned(
                top: 0,
                child: Icon(
                  rankIcon,
                  color: iconColor,
                  size: 32,
                ),
              ),
          ],
        ),
        SizedBox(height: AppConstants.spacingXS),
        Text(
          user['username'],
          style: AppConstants.bodyText.copyWith(
            color: rankColor,
            fontWeight: AppConstants.fontWeightBold,
          ),
        ),
        Text(
          'XP: ${user['xp']}',
          style: AppConstants.smallText.copyWith(
            color: AppConstants.textOnDark.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildUserTile({
    required int rank,
    required Map<String, dynamic> user,
    required bool isCurrentUser,
  }) {
    final rankColor = _getRankColor(user['title']);

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: getImageProvider(user['pfp']),
      ),
      title: Text(
        user['username'],
        style: AppConstants.bodyText.copyWith(color: rankColor),
      ),
      subtitle: Text(
        'Title: ${user['title']}',
        style: AppConstants.smallText.copyWith(
          color: AppConstants.textOnDark.withOpacity(0.7),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'XP: ${user['xp']}',
            style: AppConstants.bodyText.copyWith(
              color: AppConstants.textOnDark,
            ),
          ),
          SizedBox(width: AppConstants.spacingXS),
          Text(
            '#$rank',
            style: AppConstants.subtitle.copyWith(
              fontWeight: AppConstants.fontWeightBold,
              color: rankColor,
            ),
          ),
        ],
      ),
      tileColor:
          isCurrentUser ? AppConstants.primaryBlue.withOpacity(0.3) : null,
    );
  }
}
