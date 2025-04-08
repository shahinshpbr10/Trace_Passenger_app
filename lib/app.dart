import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trace_companion/pages/splash.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
