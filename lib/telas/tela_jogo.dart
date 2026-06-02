import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class TelaJogo extends StatefulWidget {
  const TelaJogo({super.key});

  @override
  State<TelaJogo> createState() => _TelaJogoState();
}

class _TelaJogoState extends State<TelaJogo> {
  List<Map<String, dynamic>> perguntas = [];
  bool carregando = true;

  int perguntaAtual = 0;
  int pontuacao = 0;

  @override
  void initState() {
    super.initState();
    carregarPerguntas();
  }

  Future<void> carregarPerguntas() async {
    final resultado =
        await DatabaseHelper.buscarPerguntasParaJogo();

    setState(() {
      perguntas = resultado;
      carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;

    if (carregando) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (perguntas.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('Nenhuma pergunta cadastrada'),
        ),
      );
    }

    final pergunta = perguntas[perguntaAtual]['questao'];
    final alternativas =
        perguntas[perguntaAtual]['alternativas'];

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
            top: 25,
            left: 25,
            child: Image.asset(
              'assets/images/logo2_cps.png',
              width: isMobile ? 70 : 110,
              color: Colors.white,
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pergunta ${perguntaAtual + 1}/10',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        'Pontos: $pontuacao',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                    child: Text(
                      pergunta['enunciado'] ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  Expanded(
                    child: ListView.builder(
                      itemCount: alternativas.length,
                      itemBuilder: (context, index) {

                        final alternativa =
                            alternativas[index];

                        return Padding(
                          padding:
                              const EdgeInsets.only(
                            bottom: 12,
                          ),
                          child: ElevatedButton(
                            onPressed: () {},
                            style:
                                ElevatedButton.styleFrom(
                              minimumSize:
                                  const Size.fromHeight(
                                70,
                              ),
                            ),
                            child: Text(
                              alternativa['texto']
                                      ?.toString() ??
                                  '',
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('50/50'),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Dica'),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Pular'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}