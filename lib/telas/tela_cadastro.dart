// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  bool mostrarSenha = false;

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  Future<void> criarConta() async {
    final nome = nomeController.text.trim();
    final email = emailController.text.trim();
    final senha = senhaController.text.trim();

    if (nome.isEmpty || email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preencha todos os campos')));
      return;
    }

    final emailValido = email.endsWith('@cps') || email.endsWith('@aluno.cps');

    if (!emailValido) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Use um email @aluno.cps ou @cps')),
      );
      return;
    }

    final sucesso = await DatabaseHelper.criarUsuario(nome, email, senha);

    if (!mounted) return;

    if (sucesso) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Conta criada com sucesso')));

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este email já está cadastrado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/fundo_login.png',
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 150.250,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xFFC90000),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(18),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/logo2_cps.png',
                                width: 145,
                                fit: BoxFit.contain,
                              ),

                              const SizedBox(height: 8),

                              const Text(
                                'Crie sua conta',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(40, 34, 40, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Nome',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: nomeController,
                                decoration: InputDecoration(
                                  hintText: 'Digite seu nome',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 22),

                              const Text(
                                'Email',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  hintText: 'seu.email@cps',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 22),

                              const Text(
                                'Senha',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: senhaController,
                                obscureText: !mostrarSenha,
                                decoration: InputDecoration(
                                  hintText: 'Digite sua senha',

                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
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

                              const SizedBox(height: 28),

                              SizedBox(
                                width: double.infinity,
                                height: 60,
                                child: ElevatedButton(
                                  onPressed: criarConta,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFC90000),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 8,
                                  ),
                                  child: const Text(
                                    'Cadastrar',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'Já tenho conta',
                                    style: TextStyle(
                                      color: Color(0xFFC90000),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          height: 60,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF3F3F3),
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(18),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              '© 2026 Centro Paula Souza - ETEC',
                              style: TextStyle(
                                color: Colors.blueGrey,
                                fontSize: 14,
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
          ),
        ],
      ),
    );
  }
}
