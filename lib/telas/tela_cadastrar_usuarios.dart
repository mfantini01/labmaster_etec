import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class TelaCadastrarUsuario extends StatefulWidget {
  const TelaCadastrarUsuario({super.key});

  @override
  State<TelaCadastrarUsuario> createState() => _TelaCadastrarUsuarioState();
}

class _TelaCadastrarUsuarioState extends State<TelaCadastrarUsuario> {
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  Future<void> cadastrarUsuario() async {
    if (nomeController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        senhaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preencha todos os campos')));
      return;
    }

    final sucesso = await DatabaseHelper.criarUsuario(
      nomeController.text.trim(),
      emailController.text.trim(),
      senhaController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sucesso
              ? 'Usuário cadastrado com sucesso'
              : 'E-mail inválido ou usuário já existe',
        ),
      ),
    );

    if (sucesso) Navigator.pop(context);
  }

  Widget campoTexto({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
  }) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;

    return Container(
      width: double.infinity,
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.grey[600],
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(
          color: Colors.white,
          fontSize: isMobile ? 19 : 22,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(icon, color: Colors.white, size: 30),
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white70,
            fontSize: isMobile ? 19 : 22,
            fontWeight: FontWeight.bold,
          ),
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
      resizeToAvoidBottomInset: true,
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
                  isMobile ? 120 : 105,
                  isMobile ? 22 : 24,
                  30,
                ),
                child: Center(
                  child: SizedBox(
                    width: isMobile ? double.infinity : 680,
                    child: Column(
                      children: [
                        Text(
                          'Adicionar Usuário',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isMobile ? 30 : 34,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFB71C1C),
                          ),
                        ),

                        const SizedBox(height: 28),

                        campoTexto(
                          controller: nomeController,
                          hint: 'Nome:',
                          icon: Icons.person,
                        ),

                        const SizedBox(height: 14),

                        campoTexto(
                          controller: emailController,
                          hint: 'E-mail:',
                          icon: Icons.email,
                        ),

                        const SizedBox(height: 14),

                        campoTexto(
                          controller: senhaController,
                          hint: 'Senha:',
                          icon: Icons.lock,
                          obscureText: true,
                        ),

                        const SizedBox(height: 14),

                        const SizedBox(height: 26),

                        SizedBox(
                          width: isMobile ? size.width * 0.65 : 265,
                          height: 62,
                          child: ElevatedButton(
                            onPressed: cadastrarUsuario,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB71C1C),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'CADASTRAR',
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
