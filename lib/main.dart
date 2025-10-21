import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/splash_screen.dart';
import 'pages/kuy_ride_page.dart';
import 'pages/kuy_food_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MovakaApp());
}

class MovakaApp extends StatelessWidget {
  const MovakaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(  
      debugShowCheckedModeBanner: false,
      title: 'Movaka',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(),
      routes: {
        '/kuyride': (context) => KuyRidePage(),
        '/kuyfood': (context) => KuyFoodPage(),
      },
    );
  }
}
