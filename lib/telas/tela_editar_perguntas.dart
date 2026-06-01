import 'dart:io';
import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class TelaEditarPerguntas extends StatefulWidget {
  const TelaEditarPerguntas({super.key});

  @override
  State<TelaEditarPerguntas> createState() => _TelaEditarPerguntasState();
}

class _TelaEditarPerguntasState extends State<TelaEditarPerguntas> {
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
                      'Editar Perguntas',
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
                                      TelaFormularioEditarPerguntas(
                                        questaoId: pergunta['id'],
                                      ),
                                ),
                              );
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
                                    Icons.edit,
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

class TelaFormularioEditarPerguntas extends StatefulWidget {
  final int questaoId;

  const TelaFormularioEditarPerguntas({super.key, required this.questaoId});

  @override
  State<TelaFormularioEditarPerguntas> createState() =>
      _TelaFormularioEditarPerguntasState();
}

class _TelaFormularioEditarPerguntasState
    extends State<TelaFormularioEditarPerguntas> {
  final perguntaController = TextEditingController();
  final dicaController = TextEditingController();
  final alternativaAController = TextEditingController();
  final alternativaBController = TextEditingController();
  final alternativaCController = TextEditingController();
  final alternativaDController = TextEditingController();

  String? dificuldade;
  String? caminhoImagem;
  String? alternativaCorreta = 'A';
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarPergunta();
  }

  @override
  void dispose() {
    perguntaController.dispose();
    dicaController.dispose();
    alternativaAController.dispose();
    alternativaBController.dispose();
    alternativaCController.dispose();
    alternativaDController.dispose();
    super.dispose();
  }

  Future<void> carregarPergunta() async {
    final dados = await DatabaseHelper.buscarPerguntaCompleta(widget.questaoId);

    if (!mounted) return;

    if (dados == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pergunta não encontrada')));
      Navigator.pop(context);
      return;
    }

    final questao = dados['questao'] as Map<String, dynamic>;
    final alternativas = dados['alternativas'] as List<Map<String, dynamic>>;

    perguntaController.text = questao['enunciado']?.toString() ?? '';
    dicaController.text = questao['dica']?.toString() ?? '';
    dificuldade = questao['dificuldade']?.toString();
    caminhoImagem = questao['caminho_imagem']?.toString();

    if (alternativas.isNotEmpty) {
      alternativaAController.text = alternativas.length > 0
          ? alternativas[0]['texto']?.toString() ?? ''
          : '';
      alternativaBController.text = alternativas.length > 1
          ? alternativas[1]['texto']?.toString() ?? ''
          : '';
      alternativaCController.text = alternativas.length > 2
          ? alternativas[2]['texto']?.toString() ?? ''
          : '';
      alternativaDController.text = alternativas.length > 3
          ? alternativas[3]['texto']?.toString() ?? ''
          : '';

      for (int i = 0; i < alternativas.length && i < 4; i++) {
        if (alternativas[i]['correta'] == 1) {
          alternativaCorreta = ['A', 'B', 'C', 'D'][i];
        }
      }
    }

    setState(() {
      carregando = false;
    });
  }

  Future<void> escolherImagem() async {
    final resultado = await FilePicker.pickFiles(type: FileType.image);

    if (resultado != null && resultado.files.first.path != null) {
      setState(() {
        caminhoImagem = resultado.files.first.path!;
      });
    }
  }

  Future<void> salvarEdicao() async {
    final enunciado = perguntaController.text.trim();
    final dica = dicaController.text.trim();
    final alternativaA = alternativaAController.text.trim();
    final alternativaB = alternativaBController.text.trim();
    final alternativaC = alternativaCController.text.trim();
    final alternativaD = alternativaDController.text.trim();

    if (enunciado.isEmpty ||
        dica.isEmpty ||
        dificuldade == null ||
        alternativaA.isEmpty ||
        alternativaB.isEmpty ||
        alternativaC.isEmpty ||
        alternativaD.isEmpty ||
        alternativaCorreta == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preencha todos os campos')));
      return;
    }

    final sucesso = await DatabaseHelper.atualizarPerguntas(
      questaoId: widget.questaoId,
      enunciado: enunciado,
      dica: dica,
      dificuldade: int.parse(dificuldade!),
      alternativaA: alternativaA,
      alternativaB: alternativaB,
      alternativaC: alternativaC,
      alternativaD: alternativaD,
      alternativaCorreta: alternativaCorreta!,
      caminhoImagem: caminhoImagem,
    );

    if (!mounted) return;

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pergunta atualizada com sucesso')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar pergunta')),
      );
    }
  }

  Widget campoAlternativa(String letra, TextEditingController controller) {
    return Container(
      width: 330,
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFC62828),
            child: Text(
              letra,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Digite a alternativa $letra',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget caixaCorreta(String letra) {
    final selecionada = alternativaCorreta == letra;

    return InkWell(
      onTap: () => setState(() => alternativaCorreta = letra),
      child: Container(
        width: 150,
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selecionada ? Colors.green.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selecionada ? Colors.green : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              letra,
              style: TextStyle(
                color: selecionada ? Colors.green : Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(
              selecionada ? Icons.check_box : Icons.check_box_outline_blank,
              color: selecionada ? Colors.green : Colors.grey,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget imagemPreview() {
    if (caminhoImagem == null || caminhoImagem!.isEmpty) {
      return const SizedBox.shrink();
    }

    final arquivo = File(caminhoImagem!);

    if (!arquivo.existsSync()) {
      return Container(
        width: double.infinity,
        height: 80,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.45),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade400, width: 2),
        ),
        child: const Text(
          'Imagem anexada anteriormente',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 230,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade400, width: 2),
      ),
      child: Image.file(arquivo, fit: BoxFit.scaleDown),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;

    if (carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
          Positioned(
            top: 115,
            left: 25,
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

          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: caminhoImagem == null ? 55 : 30,
              bottom: 30,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: size.height - 60),
              child: Center(
                child: SizedBox(
                  width: isMobile ? size.width * 0.88 : 680,
                  child: Column(
                    mainAxisAlignment: caminhoImagem == null
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 105,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: TextField(
                          controller: perguntaController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Pergunta:',
                            hintStyle: TextStyle(
                              color: Colors.white70,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Container(
                        width: double.infinity,
                        height: 72,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          color: Colors.grey[500],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: dicaController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Dica:',
                            hintStyle: TextStyle(
                              color: Colors.white70,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: isMobile ? size.width * 0.42 : 310,
                            height: 60,
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            decoration: BoxDecoration(
                              color: Colors.grey[600],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: dificuldade,
                                hint: const Text(
                                  'Dificuldade',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                dropdownColor: Colors.grey[700],
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.white,
                                ),
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(
                                    value: '1',
                                    child: Text('Fácil'),
                                  ),
                                  DropdownMenuItem(
                                    value: '2',
                                    child: Text('Médio'),
                                  ),
                                  DropdownMenuItem(
                                    value: '3',
                                    child: Text('Difícil'),
                                  ),
                                ],
                                onChanged: (value) =>
                                    setState(() => dificuldade = value),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 40),

                          SizedBox(
                            width: isMobile ? size.width * 0.42 : 310,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: escolherImagem,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[600],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Imagem',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Icon(Icons.add, size: 34),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (caminhoImagem != null &&
                          caminhoImagem!.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        imagemPreview(),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                setState(() => caminhoImagem = null),
                            icon: const Icon(Icons.delete_outline),
                            label: const Text(
                              'Desanexar imagem',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[600],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 18),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Alternativas:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Wrap(
                        spacing: 18,
                        runSpacing: 14,
                        alignment: WrapAlignment.center,
                        children: [
                          campoAlternativa('A', alternativaAController),
                          campoAlternativa('B', alternativaBController),
                          campoAlternativa('C', alternativaCController),
                          campoAlternativa('D', alternativaDController),
                        ],
                      ),

                      const SizedBox(height: 18),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Resposta correta:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Wrap(
                        spacing: 18,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: [
                          caixaCorreta('A'),
                          caixaCorreta('B'),
                          caixaCorreta('C'),
                          caixaCorreta('D'),
                        ],
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: isMobile ? size.width * 0.65 : 265,
                        height: 62,
                        child: ElevatedButton(
                          onPressed: salvarEdicao,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB71C1C),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'SALVAR',
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
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
