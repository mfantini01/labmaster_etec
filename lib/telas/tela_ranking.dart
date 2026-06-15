import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class TelaRanking extends StatelessWidget {
  const TelaRanking({super.key});

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
            top: isMobile ? 28 : 35,
            left: isMobile ? 24 : 38,
            child: Image.asset(
              'assets/images/logo_cps_semfundo.png',
              width: isMobile ? 90 : 120,
            ),
          ),
          Center(
            child: Container(
              width: isMobile ? size.width * 0.92 : 720,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Ranking',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD32F2F),
                    ),
                  ),
                  const SizedBox(height: 24),

                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: DatabaseHelper.buscarRanking(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'Nenhuma partida registrada ainda.',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }

                      final ranking = snapshot.data!;

                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: ranking.length,
                        itemBuilder: (context, index) {
                          final item = ranking[index];

                          return _linhaRanking(
                            index + 1,
                            item['nome']?.toString() ?? 'Aluno',
                            item['pontuacao'] as int? ?? 0,
                            item['acertos'] as int? ?? 0,
                            item['erros'] as int? ?? 0,
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: 180,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Voltar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _linhaRanking(
    int posicao,
    String nome,
    int pontos,
    int acertos,
    int erros,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFD32F2F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            '$posicaoº',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Acertos: $acertos | Erros: $erros',
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ],
            ),
          ),
          Text(
            '$pontos pts',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
