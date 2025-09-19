import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Conexao {
  static final Conexao _conexao = Conexao._internal();
  factory Conexao() => _conexao;
  Conexao._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'nahero_app.db');
    // deleteDatabase(path);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        senha TEXT NOT NULL,
        criadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        atualizadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        excluidoEm TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE contratos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nomeArquivo TEXT,
        tipoSociedade TEXT,
        clausulas TEXT,
        areaAtuacoes TEXT,
        socios TEXT,
        jsonIA TEXT,
        dataUpload TEXT,
        caminhoArquivo TEXT,
        usuario_id INTEGER NOT NULL,
        criadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        atualizadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        excluidoEm TIMESTAMP,
        FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE modelos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        chave TEXT,
        usuario_id INTEGER NOT NULL,
        criadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        atualizadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        excluidoEm TIMESTAMP,
        FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE recados(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        erroIA TEXT,
        criadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        atualizadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        excluidoEm TIMESTAMP
      )
    ''');
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
