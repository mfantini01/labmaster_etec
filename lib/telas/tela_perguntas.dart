import 'package:flutter/material.dart';

class TelaPerguntas extends StatelessWidget {
  const TelaPerguntas({super.key});

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

          Positioned(
            top: isMobile ? 20 : 30,
            left: isMobile ? 20 : 30,
            child: Image.asset(
              'assets/images/logo2_cps.png',
              width: isMobile ? 90 : 120,
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

                  SizedBox(height: isMobile ? 35 : 55),

                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 28,
                    runSpacing: 22,
                    children: [
                      _BotaoPergunta(
                        texto: 'Adicionar\nPerguntas',
                        width: isMobile ? size.width * 0.75 : 260,
                        onPressed: () {},
                      ),
                      _BotaoPergunta(
                        texto: 'Editar\nPerguntas',
                        width: isMobile ? size.width * 0.75 : 260,
                        onPressed: () {},
                      ),
                      _BotaoPergunta(
                        texto: 'Excluir\nPerguntas',
                        width: isMobile ? size.width * 0.75 : 260,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: isMobile ? 20 : 30,
            right: isMobile ? 20 : 30,
            child: SizedBox(
              width: isMobile ? 95 : 110,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Voltar',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BotaoPergunta extends StatelessWidget {
  final String texto;
  final double width;
  final VoidCallback onPressed;

  const _BotaoPergunta({
    required this.texto,
    required this.width,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 85,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD32F2F),
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            height: 1.1,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}