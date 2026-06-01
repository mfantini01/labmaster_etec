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

  Widget logoSuperior({required bool isMobile}) {
    return Padding(
      padding: EdgeInsets.only(
        top: isMobile ? 18 : 25,
        left: isMobile ? 18 : 25,
        right: isMobile ? 18 : 30,
      ),
      child: Row(
        mainAxisAlignment:
            isMobile ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
        children: [
          Image.asset(
            'assets/images/logo_cps_semfundo.png',
            width: isMobile ? 70 : 115,
          ),
          if (isMobile)
            Image.asset(
              'assets/images/logo_labmaster.png',
              width: 95,
            ),
        ],
      ),
    );
  }

  Widget logoLabMasterDesktop() {
    return Positioned(
      top: 30,
      right: 30,
      child: Image.asset(
        'assets/images/logo_labmaster.png',
        width: 180,
      ),
    );
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

          if (!isMobile) logoLabMasterDesktop(),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: logoSuperior(isMobile: isMobile),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 22 : 24,
                isMobile ? 120 : 105,
                isMobile ? 22 : 24,
                30,
              ),
              child: Center(
                child: SizedBox(
                  width: isMobile ? double.infinity : 700,
                  child: Column(
                    children: [
                      Text(
                        'Excluir Perguntas',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? 30 : 34,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFB71C1C),
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
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 19 : 22,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: const Icon(
                              Icons.search,
                              color: Colors.white,
                              size: 30,
                            ),
                            hintText: isMobile
                                ? 'Digite o enunciado da per...'
                                : 'Digite o enunciado da pergunta',
                            hintStyle: TextStyle(
                              color: Colors.white70,
                              fontSize: isMobile ? 19 : 22,
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
                                ).then(
                                  (_) => pesquisar(pesquisaController.text),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(14),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
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
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: isMobile ? 17 : 19,
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

                      const SizedBox(height: 26),

                      SizedBox(
                        width: isMobile ? size.width * 0.65 : 265,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[700],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Voltar',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                    ],
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB71C1C),
              foregroundColor: Colors.white,
            ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao excluir pergunta')),
      );
    }
  }

  Widget logoSuperior({required bool isMobile}) {
    return Padding(
      padding: EdgeInsets.only(
        top: isMobile ? 18 : 25,
        left: isMobile ? 18 : 25,
        right: isMobile ? 18 : 30,
      ),
      child: Row(
        mainAxisAlignment:
            isMobile ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
        children: [
          Image.asset(
            'assets/images/logo_cps_semfundo.png',
            width: isMobile ? 70 : 115,
          ),
          if (isMobile)
            Image.asset(
              'assets/images/logo_labmaster.png',
              width: 95,
            ),
        ],
      ),
    );
  }

  Widget logoLabMasterDesktop() {
    return Positioned(
      top: 30,
      right: 30,
      child: Image.asset(
        'assets/images/logo_labmaster.png',
        width: 180,
      ),
    );
  }

  Widget alternativaCard({
    required String texto,
    required bool correta,
    required String? caminhoImagemAlternativa,
    required bool isMobile,
  }) {
    final temImagem =
        caminhoImagemAlternativa != null && caminhoImagemAlternativa.isNotEmpty;

    return Container(
      width: isMobile ? double.infinity : 560,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: correta ? Colors.green.withOpacity(0.13) : Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: correta ? Colors.green : Colors.grey.shade300,
          width: correta ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (texto.isNotEmpty)
            Text(
              texto,
              style: TextStyle(
                fontSize: isMobile ? 17 : 18,
                fontWeight: FontWeight.bold,
                color: correta ? Colors.green : Colors.black87,
              ),
            ),

          if (temImagem) ...[
            if (texto.isNotEmpty) const SizedBox(height: 10),
            Center(
              child: Container(
                width: isMobile ? double.infinity : 420,
                height: isMobile ? 125 : 145,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(caminhoImagemAlternativa),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget imagemQuestao(String caminhoImagem, bool isMobile) {
    final arquivo = File(caminhoImagem);

    if (!arquivo.existsSync()) {
      return Container(
        width: double.infinity,
        height: 80,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.55),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: const Text(
          'Imagem anexada anteriormente',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }

    return Container(
      height: isMobile ? 180 : 250,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white70,
      ),
      child: Image.file(
        arquivo,
        fit: BoxFit.contain,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;

    if (dados == null) {
      return const Scaffold(
        body: Center(
          child: Text('Pergunta não encontrada'),
        ),
      );
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

          if (!isMobile) logoLabMasterDesktop(),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: logoSuperior(isMobile: isMobile),
            ),
          ),

          SafeArea(
            child: Scrollbar(
              thumbVisibility: !isMobile,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 22 : 24,
                  isMobile ? 105 : 90,
                  isMobile ? 22 : 24,
                  30,
                ),
                child: Center(
                  child: SizedBox(
                    width: isMobile ? double.infinity : 700,
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
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile ? 21 : 24,
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
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile ? 18 : 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        if (questao['caminho_imagem'] != null &&
                            questao['caminho_imagem']
                                .toString()
                                .isNotEmpty) ...[
                          const SizedBox(height: 20),
                          imagemQuestao(
                            questao['caminho_imagem'].toString(),
                            isMobile,
                          ),
                        ],

                        const SizedBox(height: 24),

                        ...alternativas.map<Widget>((alternativa) {
                          final texto = alternativa['texto']?.toString() ?? '';
                          final caminhoImagemAlternativa =
                              alternativa['caminho_imagem_alternativa']
                                  ?.toString();
                          final correta = alternativa['correta'] == 1;

                          return alternativaCard(
                            texto: texto,
                            correta: correta,
                            caminhoImagemAlternativa:
                                caminhoImagemAlternativa,
                            isMobile: isMobile,
                          );
                        }).toList(),

                        const SizedBox(height: 40),

                        SizedBox(
                          width: isMobile ? size.width * 0.72 : 280,
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        SizedBox(
                          width: isMobile ? size.width * 0.65 : 265,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[700],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Voltar',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
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