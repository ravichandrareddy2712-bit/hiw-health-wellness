import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../avatar/avatar_store.dart'; // 🔔
import 'profile_screen.dart'; 
import 'update_log_screen.dart'; // 🆕 Full screen log
import '../widgets/dev_theme_tools.dart'; 

enum AvatarStage { unhealthy, normal, healthy, veryHealthy }

class AvatarScreen extends StatelessWidget {
  final double healthPercent;        // weekly finalized
  final double energyPercent;        // weekly finalized
  final double staminaPercent;       // 🆕 daily preview stamina

  const AvatarScreen({
    super.key,
    required this.healthPercent,
    required this.energyPercent,
    required this.staminaPercent,
  });

  AvatarStage _stage(double p) {
    if (p >= 80) return AvatarStage.veryHealthy;
    if (p >= 60) return AvatarStage.healthy;
    if (p >= 40) return AvatarStage.normal;
    return AvatarStage.unhealthy;
  }

  @override
  Widget build(BuildContext context) {
    // 🔔 LISTEN TO AVATAR STORE LIVE
    return AnimatedBuilder(
      animation: AvatarStore(),
      builder: (context, _) {
        final store = AvatarStore();
        final currentHealth = store.avatar.health;
        final currentEnergy = store.avatar.energy;
        final currentStamina = store.dailyStaminaPreview; // preview is the live one

        final stage = _stage(currentHealth);

        return Stack(
          children: [
            // CONTD: EXISTING LISTVIEW
            ListView(
              padding: EdgeInsets.all(16.r),
              children: [
                SizedBox(height: 40.h), // Space for top buttons
                
                // -------------------------
                // AVATAR CARD
                // -------------------------
                Center(
                  child: Container(
                    width: 200.w,
                    height: 240.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      gradient: _gradient(stage),
                      border: Border.all(
                        color: Colors.tealAccent.withOpacity(0.8),
                        width: 2.w,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '3D Avatar\nplaceholder',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                // -------------------------
                // STATS
                // -------------------------
                _statRow(context, 'Health ', currentHealth),
                _statRow(context, 'Energy ', currentEnergy),
                _statRow(context, 'Stamina ', currentStamina), // 🆕

                SizedBox(height: 12.h),

                Center(
                  child: Text(
                    'Stage: ${stage.name.toUpperCase()}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    ),
                  ),
                ),

            SizedBox(height: 28.h),

            // -------------------------
            // 🎮 GAME ACCESS (TESTER MODE)
            // -------------------------
            Center(
              child: Column(
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.sports_esports),
                    label: Text('Enter Gaming World'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      backgroundColor: Colors.tealAccent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GamingWorldScreen(),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 10.h),

                  // 🔒 OFFICIAL RULE NOTE
                  Text(
                    'ℹ️ Official game unlock: Every Saturday at 4:00 PM\n'
                    '(Tester access currently enabled)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 12.sp,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  SizedBox(height: 25.h),

                  // 🚀 UPDATE LOG BUTTON (NEW)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const UpdateLogScreen()),
                      );
                    },
                    icon: Icon(Icons.history_edu, color: Colors.white),
                    label: Text(
                      'View Update Log',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12.h),
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
            // ⚙️ SETTINGS / PROFILE BUTTON (Top Right)
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: Icon(Icons.settings, color: Theme.of(context).iconTheme.color, size: 28),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
              ),
            ),
            
            // 🎨 DEV TOOLS BUTTON (Top Left)
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon: Icon(Icons.palette, color: Theme.of(context).iconTheme.color, size: 28),
                onPressed: () => showDevThemeTools(context),
              ),
            ),
          ],
        );
      },
    );
  }



  // -------------------------
  // GRADIENT BY STAGE
  // -------------------------
  Gradient _gradient(AvatarStage s) {
    switch (s) {
      case AvatarStage.unhealthy:
        return const LinearGradient(
          colors: [Colors.grey, Colors.red],
        );
      case AvatarStage.normal:
        return const LinearGradient(
          colors: [Colors.blueGrey, Colors.green],
        );
      case AvatarStage.healthy:
        return const LinearGradient(
          colors: [Colors.green, Colors.teal],
        );
      case AvatarStage.veryHealthy:
        return const LinearGradient(
          colors: [Colors.teal, Colors.lightGreenAccent],
        );
    }
  }

  // -------------------------
  // STAT ROW
  // -------------------------
  Widget _statRow(BuildContext context, String label, double value) {
    return Padding(

      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          SizedBox(
            width: 110.w,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999.r),
              child: LinearProgressIndicator(
                value: (value / 100).clamp(0, 1),
                minHeight: 10,
                backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white12 : Colors.black.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            '${value.toStringAsFixed(0)}%',
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
        ],
      ),
    );
  }
}

// -------------------------
// 🎮 PLACEHOLDER GAME WORLD
// -------------------------
class GamingWorldScreen extends StatelessWidget {
  const GamingWorldScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gaming World')),
      body: Center(
        child: Text(
          '🎮 Gaming World\n\n'
          'CURRENTLY UNDER CONSTRUCTION\n'
          'Coming Soon 🚀\nSTAY TUNED!!! ',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18.sp),
        ),
      ),
    );
  }
}
