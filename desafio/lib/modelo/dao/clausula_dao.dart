import 'package:desafio/comum/config/banco/conexao.dart';
import 'package:desafio/modelo/entidades/clausula/clausula.dart';
import 'package:sqflite/sqflite.dart';

class ClausulaDAO {
  static final ClausulaDAO _instance = ClausulaDAO._internal();
  factory ClausulaDAO() => _instance;
  ClausulaDAO._internal();

  Future<Database> get _db async => await Conexao().database;

  Future<Clausula?> criarClausula(
    String texto,
    String tipo,
    String status,
    int contratoId,
  ) async {
    final db = await _db;

    try {
      final agora = DateTime.now();
      final id = await db.insert('clausulas', {
        'texto': texto,
        'tipo': tipo,
        'status': status,
        'contrato_id': contratoId,
        'criadoEm': agora.toIso8601String(),
        'atualizadoEm': agora.toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      return Clausula(
        id: id,
        texto: texto,
        tipo: tipo,
        status: status,
        contratoId: contratoId,
        criadoEm: agora,
        atualizadoEm: agora,
      );
    } catch (e) {
      throw Exception('Erro ao criar cláusula: $e');
    }
  }

  Future<Clausula?> buscarPorId(int id) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'clausulas',
      where: 'id = ? AND excluidoEm IS NULL',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Clausula.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Clausula>> listarTodas({int? limite, int? offset}) async {
    final db = await _db;

    String query =
        'SELECT * FROM clausulas WHERE excluidoEm IS NULL ORDER BY criadoEm DESC';
    List<dynamic> arguments = [];

    if (limite != null) {
      query += ' LIMIT ?';
      arguments.add(limite);

      if (offset != null) {
        query += ' OFFSET ?';
        arguments.add(offset);
      }
    }

    final List<Map<String, dynamic>> maps = await db.rawQuery(query, arguments);

    return List.generate(maps.length, (i) {
      return Clausula.fromMap(maps[i]);
    });
  }

  Future<List<Clausula>> listarPorContrato(int contratoId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'clausulas',
      where: 'contrato_id = ? AND excluidoEm IS NULL',
      whereArgs: [contratoId],
      orderBy: 'criadoEm DESC',
    );

    return List.generate(maps.length, (i) {
      return Clausula.fromMap(maps[i]);
    });
  }

  Future<List<Clausula>> buscarPorTipo(String tipo) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'clausulas',
      where: 'tipo = ? AND excluidoEm IS NULL',
      whereArgs: [tipo],
      orderBy: 'criadoEm DESC',
    );

    return List.generate(maps.length, (i) {
      return Clausula.fromMap(maps[i]);
    });
  }

  Future<bool> atualizarClausula(Clausula clausula) async {
    final db = await _db;

    try {
      clausula.atualizadoEm = DateTime.now();

      final count = await db.update(
        'clausulas',
        {
          'texto': clausula.texto,
          'tipo': clausula.tipo,
          'status': clausula.status,
          'contrato_id': clausula.contratoId,
          'atualizadoEm': clausula.atualizadoEm!.toIso8601String(),
        },
        where: 'id = ? AND excluidoEm IS NULL',
        whereArgs: [clausula.id],
      );

      return count > 0;
    } catch (e) {
      throw Exception('Erro ao atualizar cláusula: $e');
    }
  }

  Future<bool> excluirClausula(int id) async {
    final db = await _db;

    try {
      final agora = DateTime.now();
      final count = await db.update(
        'clausulas',
        {
          'excluidoEm': agora.toIso8601String(),
          'atualizadoEm': agora.toIso8601String(),
        },
        where: 'id = ? AND excluidoEm IS NULL',
        whereArgs: [id],
      );

      return count > 0;
    } catch (e) {
      throw Exception('Erro ao excluir cláusula: $e');
    }
  }

  Future<int> contarClausulas({
    int? contratoId,
    String? tipo,
    bool? apenasExcluidas,
  }) async {
    final db = await _db;
    String where = '';
    List<dynamic> whereArgs = [];

    if (apenasExcluidas == true) {
      where = 'excluidoEm IS NOT NULL';
    } else if (apenasExcluidas == false) {
      where = 'excluidoEm IS NULL';

      if (contratoId != null) {
        where += ' AND contrato_id = ?';
        whereArgs.add(contratoId);
      }

      if (tipo != null) {
        where += ' AND tipo = ?';
        whereArgs.add(tipo);
      }
    }

    final List<Map<String, dynamic>> result = await db.query(
      'clausulas',
      columns: ['COUNT(*) as count'],
      where: where.isNotEmpty ? where : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );

    return result.first['count'] as int;
  }
}
