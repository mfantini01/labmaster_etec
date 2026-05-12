import 'package:flutter/material.dart';
import 'dart:io';

class ProfessorScreen extends StatelessWidget {
  const ProfessorScreen({super.key});

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
                    width: isMobile ? size.width * 0.9 : 700,
                    fit: BoxFit.contain,
                  ),

                  SizedBox(height: isMobile ? 35 : 55),

                  Wrap(
                    spacing: isMobile ? 0 : 55,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: [
                      _MenuButton(
                        text: 'Perguntas',
                        width: isMobile ? size.width * 0.75 : 260,
                        height: isMobile ? 65 : 80,
                        onPressed: () {
                          debugPrint('Perguntas clicado');
                        },
                      ),
                      _MenuButton(
                        text: 'Ranking',
                        width: isMobile ? size.width * 0.75 : 260,
                        height: isMobile ? 65 : 80,
                        onPressed: () {
                          debugPrint('Ranking clicado');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 30,
            right: 30,
            child: SizedBox(
              width: isMobile ? 90 : 100,
              height: isMobile ? 45 : 50,
              child: ElevatedButton(
                onPressed: () {
                  exit(0);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
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

class _MenuButton extends StatelessWidget {
  final String text;
  final double width;
  final double height;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.text,
    required this.width,
    required this.height,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD32F2F),
          foregroundColor: Colors.white,
          elevation: 10,
          shadowColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
