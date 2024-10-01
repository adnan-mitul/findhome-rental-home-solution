import 'dart:async';

import 'package:find_home/home_pages/root_page.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 7), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RootPage(), // Corrected class name to HomePage
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/img.png',
              width: 350, // Adjusted the width of the logo
              height: 350, // Adjusted the height of the logo
            ),
            const SizedBox(height: 5), // Optional small space if needed
            const TypingText(
              text: 'Find Faster, Live Better',
              textStyle: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF7043), // Custom color between red and orange
              ),
              duration:
                  Duration(milliseconds: 50), // Adjusted the speed of typing
            ),
          ],
        ),
      ),
    );
  }
}

class TypingText extends StatefulWidget {
  final String text;
  final TextStyle textStyle;
  final Duration duration;

  const TypingText({
    required this.text,
    required this.textStyle,
    required this.duration,
    Key? key,
  }) : super(key: key);

  @override
  _TypingTextState createState() => _TypingTextState();
}

class _TypingTextState extends State<TypingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _charCount;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration * widget.text.length,
      vsync: this,
    );

    _charCount =
        StepTween(begin: 0, end: widget.text.length).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _charCount,
      builder: (BuildContext context, Widget? child) {
        String visibleString = widget.text.substring(0, _charCount.value);
        return Text(
          visibleString,
          style: widget.textStyle,
        );
      },
    );
  }
}
