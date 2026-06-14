import 'dart:io';

import '../database/database_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class TelaAdicionarPerguntas extends StatefulWidget {
  const TelaAdicionarPerguntas({super.key});

  @override
  State<TelaAdicionarPerguntas> createState() => _TelaAdicionarPerguntasState();
}

class _TelaAdicionarPerguntasState extends State<TelaAdicionarPerguntas> {
  final perguntaController = TextEditingController();
  final dicaController = TextEditingController();
  final alternativaAController = TextEditingController();
  final alternativaBController = TextEditingController();
  final alternativaCController = TextEditingController();
  final alternativaDController = TextEditingController();

  String? dificuldade;
  String? caminhoImagem;
  String? alternativaCorreta = 'A';
  String? imagemAlternativaA;
  String? imagemAlternativaB;
  String? imagemAlternativaC;
  String? imagemAlternativaD;

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

  Future<void> escolherImagem() async {
    final resultado = await FilePicker.pickFiles(type: FileType.image);

    if (resultado != null && resultado.files.first.path != null) {
      setState(() {
        caminhoImagem = resultado.files.first.path!;
      });
    }
  }

  Future<void> escolherImagemAlternativa(String letra) async {
    final resultado = await FilePicker.pickFiles(type: FileType.image);

    if (resultado != null && resultado.files.first.path != null) {
      setState(() {
        switch (letra) {
          case 'A':
            imagemAlternativaA = resultado.files.first.path!;
            break;
          case 'B':
            imagemAlternativaB = resultado.files.first.path!;
            break;
          case 'C':
            imagemAlternativaC = resultado.files.first.path!;
            break;
          case 'D':
            imagemAlternativaD = resultado.files.first.path!;
            break;
        }
      });
    }
  }

  Future<void> confirmarPerguntas() async {
    final enunciado = perguntaController.text.trim();
    final dica = dicaController.text.trim();
    final alternativaA = alternativaAController.text.trim();
    final alternativaB = alternativaBController.text.trim();
    final alternativaC = alternativaCController.text.trim();
    final alternativaD = alternativaDController.text.trim();

    if (enunciado.isEmpty ||
        dica.isEmpty ||
        dificuldade == null ||
        (alternativaA.isEmpty && imagemAlternativaA == null) ||
        (alternativaB.isEmpty && imagemAlternativaB == null) ||
        (alternativaC.isEmpty && imagemAlternativaC == null) ||
        (alternativaD.isEmpty && imagemAlternativaD == null) ||
        alternativaCorreta == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preencha todos os campos')));
      return;
    }

    final sucesso = await DatabaseHelper.salvarPerguntas(
      enunciado: enunciado,
      dica: dica,
      dificuldade: int.parse(dificuldade!),
      alternativaA: alternativaA,
      alternativaB: alternativaB,
      alternativaC: alternativaC,
      alternativaD: alternativaD,
      alternativaCorreta: alternativaCorreta!,
      caminhoImagem: caminhoImagem,
      imagemAlternativaA: imagemAlternativaA,
      imagemAlternativaB: imagemAlternativaB,
      imagemAlternativaC: imagemAlternativaC,
      imagemAlternativaD: imagemAlternativaD,
    );

    if (!mounted) return;

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pergunta salva com sucesso')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erro ao salvar pergunta')));
    }
  }

  Widget campoAlternativa(String letra, TextEditingController controller) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;

    String? imagem;

    switch (letra) {
      case 'A':
        imagem = imagemAlternativaA;
        break;
      case 'B':
        imagem = imagemAlternativaB;
        break;
      case 'C':
        imagem = imagemAlternativaC;
        break;
      case 'D':
        imagem = imagemAlternativaD;
        break;
    }

    return Container(
      width: isMobile ? size.width * 0.84 : 330,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Row(
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
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: 'Alternativa $letra',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 48,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => escolherImagemAlternativa(letra),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(Icons.image),
                ),
              ),
            ],
          ),
          if (imagem != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: isMobile ? 130 : 170,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(File(imagem), fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    switch (letra) {
                      case 'A':
                        imagemAlternativaA = null;
                        break;
                      case 'B':
                        imagemAlternativaB = null;
                        break;
                      case 'C':
                        imagemAlternativaC = null;
                        break;
                      case 'D':
                        imagemAlternativaD = null;
                        break;
                    }
                  });
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Remover imagem'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
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

  Widget logoSuperior({required bool isMobile}) {
    return Padding(
      padding: EdgeInsets.only(
        top: isMobile ? 18 : 25,
        left: isMobile ? 18 : 25,
        right: isMobile ? 18 : 30,
      ),
      child: Row(
        mainAxisAlignment: isMobile
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.start,
        children: [
          Image.asset(
            'assets/images/logo_cps_semfundo.png',
            width: isMobile ? 70 : 115,
          ),
          if (isMobile)
            Image.asset('assets/images/logo_labmaster.png', width: 95),
        ],
      ),
    );
  }

  Widget logoLabMasterDesktop() {
    return Positioned(
      top: 30,
      right: 30,
      child: Image.asset('assets/images/logo_labmaster.png', width: 180),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fundo_login.png'),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        child: Stack(
          children: [
            if (!isMobile) logoLabMasterDesktop(),

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(child: logoSuperior(isMobile: isMobile)),
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 22 : 24,
                  isMobile ? 105 : 90,
                  isMobile ? 22 : 24,
                  30,
                ),
                child: Center(
                  child: SizedBox(
                    width: isMobile ? double.infinity : 680,
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: isMobile ? 92 : 105,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          decoration: BoxDecoration(
                            color: Colors.grey[600],
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: TextField(
                            controller: perguntaController,
                            maxLines: null,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile ? 20 : 24,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Pergunta:',
                              hintStyle: TextStyle(
                                color: Colors.white70,
                                fontSize: isMobile ? 22 : 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Container(
                          width: double.infinity,
                          height: isMobile ? 65 : 72,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          decoration: BoxDecoration(
                            color: Colors.grey[500],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: dicaController,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile ? 18 : 20,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Dica:',
                              hintStyle: TextStyle(
                                color: Colors.white70,
                                fontSize: isMobile ? 20 : 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: isMobile ? 14 : 40,
                          runSpacing: 14,
                          children: [
                            Container(
                              width: isMobile ? size.width * 0.38 : 310,
                              height: 60,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[600],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: dificuldade,
                                  hint: Text(
                                    'Dificuldade',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isMobile ? 18 : 22,
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
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isMobile ? 17 : 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(
                              width: isMobile ? size.width * 0.38 : 310,
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
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Imagem',
                                      style: TextStyle(
                                        fontSize: isMobile ? 18 : 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Icon(Icons.add, size: isMobile ? 28 : 34),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        if (caminhoImagem != null) ...[
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            height: isMobile ? 180 : 230,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.45),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.grey.shade400,
                                width: 2,
                              ),
                            ),
                            child: Image.file(
                              File(caminhoImagem!),
                              fit: BoxFit.scaleDown,
                            ),
                          ),
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
                            onPressed: confirmarPerguntas,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB71C1C),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'CONFIRMAR',
                              style: TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
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
          ],
        ),
      ),
    );
  }
}
