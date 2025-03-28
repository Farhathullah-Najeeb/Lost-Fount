// splash_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lostandfound/view/login_screen/login_screen_provider/login_screen_provider.dart';
import 'package:lostandfound/view/splash_screen/splash_screen_provider/splash_screen_provider.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => SplashProvider()),
      ],
      child: Consumer2<SplashProvider, LoginProvider>(
        builder: (context, splashProvider, loginProvider, child) {
          // Only check status once when loading starts
          if (splashProvider.isLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              splashProvider.checkLoginStatus(context);
            });
          }

          return Scaffold(
            backgroundColor: Colors.blue,
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blueAccent, Colors.blue.shade700],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'asset/images/logo.png',
                      color: Colors.white,
                      width: 150,
                      height: 150,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
