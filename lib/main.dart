import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otp_animation/otp_animation_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        textTheme: GoogleFonts.ibmPlexSansArabicTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: OtpVerificationPage(),
    );
  }
}
