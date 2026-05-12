import 'package:flutter/material.dart';
import 'dart:io';
import 'tela_login.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/fundo_login.png',
              fit: BoxFit.cover,
            ),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo_labmaster.png',
                    width: isMobile ? size.width * 0.85 : 650,
                    fit: BoxFit.contain,
                  ),

                  SizedBox(height: isMobile ? 40 : 55),

                 
                  SizedBox(
                    width: isMobile ? size.width * 0.72 : 320,
                    height: isMobile ? 70 : 90,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        elevation: 10,
                        shadowColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'JOGAR',
                        style: TextStyle(
                          fontSize: isMobile ? 22 : 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 30,
            right: 30,
            child: SizedBox(
              width: isMobile ? 90 : 110,
              height: isMobile ? 45 : 50,
              child: ElevatedButton(
                onPressed: () {
                  exit(0);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                ),
                child: const Text('Sair'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
