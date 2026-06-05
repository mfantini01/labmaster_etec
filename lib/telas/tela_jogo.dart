import 'dart:math';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class TelaJogo extends StatefulWidget {
  const TelaJogo({super.key});

  @override
  State<TelaJogo> createState() => _TelaJogoState();
}

class _TelaJogoState extends State<TelaJogo> {
  List<Map<String, dynamic>> perguntas = [];
  List<int> alternativasOcultas = [];

  bool carregando = true;
  bool usou5050 = false;
  bool usouDica = false;
  bool usouPular = false;

  int perguntaAtual = 0;
  int pontuacao = 0;
  int acertos = 0;
  int erros = 0;

  @override
  void initState() {
    super.initState();
    carregarPerguntas();
  }

  Future<void> carregarPerguntas() async {
    final resultado = await DatabaseHelper.buscarPerguntasParaJogo();

    int pesoDificuldade(Map<String, dynamic> pergunta) {
      final dificuldade =
          pergunta['questao']['dificuldade']?.toString().trim() ?? '';

      if (dificuldade == '1') return 1; // Fácil
      if (dificuldade == '2') return 2; // Médio
      if (dificuldade == '3') return 3; // Difícil

      return 4;
    }

    resultado.sort((a, b) {
      return pesoDificuldade(a).compareTo(pesoDificuldade(b));
    });

    setState(() {
      perguntas = resultado;
      carregando = false;
    });
  }

  void responder(Map<String, dynamic> alternativa) {
    final correta = alternativa['correta'] == 1;

    if (correta) {
      pontuacao += 10;
      acertos++;
    } else {
      erros++;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(correta ? 'Resposta correta!' : 'Resposta errada!'),
        content: Text(
          correta ? 'Você ganhou 10 pontos.' : 'Não foi dessa vez.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              proximaPergunta();
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void proximaPergunta() {
    if (perguntaAtual < perguntas.length - 1) {
      setState(() {
        perguntaAtual++;
        alternativasOcultas.clear();
        usouDica = false;
        usou5050 = false;
        usouPular = false;
      });
    } else {
      mostrarFimDeJogo();
    }
  }

  void usar5050() {
    if (usou5050) return;

    final alternativas =
        perguntas[perguntaAtual]['alternativas'] as List<Map<String, dynamic>>;

    final erradas = <int>[];

    for (int i = 0; i < alternativas.length; i++) {
      if (alternativas[i]['correta'] != 1) {
        erradas.add(i);
      }
    }

    erradas.shuffle(Random());

    setState(() {
      alternativasOcultas = erradas.take(2).toList();
      usou5050 = true;
    });
  }

  void mostrarDica() {
    if (usouDica) return;

    final pergunta = perguntas[perguntaAtual]['questao'];
    final dica = pergunta['dica']?.toString() ?? 'Sem dica cadastrada.';

    setState(() {
      usouDica = true;
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Dica'),
        content: Text(dica.isEmpty ? 'Sem dica cadastrada.' : dica),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void pularPergunta() {
    if (usouPular) return;

    setState(() {
      usouPular = true;
    });

    proximaPergunta();
  }

  void mostrarFimDeJogo() {
    final total = perguntas.length;
    final porcentagem = total == 0 ? 0 : (acertos / total) * 100;

    String desempenho;

    if (porcentagem >= 80) {
      desempenho = 'Excelente';
    } else if (porcentagem >= 60) {
      desempenho = 'Bom';
    } else if (porcentagem >= 40) {
      desempenho = 'Regular';
    } else {
      desempenho = 'Precisa melhorar';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Fim de jogo!'),
        content: Text(
          'Acertos: $acertos/$total\n'
          'Erros: $erros\n'
          'Pontuação: $pontuacao pontos\n'
          'Desempenho: $desempenho',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;

    if (carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (perguntas.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Nenhuma pergunta cadastrada')),
      );
    }

    final pergunta = perguntas[perguntaAtual]['questao'];
    final alternativas =
        perguntas[perguntaAtual]['alternativas'] as List<Map<String, dynamic>>;

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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pergunta ${perguntaAtual + 1}/${perguntas.length}',
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
                      borderRadius: BorderRadius.circular(16),
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
                        if (alternativasOcultas.contains(index)) {
                          return const SizedBox.shrink();
                        }

                        final alternativa = alternativas[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ElevatedButton(
                            onPressed: () => responder(alternativa),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(70),
                            ),
                            child: Text(
                              alternativa['texto']?.toString() ?? '',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: usou5050 ? null : usar5050,
                        child: const Text('50/50'),
                      ),
                      ElevatedButton(
                        onPressed: usouDica ? null : mostrarDica,
                        child: const Text('Dica'),
                      ),
                      ElevatedButton(
                        onPressed: usouPular ? null : pularPergunta,
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
