import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class DatabaseHelper {
  static Database? _db;

  static String gerarHashSenha(String senha) {
    final bytes = utf8.encode(senha);
    final hash = sha256.convert(bytes).toString();

    return hash;
  }

  static bool senhaJaEstaComHash(String senha) {
    final regex = RegExp(r'^[a-f0-9]{64}$');
    return regex.hasMatch(senha);
  }

  static Future<Database> getDatabase() async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'labmaster.db');

    _db = await openDatabase(
      path,
      version: 2,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _createTables(db);
        await _insertInitialData(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _migrarSenhasParaHash(db);
        }
      },
    );
    return _db!;
  }

  static Future<void> _migrarSenhasParaHash(Database db) async {
    final usuarios = await db.query('usuarios', columns: ['id', 'senha_hash']);

    for (final usuario in usuarios) {
      final id = usuario['id'] as int;
      final senhaAtual = usuario['senha_hash']?.toString() ?? '';

      if (!senhaJaEstaComHash(senhaAtual)) {
        await db.update(
          'usuarios',
          {'senha_hash': gerarHashSenha(senhaAtual)},
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    }
  }

  static Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        senha_hash TEXT NOT NULL,
        tipo TEXT NOT NULL CHECK(tipo IN ('aluno','professor')),
        ativo INTEGER DEFAULT 1,
        criado_em DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE imagens (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        caminho TEXT NOT NULL,
        descricao_alt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE materiais (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        descricao TEXT,
        funcao TEXT,
        categoria TEXT,
        imagem_id INTEGER,
        FOREIGN KEY(imagem_id) REFERENCES imagens(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE sistemas_experimentais (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        descricao TEXT,
        imagem_id INTEGER,
        FOREIGN KEY(imagem_id) REFERENCES imagens(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE questoes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        enunciado TEXT NOT NULL,
        dificuldade INTEGER NOT NULL CHECK(dificuldade IN (1,2,3)),
        tempo_limite INTEGER,
        dica TEXT,
        material_id INTEGER,
        sistema_id INTEGER,
        imagem_id INTEGER,
        professor_id INTEGER,
        ativa INTEGER DEFAULT 1,
        FOREIGN KEY(material_id) REFERENCES materiais(id),
        FOREIGN KEY(sistema_id) REFERENCES sistemas_experimentais(id),
        FOREIGN KEY(imagem_id) REFERENCES imagens(id),
        FOREIGN KEY(professor_id) REFERENCES usuarios(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE alternativas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        questao_id INTEGER NOT NULL,
        texto TEXT,
        imagem_id INTEGER,
        correta INTEGER DEFAULT 0 CHECK(correta IN (0,1)),
        FOREIGN KEY(questao_id) REFERENCES questoes(id),
        FOREIGN KEY(imagem_id) REFERENCES imagens(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE ajudas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        tipo TEXT NOT NULL CHECK(tipo IN ('cinquenta_cinquenta','dica','pular_questao')),
        limite_uso INTEGER DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE partidas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        aluno_id INTEGER NOT NULL,
        nivel_atual INTEGER DEFAULT 1 CHECK(nivel_atual IN (1,2,3)),
        pontuacao INTEGER DEFAULT 0,
        acertos INTEGER DEFAULT 0,
        erros INTEGER DEFAULT 0,
        data_inicio DATETIME DEFAULT CURRENT_TIMESTAMP,
        data_fim DATETIME,
        FOREIGN KEY(aluno_id) REFERENCES usuarios(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE inventario_ajudas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        partida_id INTEGER NOT NULL,
        ajuda_id INTEGER NOT NULL,
        usos_restantes INTEGER DEFAULT 1,
        FOREIGN KEY(partida_id) REFERENCES partidas(id),
        FOREIGN KEY(ajuda_id) REFERENCES ajudas(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE uso_ajudas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        partida_id INTEGER NOT NULL,
        ajuda_id INTEGER NOT NULL,
        questao_id INTEGER,
        usado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(partida_id) REFERENCES partidas(id),
        FOREIGN KEY(ajuda_id) REFERENCES ajudas(id),
        FOREIGN KEY(questao_id) REFERENCES questoes(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE respostas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        partida_id INTEGER NOT NULL,
        questao_id INTEGER NOT NULL,
        alternativa_id INTEGER,
        acertou INTEGER NOT NULL CHECK(acertou IN (0,1)),
        tempo_gasto INTEGER,
        pulada INTEGER DEFAULT 0 CHECK(pulada IN (0,1)),
        FOREIGN KEY(partida_id) REFERENCES partidas(id),
        FOREIGN KEY(questao_id) REFERENCES questoes(id),
        FOREIGN KEY(alternativa_id) REFERENCES alternativas(id)
      )
    ''');
  }

  static Future<void> _insertInitialData(Database db) async {
    await db.insert('usuarios', {
      'nome': 'Professor Admin',
      'email': 'professor@cps.sp.gov.br',
      'senha_hash': gerarHashSenha('123456'),
      'tipo': 'professor',
    });

    await db.rawInsert('''
      INSERT INTO ajudas(nome, tipo, limite_uso)
      VALUES
      ('50/50', 'cinquenta_cinquenta', 1),
      ('Dica', 'dica', 1),
      ('Pular Questão', 'pular_questao', 1)
    ''');

    await db.rawInsert('''
      INSERT INTO sistemas_experimentais (nome)
      VALUES
      ('Filtração Simples'),
      ('Filtração a Vácuo'),
      ('Destilação Simples'),
      ('Destilação Fracionada'),
      ('Refluxo'),
      ('Extração Soxhlet'),
      ('Destilação por Arraste a Vapor'),
      ('Titulação'),
      ('Extração Líquido-Líquido')
    ''');
  }

  static Future<bool> validarLogin(String email, String senha) async {
    final db = await getDatabase();

    final resultado = await db.query(
      'usuarios',
      where: 'email = ? AND senha_hash = ? AND ativo = 1',
      whereArgs: [email, gerarHashSenha(senha)],
    );

    return resultado.isNotEmpty;
  }

  static Future<bool> criarUsuario(
    String nome,
    String email,
    String senha,
  ) async {
    final db = await getDatabase();

    try {
      String tipo;

      if (email.endsWith('@aluno.cps.sp.gov.br')) {
        tipo = 'aluno';
      } else if (email.endsWith('@cps.sp.gov.br')) {
        tipo = 'professor';
      } else {
        return false;
      }

      await db.insert('usuarios', {
        'nome': nome,
        'email': email,
        'senha_hash': gerarHashSenha(senha),
        'tipo': tipo,
        'ativo': 1,
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<String?> buscarTipoUsuario(String email, String senha) async {
    final db = await getDatabase();

    final resultado = await db.query(
      'usuarios',
      columns: ['tipo'],
      where: 'email = ? AND senha_hash = ? AND ativo = 1',
      whereArgs: [email, gerarHashSenha(senha)],
      limit: 1,
    );

    if (resultado.isEmpty) return null;

    return resultado.first['tipo'] as String;
  }

  static Future<Map<String, dynamic>?> buscarUsuario(
    String email,
    String senha,
  ) async {
    final db = await getDatabase();

    final resultado = await db.query(
      'usuarios',
      columns: ['id', 'nome', 'email', 'tipo'],
      where: 'email = ? AND senha_hash = ? AND ativo = 1',
      whereArgs: [email, gerarHashSenha(senha)],
      limit: 1,
    );

    if (resultado.isEmpty) return null;

    return resultado.first;
  }

  static Future<bool> salvarPerguntas({
    required String enunciado,
    required String dica,
    required int dificuldade,
    required String alternativaA,
    required String alternativaB,
    required String alternativaC,
    required String alternativaD,
    required String alternativaCorreta,
    String? caminhoImagem,
    String? imagemAlternativaA,
    String? imagemAlternativaB,
    String? imagemAlternativaC,
    String? imagemAlternativaD,
  }) async {
    final db = await getDatabase();

    try {
      int? imagemId;

      if (caminhoImagem != null && caminhoImagem.isNotEmpty) {
        imagemId = await db.insert('imagens', {
          'caminho': caminhoImagem,
          'descricao_alt': enunciado,
        });
      }

      final questaoId = await db.insert('questoes', {
        'enunciado': enunciado,
        'dificuldade': dificuldade,
        'dica': dica,
        'imagem_id': imagemId,
        'ativa': 1,
      });

      Future<int?> salvarImagemAlternativa(
        String? caminho,
        String descricao,
      ) async {
        if (caminho == null || caminho.isEmpty) return null;

        return await db.insert('imagens', {
          'caminho': caminho,
          'descricao_alt': descricao,
        });
      }

      final alternativas = [
        {'letra': 'A', 'texto': alternativaA, 'imagem': imagemAlternativaA},
        {'letra': 'B', 'texto': alternativaB, 'imagem': imagemAlternativaB},
        {'letra': 'C', 'texto': alternativaC, 'imagem': imagemAlternativaC},
        {'letra': 'D', 'texto': alternativaD, 'imagem': imagemAlternativaD},
      ];

      for (final item in alternativas) {
        final imagemAlternativaId = await salvarImagemAlternativa(
          item['imagem'],
          item['texto'] ?? '',
        );

        await db.insert('alternativas', {
          'questao_id': questaoId,
          'texto': item['texto'],
          'imagem_id': imagemAlternativaId,
          'correta': item['letra'] == alternativaCorreta ? 1 : 0,
        });
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> atualizarUsuario({
    required String emailAtual,
    required String novoEmail,
    required String novaSenha,
  }) async {
    final db = await getDatabase();

    try {
      String tipo;

      if (novoEmail.endsWith('@aluno.cps.sp.gov.br')) {
        tipo = 'aluno';
      } else if (novoEmail.endsWith('@cps.sp.gov.br')) {
        tipo = 'professor';
      } else {
        return false;
      }

      final linhasAfetadas = await db.update(
        'usuarios',
        {
          'email': novoEmail,
          'senha_hash': gerarHashSenha(novaSenha),
          'tipo': tipo,
        },
        where: 'email = ?',
        whereArgs: [emailAtual],
      );

      return linhasAfetadas > 0;
    } catch (e) {
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> pesquisarPerguntas(
    String termo,
  ) async {
    final db = await getDatabase();

    final todas = await db.query(
      'questoes',
      where: 'ativa = 1',
      orderBy: 'id DESC',
    );

    if (termo.trim().isEmpty) {
      return todas;
    }

    String normalizar(String texto) {
      return texto
          .toLowerCase()
          .replaceAll('á', 'a')
          .replaceAll('à', 'a')
          .replaceAll('ã', 'a')
          .replaceAll('â', 'a')
          .replaceAll('é', 'e')
          .replaceAll('ê', 'e')
          .replaceAll('í', 'i')
          .replaceAll('ó', 'o')
          .replaceAll('ô', 'o')
          .replaceAll('õ', 'o')
          .replaceAll('ú', 'u')
          .replaceAll('ç', 'c');
    }

    final termoNormalizado = normalizar(termo);

    return todas.where((pergunta) {
      final enunciado = normalizar(pergunta['enunciado']?.toString() ?? '');
      return enunciado.contains(termoNormalizado);
    }).toList();
  }

  static Future<Map<String, dynamic>?> buscarPerguntaCompleta(
    int questaoId,
  ) async {
    final db = await getDatabase();

    final questoes = await db.rawQuery(
      '''
    SELECT q.*, i.caminho AS caminho_imagem
    FROM questoes q
    LEFT JOIN imagens i ON i.id = q.imagem_id
    WHERE q.id = ?
    LIMIT 1
    ''',
      [questaoId],
    );

    if (questoes.isEmpty) return null;

    final alternativas = await db.rawQuery(
      '''
    SELECT a.*, i.caminho AS caminho_imagem_alternativa
    FROM alternativas a
    LEFT JOIN imagens i ON i.id = a.imagem_id
    WHERE a.questao_id = ?
    ORDER BY a.id ASC
    ''',
      [questaoId],
    );

    return {'questao': questoes.first, 'alternativas': alternativas};
  }

  static Future<bool> atualizarPerguntas({
    required int questaoId,
    required String enunciado,
    required String dica,
    required int dificuldade,
    required String alternativaA,
    required String alternativaB,
    required String alternativaC,
    required String alternativaD,
    required String alternativaCorreta,
    String? caminhoImagem,
    String? imagemAlternativaA,
    String? imagemAlternativaB,
    String? imagemAlternativaC,
    String? imagemAlternativaD,
  }) async {
    final db = await getDatabase();

    try {
      int? imagemId;

      if (caminhoImagem != null && caminhoImagem.isNotEmpty) {
        imagemId = await db.insert('imagens', {
          'caminho': caminhoImagem,
          'descricao_alt': enunciado,
        });
      }

      final Map<String, dynamic> dadosQuestao = {
        'enunciado': enunciado,
        'dificuldade': dificuldade,
        'dica': dica,
        'ativa': 1,
        'imagem_id': imagemId,
      };

      await db.update(
        'questoes',
        dadosQuestao,
        where: 'id = ?',
        whereArgs: [questaoId],
      );

      await db.delete(
        'alternativas',
        where: 'questao_id = ?',
        whereArgs: [questaoId],
      );

      Future<int?> salvarImagemAlternativa(
        String? caminho,
        String descricao,
      ) async {
        if (caminho == null || caminho.isEmpty) return null;

        return await db.insert('imagens', {
          'caminho': caminho,
          'descricao_alt': descricao,
        });
      }

      final alternativas = [
        {'letra': 'A', 'texto': alternativaA, 'imagem': imagemAlternativaA},
        {'letra': 'B', 'texto': alternativaB, 'imagem': imagemAlternativaB},
        {'letra': 'C', 'texto': alternativaC, 'imagem': imagemAlternativaC},
        {'letra': 'D', 'texto': alternativaD, 'imagem': imagemAlternativaD},
      ];

      for (final item in alternativas) {
        final imagemAlternativaId = await salvarImagemAlternativa(
          item['imagem'],
          item['texto'] ?? '',
        );

        await db.insert('alternativas', {
          'questao_id': questaoId,
          'texto': item['texto'],
          'imagem_id': imagemAlternativaId,
          'correta': item['letra'] == alternativaCorreta ? 1 : 0,
        });
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> excluirPergunta(int questaoId) async {
    final db = await getDatabase();

    try {
      final linhasAfetadas = await db.update(
        'questoes',
        {'ativa': 0},
        where: 'id = ?',
        whereArgs: [questaoId],
      );

      return linhasAfetadas > 0;
    } catch (e) {
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> buscarPerguntasParaJogo() async {
    final db = await getDatabase();

    final questoes = await db.rawQuery('''
    SELECT q.*, i.caminho AS caminho_imagem
    FROM questoes q
    LEFT JOIN imagens i ON i.id = q.imagem_id
    WHERE q.ativa = 1
    ORDER BY RANDOM()
    LIMIT 10
  ''');

    List<Map<String, dynamic>> resultado = [];

    for (final questao in questoes) {
      final alternativas = await db.rawQuery(
        '''
      SELECT a.*, i.caminho AS caminho_imagem_alternativa
      FROM alternativas a
      LEFT JOIN imagens i ON i.id = a.imagem_id
      WHERE a.questao_id = ?
      ORDER BY a.id ASC
    ''',
        [questao['id']],
      );

      resultado.add({'questao': questao, 'alternativas': alternativas});
    }

    return resultado;
  }

  static Future<List<Map<String, dynamic>>> pesquisarUsuarios(
    String termo,
  ) async {
    final db = await getDatabase();

    final todos = await db.query(
      'usuarios',
      where: 'ativo = 1',
      orderBy: 'id DESC',
    );

    if (termo.trim().isEmpty) {
      return todos;
    }

    String normalizar(String texto) {
      return texto
          .toLowerCase()
          .replaceAll('á', 'a')
          .replaceAll('à', 'a')
          .replaceAll('ã', 'a')
          .replaceAll('â', 'a')
          .replaceAll('é', 'e')
          .replaceAll('ê', 'e')
          .replaceAll('í', 'i')
          .replaceAll('ó', 'o')
          .replaceAll('ô', 'o')
          .replaceAll('õ', 'o')
          .replaceAll('ú', 'u')
          .replaceAll('ç', 'c');
    }

    final termoNormalizado = normalizar(termo);

    return todos.where((usuario) {
      final nome = normalizar(usuario['nome']?.toString() ?? '');
      final email = normalizar(usuario['email']?.toString() ?? '');

      return nome.contains(termoNormalizado) ||
          email.contains(termoNormalizado);
    }).toList();
  }

  static Future<Map<String, dynamic>?> buscarUsuarioPorId(int usuarioId) async {
    final db = await getDatabase();

    final resultado = await db.query(
      'usuarios',
      columns: ['id', 'nome', 'email', 'tipo', 'ativo'],
      where: 'id = ? AND ativo = 1',
      whereArgs: [usuarioId],
      limit: 1,
    );

    if (resultado.isEmpty) return null;

    return resultado.first;
  }

  static Future<bool> atualizarUsuarioPorId({
    required int usuarioId,
    required String nome,
    required String email,
    String? senha,
    required String tipoUsuario,
  }) async {
    final db = await getDatabase();

    try {
      final dados = <String, dynamic>{
        'nome': nome,
        'email': email,
        'tipo': tipoUsuario,
      };

      if (senha != null && senha.isNotEmpty) {
        dados['senha_hash'] = gerarHashSenha(senha);
      }

      final linhasAfetadas = await db.update(
        'usuarios',
        dados,
        where: 'id = ?',
        whereArgs: [usuarioId],
      );

      return linhasAfetadas > 0;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> excluirUsuario(int usuarioId) async {
    final db = await getDatabase();

    try {
      final linhasAfetadas = await db.update(
        'usuarios',
        {'ativo': 0},
        where: 'id = ?',
        whereArgs: [usuarioId],
      );

      return linhasAfetadas > 0;
    } catch (e) {
      return false;
    }
  }
}
