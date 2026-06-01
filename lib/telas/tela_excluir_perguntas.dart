import 'dart:io';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class TelaExcluirPerguntas extends StatefulWidget {
  const TelaExcluirPerguntas({super.key});

  @override
  State<TelaExcluirPerguntas> createState() => _TelaExcluirPerguntasState();
}

class _TelaExcluirPerguntasState extends State<TelaExcluirPerguntas> {
  final pesquisaController = TextEditingController();
  List<Map<String, dynamic>> perguntas = [];

  @override
  void initState() {
    super.initState();
    pesquisar('');
  }

  @override
  void dispose() {
    pesquisaController.dispose();
    super.dispose();
  }

  Future<void> pesquisar(String termo) async {
    final resultado = await DatabaseHelper.pesquisarPerguntas(termo);

    if (!mounted) return;

    setState(() {
      perguntas = resultado;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;

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
              'assets/images/logo_cps_semfundo.png',
              width: isMobile ? 90 : 120,
            ),
          ),

          Positioned(
            top: isMobile ? 25 : 30,
            right: isMobile ? 20 : 30,
            child: Image.asset(
              'assets/images/logo_labmaster.png',
              width: isMobile ? 140 : 180,
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 35),
              child: SizedBox(
                width: isMobile ? size.width * 0.88 : 700,
                child: Column(
                  children: [
                    const Text(
                      'Excluir Perguntas',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB71C1C),
                      ),
                    ),

                    const SizedBox(height: 28),

                    Container(
                      width: double.infinity,
                      height: 70,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TextField(
                        controller: pesquisaController,
                        onChanged: pesquisar,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          icon: Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 30,
                          ),
                          hintText: 'Digite o enunciado da pergunta',
                          hintStyle: TextStyle(
                            color: Colors.white70,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    if (perguntas.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text(
                          'Nenhuma pergunta encontrada',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: perguntas.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final pergunta = perguntas[index];

                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TelaFormularioExcluirPerguntas(
                                        questaoId: pergunta['id'],
                                      ),
                                ),
                              ).then((_) => pesquisar(pesquisaController.text));
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.delete,
                                    color: Color(0xFFB71C1C),
                                    size: 30,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      pergunta['enunciado'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 20,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
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
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Voltar',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TelaFormularioExcluirPerguntas extends StatefulWidget {
  final int questaoId;

  const TelaFormularioExcluirPerguntas({super.key, required this.questaoId});

  @override
  State<TelaFormularioExcluirPerguntas> createState() =>
      _TelaFormularioExcluirPerguntasState();
}

class _TelaFormularioExcluirPerguntasState
    extends State<TelaFormularioExcluirPerguntas> {
  Map<String, dynamic>? dados;
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarPergunta();
  }

  Future<void> carregarPergunta() async {
    final resultado = await DatabaseHelper.buscarPerguntaCompleta(
      widget.questaoId,
    );

    if (!mounted) return;

    setState(() {
      dados = resultado;
      carregando = false;
    });
  }

  Future<void> excluirPergunta() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir pergunta'),
        content: const Text('Tem certeza que deseja excluir esta pergunta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final sucesso = await DatabaseHelper.excluirPergunta(widget.questaoId);

    if (!mounted) return;

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pergunta excluída com sucesso')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erro ao excluir pergunta')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final questao = dados!['questao'];
    final alternativas = dados!['alternativas'];

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
            top: 25,
            left: 25,
            child: Image.asset(
              'assets/images/logo_cps_semfundo.png',
              width: 115,
            ),
          ),
          Positioned(
            top: 30,
            right: 30,
            child: Image.asset('assets/images/logo_labmaster.png', width: 180),
          ),

          Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Center(
                child: SizedBox(
                  width: 700,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          questao['enunciado'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.grey[500],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          questao['dica'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (questao['caminho_imagem'] != null &&
                          questao['caminho_imagem'].toString().isNotEmpty)
                        Container(
                          height: 250,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white70,
                          ),
                          child: Image.file(
                            File(questao['caminho_imagem']),
                            fit: BoxFit.contain,
                          ),
                        ),
                      const SizedBox(height: 24),
                      ...alternativas.map<Widget>((alternativa) {
                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: alternativa['correta'] == 1
                                ? Colors.green.withOpacity(0.15)
                                : Colors.white70,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            alternativa['texto'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 55),
                      SizedBox(
                        width: 280,
                        height: 60,
                        child: ElevatedButton.icon(
                          onPressed: excluirPergunta,
                          icon: const Icon(Icons.delete),
                          label: const Text(
                            'EXCLUIR',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB71C1C),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 90),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 30,
            right: 30,
            child: SizedBox(
              width: 110,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Voltar',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
