import 'package:flutter/material.dart';
import 'dart:math';

void main()
{
  runApp(MaterialApp(
    home: SplashScreen(),
  ));
}
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin{
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(); // Repeats the animation indefinitely
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -150,
            left: -70,
            child: Container(
              width: 400,
              height: 350,
              decoration: BoxDecoration(
                color: (Colors.pinkAccent[100] ?? Colors.pink).withOpacity(0.7),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: -150,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: (Colors.lightBlueAccent[300] ?? Colors.blue).withOpacity(0.7),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(height: 20.0,),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo.png',
                  width: 500,
                  height: 350,
                ),
                Text(
                  'CONNECT THROUGH YOUR VOICE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                    fontSize: 30.0,
                  ),
                ),
                SizedBox(height: 50.0,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        final double animationValue =
                        (_controller.value * 2 * pi); // Map value to radians
                        final double offset1 = 25 * (1 + sin(animationValue));
                        return Transform.translate(
                          offset: Offset(offset1, 0),
                          child: const Dot(isActive: true),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        final double animationValue =
                        (_controller.value * 2 * pi); // Map value to radians
                        final double offset2 = -25 * (1 + sin(animationValue));
                        return Transform.translate(
                          offset: Offset(offset2, 0),
                          child: const Dot(isActive: false),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Dot extends StatelessWidget {
  final bool isActive;

  const Dot({Key? key, required this.isActive}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: isActive ? Colors.blueGrey : Colors.lightBlueAccent,
        shape: BoxShape.circle,
      ),
    );
  }
}
