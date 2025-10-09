import 'package:desafio/comum/config/banco/conexao.dart';
import 'package:desafio/modelo/entidades/sede/sede.dart';
import 'package:sqflite/sqflite.dart';

class SedeDAO {
  static final SedeDAO _instance = SedeDAO._internal();
  factory SedeDAO() => _instance;
  SedeDAO._internal();

  Future<Database> get _db async => await Conexao().database;

  Future<Sede?> criar(String enderecoCompleto, int clausulaId) async {
    final db = await _db;

    try {
      final agora = DateTime.now();
      final id = await db.insert('sedes', {
        'enderecoCompleto': enderecoCompleto,
        'clausula_id': clausulaId,
        'criadoEm': agora.toIso8601String(),
        'atualizadoEm': agora.toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      return Sede(
        id: id,
        enderecoCompleto: enderecoCompleto,
        clausulaId: clausulaId,
        criadoEm: agora,
        atualizadoEm: agora,
      );
    } catch (e) {
      throw Exception('Erro ao criar sede: $e');
    }
  }

  Future<Sede?> buscarPorId(int id) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'sedes',
      where: 'id = ? AND excluidoEm IS NULL',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Sede.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Sede>> listarTodas({int? limite, int? offset}) async {
    final db = await _db;

    String query =
        'SELECT * FROM sedes WHERE excluidoEm IS NULL ORDER BY criadoEm DESC';
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
      return Sede.fromMap(maps[i]);
    });
  }

  Future<List<Sede>> listarPorClausula(int clausulaId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'sedes',
      where: 'clausula_id = ? AND excluidoEm IS NULL',
      whereArgs: [clausulaId],
      orderBy: 'criadoEm DESC',
    );

    return List.generate(maps.length, (i) {
      return Sede.fromMap(maps[i]);
    });
  }

  Future<bool> atualizar(Sede sede) async {
    final db = await _db;

    try {
      sede.atualizadoEm = DateTime.now();

      final count = await db.update(
        'sedes',
        {
          'enderecoCompleto': sede.enderecoCompleto,
          'clausula_id': sede.clausulaId,
          'atualizadoEm': sede.atualizadoEm!.toIso8601String(),
        },
        where: 'id = ? AND excluidoEm IS NULL',
        whereArgs: [sede.id],
      );

      return count > 0;
    } catch (e) {
      throw Exception('Erro ao atualizar sede: $e');
    }
  }

  Future<bool> excluir(int id) async {
    final db = await _db;

    try {
      final agora = DateTime.now();
      final count = await db.update(
        'sedes',
        {
          'excluidoEm': agora.toIso8601String(),
          'atualizadoEm': agora.toIso8601String(),
        },
        where: 'id = ? AND excluidoEm IS NULL',
        whereArgs: [id],
      );

      return count > 0;
    } catch (e) {
      throw Exception('Erro ao excluir sede: $e');
    }
  }

  Future<int> contar({int? clausulaId, bool? apenasExcluidas}) async {
    final db = await _db;
    String where = '';
    List<dynamic> whereArgs = [];

    if (apenasExcluidas == true) {
      where = 'excluidoEm IS NOT NULL';
    } else if (apenasExcluidas == false) {
      where = 'excluidoEm IS NULL';

      if (clausulaId != null) {
        where += ' AND clausula_id = ?';
        whereArgs.add(clausulaId);
      }
    }

    final List<Map<String, dynamic>> result = await db.query(
      'sedes',
      columns: ['COUNT(*) as count'],
      where: where.isNotEmpty ? where : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );

    return result.first['count'] as int;
  }
}
