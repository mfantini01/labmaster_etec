import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  Future<void> fazerLogin() async {
    final email = emailController.text.trim();
    final senha = senhaController.text.trim();

    final loginValido = await DatabaseHelper.validarLogin(email, senha);

    if (!mounted) return;

    if (loginValido) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login realizado com sucesso')),
      );
      debugPrint('Login OK');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Email ou senha inválidos')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/fundo_login.png',
              fit: BoxFit.cover,
            ),
          ),

          Center(
            child: Container(
              width: 560,
              height: 710,
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
                children: [
                  Container(
                    height: 205,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFC90000),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'cps',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 18),
                        Text(
                          'Centro Paula Souza',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 40, 40, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'seu.email@etec.sp.gov.br',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        const Text(
                          'Senha',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: senhaController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Digite sua senha',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: fazerLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC90000),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 8,
                            ),
                            child: const Text(
                              'Entrar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  const SizedBox(height: 10),

                  TextButton(
                    onPressed: () {
                      debugPrint("Ir para criar conta");
                    },
                    child: const Text(
                      'Criar conta',
                      style: TextStyle(
                        color: Color(0xFFC90000),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration
                            .underline, // 👈 opcional (estilo link)
                      ),
                    ),
                  ),
                  const Spacer(),

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
                        style: TextStyle(color: Colors.blueGrey, fontSize: 14),
                      ),
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
}
