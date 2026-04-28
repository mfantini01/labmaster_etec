import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {

  static Database? _db;

  static Future<Database> getDatabase() async {

    if (_db != null) {
      return _db!;
    }

    final dbPath = await getDatabasesPath();

    final path = join(
      dbPath,
      'labmaster.db'
    );

    _db = await openDatabase(
      path,
      version: 1,

      onConfigure: (db) async {
        await db.execute(
          'PRAGMA foreign_keys = ON'
        );
      },

      onCreate: (db, version) async {

        await _createTables(db);

        await _insertInitialData(db);

        print(
          'Banco LabMaster criado com sucesso'
        );
      },
    );

    return _db!;
  }

  static Future<void> _createTables(
    Database db
  ) async {

    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        senha_hash TEXT NOT NULL,
        tipo TEXT NOT NULL CHECK(
          tipo IN (
            'aluno',
            'professor'
          )
        ),
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

        FOREIGN KEY(imagem_id)
        REFERENCES imagens(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE sistemas_experimentais (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        descricao TEXT,
        imagem_id INTEGER,

        FOREIGN KEY(imagem_id)
        REFERENCES imagens(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE questoes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        enunciado TEXT NOT NULL,

        dificuldade INTEGER NOT NULL CHECK(
          dificuldade IN (1,2,3)
        ),

        tempo_limite INTEGER,
        dica TEXT,

        material_id INTEGER,
        sistema_id INTEGER,
        imagem_id INTEGER,

        professor_id INTEGER,

        ativa INTEGER DEFAULT 1,

        FOREIGN KEY(material_id)
        REFERENCES materiais(id),

        FOREIGN KEY(sistema_id)
        REFERENCES sistemas_experimentais(id),

        FOREIGN KEY(imagem_id)
        REFERENCES imagens(id),

        FOREIGN KEY(professor_id)
        REFERENCES usuarios(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE alternativas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        questao_id INTEGER NOT NULL,

        texto TEXT,
        imagem_id INTEGER,

        correta INTEGER DEFAULT 0 CHECK(
          correta IN (0,1)
        ),

        FOREIGN KEY(questao_id)
        REFERENCES questoes(id),

        FOREIGN KEY(imagem_id)
        REFERENCES imagens(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE ajudas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        nome TEXT NOT NULL,

        tipo TEXT NOT NULL CHECK(
          tipo IN (
            'cinquenta_cinquenta',
            'dica',
            'pular_questao'
          )
        ),

        limite_uso INTEGER DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE partidas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        aluno_id INTEGER NOT NULL,

        nivel_atual INTEGER DEFAULT 1 CHECK(
          nivel_atual IN (1,2,3)
        ),

        pontuacao INTEGER DEFAULT 0,
        acertos INTEGER DEFAULT 0,
        erros INTEGER DEFAULT 0,

        data_inicio DATETIME DEFAULT CURRENT_TIMESTAMP,
        data_fim DATETIME,

        FOREIGN KEY(aluno_id)
        REFERENCES usuarios(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE inventario_ajudas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        partida_id INTEGER NOT NULL,
        ajuda_id INTEGER NOT NULL,

        usos_restantes INTEGER DEFAULT 1,

        FOREIGN KEY(partida_id)
        REFERENCES partidas(id),

        FOREIGN KEY(ajuda_id)
        REFERENCES ajudas(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE uso_ajudas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        partida_id INTEGER NOT NULL,
        ajuda_id INTEGER NOT NULL,
        questao_id INTEGER,

        usado_em DATETIME DEFAULT CURRENT_TIMESTAMP,

        FOREIGN KEY(partida_id)
        REFERENCES partidas(id),

        FOREIGN KEY(ajuda_id)
        REFERENCES ajudas(id),

        FOREIGN KEY(questao_id)
        REFERENCES questoes(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE respostas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        partida_id INTEGER NOT NULL,
        questao_id INTEGER NOT NULL,
        alternativa_id INTEGER,

        acertou INTEGER NOT NULL CHECK(
          acertou IN (0,1)
        ),

        tempo_gasto INTEGER,

        pulada INTEGER DEFAULT 0 CHECK(
          pulada IN (0,1)
        ),

        FOREIGN KEY(partida_id)
        REFERENCES partidas(id),

        FOREIGN KEY(questao_id)
        REFERENCES questoes(id),

        FOREIGN KEY(alternativa_id)
        REFERENCES alternativas(id)
      )
    ''');
  }

  static Future<void> _insertInitialData(
    Database db
  ) async {

    await db.insert(
      'usuarios',
      {
        'nome': 'Professor Admin',
        'email': 'professor@etec.sp.gov.br',
        'senha_hash': '123456',
        'tipo': 'professor'
      }
    );

    await db.rawInsert('''
      INSERT INTO ajudas(
        nome,
        tipo,
        limite_uso
      )
      VALUES
      (
        '50/50',
        'cinquenta_cinquenta',
        1
      ),
      (
        'Dica',
        'dica',
        1
      ),
      (
        'Pular Questão',
        'pular_questao',
        1
      )
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
}