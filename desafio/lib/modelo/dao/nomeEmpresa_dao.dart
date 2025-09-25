import 'dart:async';
import 'package:desafio/modelo/entidades/nomeEmpresa/nomeEmpresa.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
// Importe a entidade NomeEmpresa aqui
// import 'nome_empresa.dart';

class NomeEmpresaDao {
  static const String tableName = 'nome_empresa';
  static const String columnId = 'id';
  static const String columnRazaoSocial = 'razaoSocial';
  static const String columnNomeFantasia = 'nomeFantasia';

  // Singleton pattern
  static final NomeEmpresaDao _instance = NomeEmpresaDao._internal();
  factory NomeEmpresaDao() => _instance;
  NomeEmpresaDao._internal();

  static Database? _database;

  // Getter para o banco de dados
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // Inicializar o banco de dados
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'empresa_database.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // Criar a tabela
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnRazaoSocial TEXT NOT NULL,
        $columnNomeFantasia TEXT NOT NULL
      )
    ''');
  }

  // Inserir uma nova empresa
  Future<int> insert(NomeEmpresa empresa) async {
    final db = await database;
    try {
      return await db.insert(
        tableName,
        empresa.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Erro ao inserir empresa: $e');
    }
  }

  // Buscar empresa por ID
  Future<NomeEmpresa?> findById(int id) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnId = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return NomeEmpresa.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar empresa por ID: $e');
    }
  }

  // Buscar todas as empresas
  Future<List<NomeEmpresa>> findAll() async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(tableName);
      return List.generate(maps.length, (i) {
        return NomeEmpresa.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Erro ao buscar todas as empresas: $e');
    }
  }

  // Buscar empresas por razão social (busca parcial)
  Future<List<NomeEmpresa>> findByRazaoSocial(String razaoSocial) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnRazaoSocial LIKE ?',
        whereArgs: ['%$razaoSocial%'],
      );
      return List.generate(maps.length, (i) {
        return NomeEmpresa.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Erro ao buscar empresas por razão social: $e');
    }
  }

  // Buscar empresas por nome fantasia (busca parcial)
  Future<List<NomeEmpresa>> findByNomeFantasia(String nomeFantasia) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnNomeFantasia LIKE ?',
        whereArgs: ['%$nomeFantasia%'],
      );
      return List.generate(maps.length, (i) {
        return NomeEmpresa.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Erro ao buscar empresas por nome fantasia: $e');
    }
  }

  // Atualizar uma empresa
  Future<int> update(NomeEmpresa empresa) async {
    final db = await database;
    try {
      return await db.update(
        tableName,
        empresa.toMap(),
        where: '$columnId = ?',
        whereArgs: [empresa.id],
      );
    } catch (e) {
      throw Exception('Erro ao atualizar empresa: $e');
    }
  }

  // Deletar uma empresa por ID
  Future<int> deleteById(int id) async {
    final db = await database;
    try {
      return await db.delete(
        tableName,
        where: '$columnId = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Erro ao deletar empresa: $e');
    }
  }

  // Deletar uma empresa
  Future<int> delete(NomeEmpresa empresa) async {
    return await deleteById(empresa.id);
  }

  // Deletar todas as empresas
  Future<int> deleteAll() async {
    final db = await database;
    try {
      return await db.delete(tableName);
    } catch (e) {
      throw Exception('Erro ao deletar todas as empresas: $e');
    }
  }

  // Contar o número total de empresas
  Future<int> count() async {
    final db = await database;
    try {
      final result = await db.rawQuery('SELECT COUNT(*) FROM $tableName');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw Exception('Erro ao contar empresas: $e');
    }
  }

  // Verificar se uma empresa existe por ID
  Future<bool> exists(int id) async {
    final empresa = await findById(id);
    return empresa != null;
  }

  // Busca paginada
  Future<List<NomeEmpresa>> findWithPagination({
    int limit = 10,
    int offset = 0,
  }) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        limit: limit,
        offset: offset,
        orderBy: '$columnId DESC',
      );
      return List.generate(maps.length, (i) {
        return NomeEmpresa.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Erro ao buscar empresas com paginação: $e');
    }
  }

  // Fechar o banco de dados
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
