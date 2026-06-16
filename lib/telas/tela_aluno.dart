import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'tela_editar_perfil.dart';
import 'tela_jogo.dart';
import 'tela_login.dart';

class TelaAluno extends StatelessWidget {
  final String email;
  final String senha;

  const TelaAluno({super.key, required this.email, required this.senha});

  Future<void> fazerLogout(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    await auth.logout();

    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/fundo_tela_aluno.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: isMobile ? 28 : 35,
            left: isMobile ? 24 : 38,
            child: Image.asset(
              'assets/images/logo2_cps.png',
              width: isMobile ? 80 : 110,
              color: Colors.white,
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
                    width: isMobile ? size.width * 0.9 : 720,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: isMobile ? 35 : 45),
                  Wrap(
                    spacing: isMobile ? 0 : 40,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: [
                      _BotaoAluno(
                        texto: 'Jogar',
                        width: isMobile ? size.width * 0.72 : 270,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TelaJogo(email: email, senha: senha),
                            ),
                          );
                        },
                      ),
                      _BotaoAluno(
                        texto: 'Editar Perfil',
                        width: isMobile ? size.width * 0.72 : 270,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TelaEditarPerfil(
                                emailAtual: email,
                                senhaAtual: senha,
                              ),
                            ),
                          );
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
            child: ElevatedButton.icon(
              onPressed: () => fazerLogout(context),
              icon: const Icon(Icons.logout),
              label: const Text(
                'Sair',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade700,
                foregroundColor: Colors.white,
                minimumSize: const Size(120, 50),
                elevation: 6,
                shadowColor: Colors.black54,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BotaoAluno extends StatelessWidget {
  final String texto;
  final double width;
  final VoidCallback onPressed;

  const _BotaoAluno({
    required this.texto,
    required this.width,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 70,
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
          texto,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
