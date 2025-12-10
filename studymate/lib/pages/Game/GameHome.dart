import 'package:flutter/material.dart';
import 'GameRanks.dart';
import '../../theme/app_constants.dart';

class GameHome extends StatefulWidget {
  const GameHome({super.key});

  @override
  State<GameHome> createState() => _GameHomeState();
}

class _GameHomeState extends State<GameHome> {
  @override
  Widget build(BuildContext context) {
    // حجم الشاشة للتصميم المتجاوب
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppConstants.backgroundDark,
      appBar: AppConstants.buildAppBar(
        title: 'El Batal Game',
        leading: AppConstants.buildBackButton(context),
      ),
      body: Stack(
        children: [
          // خلفية متحركة أو صورة
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/img/bg5.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // تراكب بلون نصف شفاف لمزيد من الوضوح
          Container(
            color: AppConstants.backgroundDark.withOpacity(0.5),
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
                  style: AppConstants.pageTitle.copyWith(
                    color: AppConstants.textOnDark,
                  ),
                ),
                Text(
                  'El Batal Gamification',
                  style: AppConstants.pageTitle.copyWith(
                    fontSize: AppConstants.fontSizeXXL + 4,
                    color: AppConstants.rankElBatal,
                    shadows: [
                      Shadow(
                        offset: const Offset(2.0, 2.0),
                        blurRadius: 4.0,
                        color: AppConstants.backgroundDark.withOpacity(0.5),
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
                            'assets/img/GameCharacters/ElBatal.png'),
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
                      backgroundColor: AppConstants.rankElBatal,
                      padding: EdgeInsets.symmetric(
                        vertical: AppConstants.spacingM,
                        horizontal:
                            AppConstants.spacingXXL + AppConstants.spacingS,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusXL + 6),
                      ),
                      elevation: AppConstants.elevationM,
                    ),
                    child: Text(
                      'Explore',
                      style: AppConstants.cardTitle.copyWith(
                        color: AppConstants.textOnDark,
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
