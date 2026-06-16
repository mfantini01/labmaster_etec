import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class TelaJogo extends StatefulWidget {
  final String email;
  final String senha;

  const TelaJogo({super.key, required this.email, required this.senha});

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
  int? alternativaSelecionada;
  int? alternativaCorreta;
  bool bloqueado = false;

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

    final faceis = resultado.where((p) => pesoDificuldade(p) == 1).toList();

    final medias = resultado.where((p) => pesoDificuldade(p) == 2).toList();

    final dificeis = resultado.where((p) => pesoDificuldade(p) == 3).toList();

    faceis.shuffle();
    medias.shuffle();
    dificeis.shuffle();

    resultado
      ..clear()
      ..addAll(faceis)
      ..addAll(medias)
      ..addAll(dificeis);

    setState(() {
      perguntas = resultado;
      carregando = false;
    });
  }

  void responder(Map<String, dynamic> alternativa) {
    if (bloqueado) return;

    final correta = alternativa['correta'] == 1;

    final alternativas =
        perguntas[perguntaAtual]['alternativas'] as List<Map<String, dynamic>>;

    final indiceSelecionado = alternativas.indexOf(alternativa);

    final indiceCorreto = alternativas.indexWhere((alt) => alt['correta'] == 1);

    setState(() {
      bloqueado = true;
      alternativaSelecionada = indiceSelecionado;
      alternativaCorreta = indiceCorreto;
    });

    if (correta) {
      pontuacao += 10;
      acertos++;
    } else {
      erros++;
    }

    Future.delayed(const Duration(milliseconds: 800), () {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: correta ? Colors.greenAccent : Colors.redAccent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (correta ? Colors.greenAccent : Colors.redAccent)
                        .withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    correta ? Icons.check_circle : Icons.cancel,
                    color: correta ? Colors.greenAccent : Colors.redAccent,
                    size: 60,
                  ),

                  const SizedBox(height: 15),

                  Text(
                    correta ? 'RESPOSTA CORRETA!' : 'RESPOSTA INCORRETA!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    correta ? 'Você ganhou 10 pontos.' : 'Não foi dessa vez.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 18),
                  ),

                  const SizedBox(height: 25),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);

                      setState(() {
                        alternativaSelecionada = null;
                        alternativaCorreta = null;
                        bloqueado = false;
                      });

                      proximaPergunta();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: correta
                          ? Colors.greenAccent
                          : Colors.redAccent,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(140, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'CONTINUAR',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  void proximaPergunta() {
    if (perguntaAtual < perguntas.length - 1) {
      setState(() {
        perguntaAtual++;
        alternativasOcultas.clear();
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
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.redAccent, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lightbulb, color: Colors.amber, size: 50),

                const SizedBox(height: 12),

                const Text(
                  'DICA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  dica,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 18),
                ),

                const SizedBox(height: 25),

                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('FECHAR'),
                ),
              ],
            ),
          ),
        );
      },
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
    Color corDesempenho;

    if (porcentagem >= 80) {
      desempenho = 'EXCELENTE';
      corDesempenho = Colors.greenAccent;
    } else if (porcentagem >= 60) {
      desempenho = 'BOM';
      corDesempenho = Colors.lightBlueAccent;
    } else if (porcentagem >= 40) {
      desempenho = 'REGULAR';
      corDesempenho = Colors.orangeAccent;
    } else {
      desempenho = 'PRECISA MELHORAR';
      corDesempenho = Colors.redAccent;
    }

    DatabaseHelper.salvarPartida(
      email: widget.email,
      senha: widget.senha,
      pontuacao: pontuacao,
      acertos: acertos,
      erros: erros,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.redAccent, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber, size: 70),

                const SizedBox(height: 15),

                const Text(
                  'FIM DE JOGO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 25),

                Text(
                  'Acertos: $acertos/$total',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),

                const SizedBox(height: 8),

                Text(
                  'Erros: $erros',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),

                const SizedBox(height: 8),

                Text(
                  'Pontuação: $pontuacao pontos',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),

                const SizedBox(height: 20),

                const Text(
                  'DESEMPENHO',
                  style: TextStyle(color: Colors.white70, letterSpacing: 2),
                ),

                const SizedBox(height: 8),

                Text(
                  desempenho,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: corDesempenho,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('VOLTAR AO MENU'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(220, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
    final caminhoImagem = pergunta['caminho_imagem']?.toString();
    final possuiImagem = alternativas.any(
      (alt) =>
          alt['caminho_imagem_alternativa'] != null &&
          alt['caminho_imagem_alternativa'].toString().isNotEmpty,
    );

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/fundo_tela_aluno.png',
              fit: BoxFit.cover,
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
                      Image.asset(
                        'assets/images/logo2_cps.png',
                        width: 90,
                        color: Colors.white,
                      ),

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

                  const SizedBox(height: 20),

                  if (pergunta['caminho_imagem'] != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(pergunta['caminho_imagem']),
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    ),

                  const SizedBox(height: 30),
                  Expanded(
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 colunas
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: possuiImagem ? 3.5 : 6,
                      ),
                      itemCount: alternativas.length,
                      itemBuilder: (context, index) {
                        if (alternativasOcultas.contains(index)) {
                          return const SizedBox.shrink();
                        }

                        final alternativa = alternativas[index];

                        Color corBotao = Colors.white;

                        if (alternativaCorreta != null) {
                          if (index == alternativaCorreta) {
                            corBotao = Colors.green;
                          }

                          if (index == alternativaSelecionada &&
                              index != alternativaCorreta) {
                            corBotao = Colors.red;
                          }
                        }

                        return ElevatedButton(
                          onPressed: () => responder(alternativa),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: corBotao,
                            foregroundColor: corBotao == Colors.white
                                ? Colors.black
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (alternativa['texto'] != null &&
                                  alternativa['texto'].toString().isNotEmpty)
                                Text(
                                  alternativa['texto'].toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                              if (alternativa['caminho_imagem_alternativa'] !=
                                      null &&
                                  alternativa['caminho_imagem_alternativa']
                                      .toString()
                                      .isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Image.file(
                                  File(
                                    alternativa['caminho_imagem_alternativa'],
                                  ),
                                  height: 180,
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: usou5050 ? null : usar5050,
                        icon: const Icon(Icons.content_cut),
                        label: const Text('50/50'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1E2A44),
                          elevation: 4,
                          minimumSize: const Size(120, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton.icon(
                        onPressed: usouDica ? null : mostrarDica,
                        icon: const Icon(Icons.lightbulb_outline),
                        label: const Text('Dica'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1E2A44),
                          elevation: 4,
                          minimumSize: const Size(120, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton.icon(
                        onPressed: usouPular ? null : pularPergunta,
                        icon: const Icon(Icons.skip_next),
                        label: const Text('Pular'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1E2A44),
                          elevation: 4,
                          minimumSize: const Size(120, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sair'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade700,
                foregroundColor: Colors.white,
                minimumSize: const Size(120, 50),
                elevation: 6,
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
