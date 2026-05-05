import 'package:flutter/material.dart';
import 'dart:io';
import 'tela_login.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/tela_inicial.png',
              fit: BoxFit.cover,
            ),
          ),

          Align(
            alignment: const Alignment(0, 0.45),
            child: SizedBox(
              width: 300,
              height: 90,
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
                  backgroundColor: const Color(0xFFD32F2F), // vermelho bonito
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  shadowColor: Colors.black,
                ),
                child: const Text(
                  "JOGAR",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 30,
            right: 30,
            child: ElevatedButton(
              onPressed: () {
                exit(0);
              },
              child: const Text("Sair"),
            ),
          ),
        ],
      ),
    );
  }
}
