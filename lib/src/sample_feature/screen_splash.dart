import 'dart:async';
import 'package:flutter/material.dart';
import 'package:purifier/src/sample_feature/login_page.dart';

class ScreenSplash extends StatefulWidget {
  const ScreenSplash({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ScreenSplashState createState() => _ScreenSplashState();
}

class _ScreenSplashState extends State<ScreenSplash>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2100),
      vsync: this,
    );

    _animation = Tween<double>(begin: -100.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.bounceOut, 
      ),
    );
    _controller.forward();
    Timer(
      const Duration(milliseconds: 2500),
      () => Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = 0.0;
            const end = 1.0;
            const curve = Curves.easeInOut;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var opacityAnimation = animation.drive(tween);

            return FadeTransition(
              opacity: opacityAnimation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 1500),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(        
      backgroundColor: Colors.white,
      body: SafeArea(top: true, bottom: true,left: true,right: true,
        child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0.0, _animation.value),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/cemento-base.png',
                      width: 150, height: 150),
                ],
              ),
            ),
          );
        },
      ),
      )
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
