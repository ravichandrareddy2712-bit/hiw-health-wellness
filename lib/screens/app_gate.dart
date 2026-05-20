import 'package:flutter/material.dart';
import '../core/app_state.dart';
import 'login_screen.dart';
import 'user_info_screen.dart';
import 'home_screen.dart';

class AppGate extends StatelessWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _decide(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data!;
      },
    );
  }

  Future<Widget> _decide() async {
    final loggedIn = await AppState.isLoggedIn();
    final hasInfo = await AppState.hasUserInfo();

    if (!loggedIn) {
      return const LoginScreen();
    } else if (!hasInfo) {
      return const UserInfoScreen();
    } else {
      return const HomeScreen();
    }
  }
}
