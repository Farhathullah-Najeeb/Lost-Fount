// splash_screen_provider.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:lostandfound/view/login_screen/login_screen_provider/login_screen_provider.dart';
import 'package:provider/provider.dart';

class SplashProvider with ChangeNotifier {
  bool _isLoading = true;

  bool get isLoading => _isLoading;

  Future<void> checkLoginStatus(BuildContext context) async {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    await Future.delayed(const Duration(seconds: 2));

    final isLoggedIn = await loginProvider.isUserLoggedIn();
    _isLoading = false;
    notifyListeners();

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}
