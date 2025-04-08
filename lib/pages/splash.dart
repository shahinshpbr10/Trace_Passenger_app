import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:trace_companion/Common/text_styles.dart';
import 'package:trace_companion/pages/custombottomnavbar.dart';
import 'package:trace_companion/pages/loginandsignup.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(builder: (context) => const BottomNavPage()),
              (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(builder: (context) => const OTPLoginPage()),
              (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF3FF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 130,
              width: 130,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Lottie.asset('assets/lottie/splash.json'),
              ),
            ),
            const SizedBox(height: 30),
             Text(
              "Trace Passenger",
              style: AppTextStyles.smallBodyText.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3D5AFE),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Track. Ride. Relax.",
              style: AppTextStyles.smallBodyText.copyWith(
                fontSize: 16,
                color: Color(0xFF6C7A96),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: Color(0xFF3D5AFE),
              strokeWidth: 2.5,
            )
          ],
        ),
      ),
    );
  }
}
