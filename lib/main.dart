import 'package:flutter/material.dart';
import 'package:lostandfound/view/add_items/add_items_provider/add_items_provider.dart';
import 'package:lostandfound/view/delete_item/delete_item_provider.dart';
import 'package:lostandfound/view/get_single_item/get_single_item_provider/get_single_item_provider.dart';
import 'package:lostandfound/view/get_single_item/get_single_item_view.dart';
import 'package:lostandfound/view/home_screen/home_screen.dart';
import 'package:lostandfound/view/home_screen/home_screen_provider/home_screen_provider.dart';
import 'package:lostandfound/view/item_matching/match_screen.dart';
import 'package:lostandfound/view/item_matching/matching_criteria_provider/matching%20criteria_provider.dart';
import 'package:lostandfound/view/login_screen/login_screen.dart';
import 'package:lostandfound/view/login_screen/login_screen_provider/login_screen_provider.dart';
import 'package:lostandfound/view/login_screen/user_register/user_register_provider/user_register_provider.dart';
import 'package:lostandfound/view/login_screen/user_register/view/user_register_view.dart';
import 'package:lostandfound/view/my_data/my_data.dart';
import 'package:lostandfound/view/police_view/provider/police_view_provider.dart';
import 'package:lostandfound/view/splash_screen/splash_screen.dart';
import 'package:lostandfound/view/splash_screen/splash_screen_provider/splash_screen_provider.dart';
import 'package:lostandfound/view/my_data/user_data_provider/user_data_provider.dart';
import 'package:lostandfound/view/user_match/user_match_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SplashProvider()),
        ChangeNotifierProvider(create: (context) => LoginProvider()),
        ChangeNotifierProvider(create: (context) => CategoryProvider()),
        ChangeNotifierProvider(create: (context) => RegisterProvider()),
        ChangeNotifierProvider(create: (context) => ItemProvider()),
        ChangeNotifierProvider(create: (context) => SingleItemProvider()),
        ChangeNotifierProvider(create: (context) => UserItemsProvider()),
        ChangeNotifierProvider(create: (context) => DeleteItemProvider()),
        ChangeNotifierProvider(create: (context) => PoliceProvider()),
        ChangeNotifierProvider(create: (context) => MatchesProvider()),
        ChangeNotifierProvider(create: (context) => UserMatchesProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/Splash',
      routes: {
        '/Splash': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/my-items': (context) => MyItemsScreen(),
        // '/add-item': (context) => CreateItemDialog(),
        '/item-details': (context) => ItemDetailsScreen(
              itemId: ModalRoute.of(context)!.settings.arguments as int,
            ),
        '/matches': (context) => MatchesScreen(
              itemId: ModalRoute.of(context)?.settings.arguments as int,
            ),
      },
    );
  }
}
