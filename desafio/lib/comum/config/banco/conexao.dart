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
    return await openDatabase(
      path,
      version: 8,

      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
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
        nome TEXT NOT NULL,
        descricao TEXT,
        status TEXT DEFAULT 'Rascunho',
        caminho TEXT,
        usuario_id INTEGER NOT NULL,
        criadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        atualizadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        excluidoEm TIMESTAMP,
        FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE clausulas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        texto TEXT NOT NULL,
        tipo TEXT NOT NULL,
        status TEXT DEFAULT 'Ativa',
        contrato_id INTEGER NOT NULL,
        criadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        atualizadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        excluidoEm TIMESTAMP,
        FOREIGN KEY (contrato_id) REFERENCES contratos (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE modelos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        chave TEXT,
        usuario_id INTEGER NOT NULL,
        clausula_id INTEGER,
        criadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        atualizadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        excluidoEm TIMESTAMP,
        FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE,
        FOREIGN KEY (clausula_id) REFERENCES clausulas (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE recados(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        erroIA TEXT,
        modeloIA TEXT,
        conteudoAnalise TEXT,
        nomeArquivo TEXT,
        criadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        atualizadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        excluidoEm TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE socios(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        statusSocial TEXT NOT NULL,
        dataNascimento TEXT NOT NULL,
        cpf TEXT NOT NULL,
        residencia TEXT NOT NULL,
        criadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        atualizadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        excluidoEm TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE objetos_sociais(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        atividadesEconomicas TEXT NOT NULL,
        atividadesExercidas TEXT NOT NULL,
        criadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        atualizadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        excluidoEm TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE clausulas_genericas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nomeClausula TEXT NOT NULL,
        conteudo TEXT NOT NULL,
        recado_id INTEGER,
        criadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        atualizadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        excluidoEm TIMESTAMP,
        FOREIGN KEY (recado_id) REFERENCES recados (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE prazos_duracao(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipoPrazo TEXT NOT NULL,
        criadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        atualizadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        excluidoEm TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE capitais_sociais(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        valorTotal REAL NOT NULL,
        divisaoQuotas TEXT NOT NULL,
        formaIntegralizacao TEXT NOT NULL,
        clausula_id INTEGER NOT NULL,
        criadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        atualizadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        excluidoEm TIMESTAMP,
        FOREIGN KEY (clausula_id) REFERENCES clausulas (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE sedes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        enderecoCompleto TEXT NOT NULL,
        clausula_id INTEGER NOT NULL,
        criadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        atualizadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        excluidoEm TIMESTAMP,
        FOREIGN KEY (clausula_id) REFERENCES clausulas (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE administracoes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nomeAdministrador TEXT NOT NULL,
        poderesAdministrativos TEXT NOT NULL,
        clausula_id INTEGER NOT NULL,
        criadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        atualizadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        excluidoEm TIMESTAMP,
        FOREIGN KEY (clausula_id) REFERENCES clausulas (id) ON DELETE CASCADE
      )
    ''');

    // Índices
    await db.execute(
      'CREATE INDEX idx_contratos_usuario_id ON contratos(usuario_id)',
    );
    await db.execute('CREATE INDEX idx_contratos_status ON contratos(status)');
    await db.execute(
      'CREATE INDEX idx_clausulas_contrato_id ON clausulas(contrato_id)',
    );
    await db.execute('CREATE INDEX idx_clausulas_tipo ON clausulas(tipo)');
    await db.execute('CREATE INDEX idx_clausulas_status ON clausulas(status)');
    await db.execute(
      'CREATE INDEX idx_clausulas_genericas_nomeClausula ON clausulas_genericas(nomeClausula)',
    );
    await db.execute(
      'CREATE INDEX idx_prazos_duracao_tipoPrazo ON prazos_duracao(tipoPrazo)',
    );
    await db.execute(
      'CREATE INDEX idx_capitais_sociais_clausula_id ON capitais_sociais(clausula_id)',
    );
    await db.execute(
      'CREATE INDEX idx_sedes_clausula_id ON sedes(clausula_id)',
    );
    await db.execute(
      'CREATE INDEX idx_administracoes_clausula_id ON administracoes(clausula_id)',
    );
    await db.execute(
      'CREATE INDEX idx_administracoes_nomeAdministrador ON administracoes(nomeAdministrador)',
    );
    await db.execute('CREATE INDEX idx_socios_nome ON socios(nome)');
    await db.execute('CREATE INDEX idx_socios_cpf ON socios(cpf)');
    await db.execute('CREATE INDEX idx_socios_status ON socios(statusSocial)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migração da versão 1 para 2
    if (oldVersion < 2) {
      var result = await db.rawQuery(
        "SELECT sql FROM sqlite_master WHERE type='table' AND name='contratos'",
      );

      if (result.isNotEmpty) {
        await db.execute('''
          CREATE TABLE contratos_backup AS 
          SELECT * FROM contratos
        ''');
        await db.execute('DROP TABLE contratos');

        await db.execute('''
          CREATE TABLE contratos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            descricao TEXT,
            status TEXT DEFAULT 'Rascunho',
            caminho TEXT,
            usuario_id INTEGER NOT NULL,
            criadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            atualizadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            excluidoEm TIMESTAMP,
            FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE
          )
        ''');

        try {
          await db.execute('''
            INSERT INTO contratos (id, nome, descricao, status, caminho, usuario_id, criadoEm, atualizadoEm, excluidoEm)
            SELECT 
              id, 
              COALESCE(nomeArquivo, 'Contrato sem nome') as nome,
              COALESCE(clausulas, '') as descricao,
              COALESCE('Ativo', 'Rascunho') as status,
              COALESCE(caminhoArquivo, '') as caminho,
              usuario_id,
              criadoEm,
              atualizadoEm,
              excluidoEm
            FROM contratos_backup
            WHERE excluidoEm IS NULL
          ''');
        } catch (e) {
          print('Erro na migração dos dados de contratos: $e');
        }

        await db.execute('DROP TABLE contratos_backup');
      }

      await db.execute('''
        CREATE TABLE IF NOT EXISTS clausulas(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          texto TEXT NOT NULL,
          tipo TEXT NOT NULL,
          status TEXT DEFAULT 'Ativa',
          contrato_id INTEGER NOT NULL,
          criadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          atualizadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          excluidoEm TIMESTAMP,
          FOREIGN KEY (contrato_id) REFERENCES contratos (id) ON DELETE CASCADE
        )
      ''');

      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_contratos_usuario_id ON contratos(usuario_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_contratos_status ON contratos(status)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_clausulas_contrato_id ON clausulas(contrato_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_clausulas_tipo ON clausulas(tipo)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_clausulas_status ON clausulas(status)',
      );
    }

    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS clausulas_genericas(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nomeClausula TEXT NOT NULL,
          conteudo TEXT NOT NULL,
          criadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          atualizadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          excluidoEm TIMESTAMP
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS prazos_duracao(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          tipoPrazo TEXT NOT NULL,
          criadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          atualizadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          excluidoEm TIMESTAMP
        )
      ''');

      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_clausulas_genericas_nomeClausula ON clausulas_genericas(nomeClausula)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_prazos_duracao_tipoPrazo ON prazos_duracao(tipoPrazo)',
      );

      await db.execute('''
        CREATE TABLE IF NOT EXISTS socios(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nome TEXT NOT NULL,
          statusSocial TEXT NOT NULL,
          dataNascimento TEXT NOT NULL,
          cpf TEXT NOT NULL,
          residencia TEXT NOT NULL,
          criadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          atualizadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          excluidoEm TIMESTAMP
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS objetos_sociais(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          atividadesEconomicas TEXT NOT NULL,
          atividadesExercidas TEXT NOT NULL,
          criadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          atualizadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          excluidoEm TIMESTAMP
        )
      ''');

      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_socios_nome ON socios(nome)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_socios_cpf ON socios(cpf)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_socios_status ON socios(statusSocial)',
      );
    }

    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS capitais_sociais(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          valorTotal REAL NOT NULL,
          divisaoQuotas TEXT NOT NULL,
          formaIntegralizacao TEXT NOT NULL,
          clausula_id INTEGER NOT NULL,
          criadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          atualizadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          excluidoEm TIMESTAMP,
          FOREIGN KEY (clausula_id) REFERENCES clausulas (id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS sedes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          enderecoCompleto TEXT NOT NULL,
          clausula_id INTEGER NOT NULL,
          criadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          atualizadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          excluidoEm TIMESTAMP,
          FOREIGN KEY (clausula_id) REFERENCES clausulas (id) ON DELETE CASCADE
        )
      ''');

      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_capitais_sociais_clausula_id ON capitais_sociais(clausula_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_sedes_clausula_id ON sedes(clausula_id)',
      );
    }

    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS administracoes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nomeAdministrador TEXT NOT NULL,
          poderesAdministrativos TEXT NOT NULL,
          clausula_id INTEGER NOT NULL,
          criadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          atualizadoEm TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          excluidoEm TIMESTAMP,
          FOREIGN KEY (clausula_id) REFERENCES clausulas (id) ON DELETE CASCADE
        )
      ''');

      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_administracoes_clausula_id ON administracoes(clausula_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_administracoes_nomeAdministrador ON administracoes(nomeAdministrador)',
      );
    }

    // Migration to version 6 - Add new fields to recados table for better PDF analysis storage
    if (oldVersion < 6) {
      await db.execute('''
        ALTER TABLE recados ADD COLUMN conteudoAnalise TEXT
      ''');
      await db.execute('''
        ALTER TABLE recados ADD COLUMN nomeArquivo TEXT
      ''');
    }

    // Migration to version 7 - Add recado_id to clausulas_genericas for PDF analysis linking
    if (oldVersion < 7) {
      await db.execute('''
        ALTER TABLE clausulas_genericas ADD COLUMN recado_id INTEGER
      ''');
      // Note: We don't add the foreign key constraint in ALTER TABLE for SQLite compatibility
    }

    // Migration to version 8 - Add clausula_id to modelos table
    if (oldVersion < 8) {
      await db.execute('''
        ALTER TABLE modelos ADD COLUMN clausula_id INTEGER
      ''');
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  Future<void> resetDatabase() async {
    String path = join(await getDatabasesPath(), 'nahero_app.db');
    await deleteDatabase(path);
    _database = null;
    await database;
  }

  Future<bool> verificarIntegridade() async {
    try {
      final db = await database;
      final result = await db.rawQuery('PRAGMA integrity_check');
      return result.isNotEmpty && result.first['integrity_check'] == 'ok';
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> obterInformacoesTabelaContrato() async {
    final db = await database;
    return await db.rawQuery("PRAGMA table_info(contratos)");
  }

  Future<List<Map<String, dynamic>>> obterInformacoesTabelaClausula() async {
    final db = await database;
    return await db.rawQuery("PRAGMA table_info(clausulas)");
  }

  Future<List<Map<String, dynamic>>>
  obterInformacoesTabelaCapitalSocial() async {
    final db = await database;
    return await db.rawQuery("PRAGMA table_info(capitais_sociais)");
  }

  Future<List<Map<String, dynamic>>> obterInformacoesTabelaSede() async {
    final db = await database;
    return await db.rawQuery("PRAGMA table_info(sedes)");
  }

  Future<List<Map<String, dynamic>>> obterInformacoesTabelaSocio() async {
    final db = await database;
    return await db.rawQuery("PRAGMA table_info(socios)");
  }

  Future<List<Map<String, dynamic>>>
  obterInformacoesTabelaObjetoSocial() async {
    final db = await database;
    return await db.rawQuery("PRAGMA table_info(objetos_sociais)");
  }

  Future<List<Map<String, dynamic>>> obterInformacoesTabelaAdministracao() async {
    final db = await database;
    return await db.rawQuery("PRAGMA table_info(administracoes)");
  }
}