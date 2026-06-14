import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class TelaEditarUsuarios extends StatefulWidget {
  const TelaEditarUsuarios({super.key});

  @override
  State<TelaEditarUsuarios> createState() => _TelaEditarUsuariosState();
}

class _TelaEditarUsuariosState extends State<TelaEditarUsuarios> {
  final pesquisaController = TextEditingController();
  List<Map<String, dynamic>> usuarios = [];

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

  Future<void> confirmarExclusao(int usuarioId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir usuário'),
          content: const Text('Tem certeza que deseja excluir este usuário?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      final sucesso = await DatabaseHelper.excluirUsuario(usuarioId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sucesso
                ? 'Usuário excluído com sucesso'
                : 'Erro ao excluir usuário',
          ),
        ),
      );

      pesquisar(pesquisaController.text);
    }
  }

  Future<void> pesquisar(String termo) async {
    final resultado = await DatabaseHelper.pesquisarUsuarios(termo);

    if (!mounted) return;

    setState(() {
      usuarios = resultado;
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

    final auth = Provider.of<AuthProvider>(context, listen: false);
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
                          'Editar Usuários',
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
                                  ? 'Digite o nome do usu...'
                                  : 'Digite o nome do usuário',
                              hintStyle: TextStyle(
                                color: Colors.white70,
                                fontSize: isMobile ? 19 : 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        if (usuarios.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.75),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Text(
                              'Nenhum usuário encontrado',
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
                            itemCount: usuarios.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final usuario = usuarios[index];
                              final usuarioLogado =
                                  usuario['id'] == auth.usuarioId;

                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TelaFormularioEditarUsuarios(
                                            usuarioId: usuario['id'],
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
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.person,
                                        color: Color(0xFFB71C1C),
                                        size: 32,
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    usuario['nome'] ?? '',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: isMobile
                                                          ? 18
                                                          : 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),

                                                if (usuarioLogado)
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                          left: 8,
                                                        ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 3,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: const Text(
                                                      'VOCÊ',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              usuario['email'] ?? '',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: isMobile ? 14 : 16,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (!usuarioLogado)
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed: () {
                                                confirmarExclusao(
                                                  usuario['id'],
                                                );
                                              },
                                            ),
                                          const Icon(
                                            Icons.arrow_forward_ios,
                                            size: 20,
                                            color: Colors.black54,
                                          ),
                                        ],
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
      ),
    );
  }
}

class TelaFormularioEditarUsuarios extends StatefulWidget {
  final int usuarioId;

  const TelaFormularioEditarUsuarios({super.key, required this.usuarioId});

  @override
  State<TelaFormularioEditarUsuarios> createState() =>
      _TelaFormularioEditarUsuariosState();
}

class _TelaFormularioEditarUsuariosState
    extends State<TelaFormularioEditarUsuarios> {
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  String? tipoUsuario;
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarUsuario();
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  Future<void> carregarUsuario() async {
    final usuario = await DatabaseHelper.buscarUsuarioPorId(widget.usuarioId);

    if (!mounted) return;

    if (usuario == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Usuário não encontrado')));
      Navigator.pop(context);
      return;
    }

    nomeController.text = usuario['nome']?.toString() ?? '';
    emailController.text = usuario['email']?.toString() ?? '';
    tipoUsuario = usuario['tipo']?.toString();

    setState(() {
      carregando = false;
    });
  }

  Future<void> salvarEdicao() async {
    if (nomeController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        tipoUsuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios')),
      );
      return;
    }

    final sucesso = await DatabaseHelper.atualizarUsuarioPorId(
      usuarioId: widget.usuarioId,
      nome: nomeController.text.trim(),
      email: emailController.text.trim(),
      senha: senhaController.text.trim().isEmpty
          ? null
          : senhaController.text.trim(),
      tipoUsuario: tipoUsuario!,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sucesso
              ? 'Usuário atualizado com sucesso'
              : 'Erro ao atualizar usuário',
        ),
      ),
    );

    if (sucesso) Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;

    if (carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                  isMobile ? 120 : 105,
                  isMobile ? 22 : 24,
                  30,
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: isMobile ? double.infinity : 680,
                    child: Column(
                      children: [
                        Text(
                          'Editar Usuário',
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
                          hint: 'Nova senha, opcional:',
                          icon: Icons.lock,
                          obscureText: true,
                        ),

                        const SizedBox(height: 14),

                        Container(
                          width: double.infinity,
                          height: 70,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          decoration: BoxDecoration(
                            color: Colors.grey[600],
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: tipoUsuario,
                              dropdownColor: Colors.grey[700],
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white,
                              ),
                              isExpanded: true,
                              hint: const Text(
                                'Tipo de usuário',
                                style: TextStyle(color: Colors.white70),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'professor',
                                  child: Text('Professor'),
                                ),
                                DropdownMenuItem(
                                  value: 'aluno',
                                  child: Text('Aluno'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  tipoUsuario = value;
                                });
                              },
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isMobile ? 19 : 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 26),

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
