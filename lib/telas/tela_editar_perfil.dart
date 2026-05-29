import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class TelaEditarPerfil extends StatefulWidget {
  final String emailAtual;
  final String senhaAtual;

  const TelaEditarPerfil({
    super.key,
    required this.emailAtual,
    required this.senhaAtual,
  });

  @override
  State<TelaEditarPerfil> createState() => _TelaEditarPerfilState();
}

class _TelaEditarPerfilState extends State<TelaEditarPerfil> {
  late TextEditingController emailController;
  late TextEditingController senhaController;

  bool mostrarSenha = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.emailAtual);
    senhaController = TextEditingController(text: widget.senhaAtual);
  }

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  Future<void> salvarAlteracoes() async {
    final novoEmail = emailController.text.trim();
    final novaSenha = senhaController.text.trim();

    if (novoEmail.isEmpty || novaSenha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    final sucesso = await DatabaseHelper.atualizarUsuario(
      emailAtual: widget.emailAtual,
      novoEmail: novoEmail,
      novaSenha: novaSenha,
    );

    if (!mounted) return;

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso')),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível atualizar o perfil')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Scaffold(
      resizeToAvoidBottomInset: true,
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

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  24,
                  isMobile ? 80 : 40,
                  24,
                  24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/logo_labmaster.png',
                        width: isMobile ? size.width * 0.68 : 440,
                        fit: BoxFit.contain,
                      ),

                      SizedBox(height: isMobile ? 28 : 35),

                      Container(
                        padding: EdgeInsets.all(isMobile ? 28 : 36),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.96),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.35),
                              blurRadius: 25,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Editar Perfil',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFC90000),
                              ),
                            ),

                            const SizedBox(height: 30),

                            TextField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),

                            const SizedBox(height: 22),

                            TextField(
                              controller: senhaController,
                              obscureText: !mostrarSenha,
                              decoration: InputDecoration(
                                labelText: 'Senha',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    mostrarSenha
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      mostrarSenha = !mostrarSenha;
                                    });
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            SizedBox(
                              width: double.infinity,
                              height: 58,
                              child: ElevatedButton(
                                onPressed: salvarAlteracoes,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD32F2F),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Confirmar Alteração',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
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
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
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