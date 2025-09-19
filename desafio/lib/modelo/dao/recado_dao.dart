import 'package:desafio/comum/config/banco/conexao.dart';
import 'package:desafio/modelo/entidades/recado/recado.dart';
import 'package:sqflite/sqflite.dart';

class RecadoDAO {
  static final RecadoDAO _instance = RecadoDAO._internal();
  factory RecadoDAO() => _instance;
  RecadoDAO._internal();

  Future<Database> get _db async => await Conexao().database;

  Future<Recado?> criarRecado(String nome, String? erroIA) async {
    final db = await _db;

    try {
      final agora = DateTime.now();
      final id = await db.insert('recados', {
        'nome': nome,
        'erroIA': erroIA,
        'criadoEm': agora.toIso8601String(),
        'atualizadoEm': agora.toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      return Recado(
        id: id,
        nome: nome,
        erroIA: erroIA,
        criadoEm: agora,
        atualizadoEm: agora,
      );
    } catch (e) {
      throw Exception('Erro ao criar recado: $e');
    }
  }

  Future<Recado?> buscarPorId(int id) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'recados',
      where: 'id = ? AND excluidoEm IS NULL',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Recado.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Recado>> listarTodos({int? limite, int? offset}) async {
    final db = await _db;

    String query =
        'SELECT * FROM recados WHERE excluidoEm IS NULL ORDER BY criadoEm DESC';
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
      return Recado.fromMap(maps[i]);
    });
  }

  Future<List<Recado>> buscarPorNome(String nome) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'recados',
      where: 'nome LIKE ? AND excluidoEm IS NULL',
      whereArgs: ['%$nome%'],
      orderBy: 'criadoEm DESC',
    );

    return List.generate(maps.length, (i) {
      return Recado.fromMap(maps[i]);
    });
  }

  Future<List<Recado>> listarComErros() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'recados',
      where: 'erroIA IS NOT NULL AND erroIA != "" AND excluidoEm IS NULL',
      orderBy: 'criadoEm DESC',
    );

    return List.generate(maps.length, (i) {
      return Recado.fromMap(maps[i]);
    });
  }

  Future<List<Recado>> listarSemErros() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'recados',
      where: '(erroIA IS NULL OR erroIA = "") AND excluidoEm IS NULL',
      orderBy: 'criadoEm DESC',
    );

    return List.generate(maps.length, (i) {
      return Recado.fromMap(maps[i]);
    });
  }

  Future<bool> atualizarRecado(Recado recado) async {
    final db = await _db;

    try {
      recado.atualizadoEm = DateTime.now();

      final count = await db.update(
        'recados',
        {
          'nome': recado.nome,
          'erroIA': recado.erroIA,
          'atualizadoEm': recado.atualizadoEm!.toIso8601String(),
        },
        where: 'id = ? AND excluidoEm IS NULL',
        whereArgs: [recado.id],
      );

      return count > 0;
    } catch (e) {
      throw Exception('Erro ao atualizar recado: $e');
    }
  }

  Future<bool> excluirRecado(int id) async {
    final db = await _db;

    try {
      final agora = DateTime.now();
      final count = await db.update(
        'recados',
        {
          'excluidoEm': agora.toIso8601String(),
          'atualizadoEm': agora.toIso8601String(),
        },
        where: 'id = ? AND excluidoEm IS NULL',
        whereArgs: [id],
      );

      return count > 0;
    } catch (e) {
      throw Exception('Erro ao excluir recado: $e');
    }
  }

  Future<bool> excluirDefinitivamente(int id) async {
    final db = await _db;

    try {
      final count = await db.delete(
        'recados',
        where: 'id = ?',
        whereArgs: [id],
      );

      return count > 0;
    } catch (e) {
      throw Exception('Erro ao excluir recado definitivamente: $e');
    }
  }

  Future<bool> restaurarRecado(int id) async {
    final db = await _db;

    try {
      final count = await db.update(
        'recados',
        {'excluidoEm': null, 'atualizadoEm': DateTime.now().toIso8601String()},
        where: 'id = ? AND excluidoEm IS NOT NULL',
        whereArgs: [id],
      );

      return count > 0;
    } catch (e) {
      throw Exception('Erro ao restaurar recado: $e');
    }
  }

  Future<int> contarRecados({
    bool? apenasComErros,
    bool? apenasExcluidos,
  }) async {
    final db = await _db;
    String where = '';
    List<dynamic> whereArgs = [];

    if (apenasExcluidos == true) {
      where = 'excluidoEm IS NOT NULL';
    } else if (apenasExcluidos == false) {
      where = 'excluidoEm IS NULL';

      if (apenasComErros == true) {
        where += ' AND erroIA IS NOT NULL AND erroIA != ""';
      } else if (apenasComErros == false) {
        where += ' AND (erroIA IS NULL OR erroIA = "")';
      }
    }

    final List<Map<String, dynamic>> result = await db.query(
      'recados',
      columns: ['COUNT(*) as count'],
      where: where.isNotEmpty ? where : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );

    return result.first['count'] as int;
  }

  Future<List<Recado>> listarExcluidos() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'recados',
      where: 'excluidoEm IS NOT NULL',
      orderBy: 'excluidoEm DESC',
    );

    return List.generate(maps.length, (i) {
      return Recado.fromMap(maps[i]);
    });
  }

  Future<void> limparRecadosExcluidos() async {
    final db = await _db;

    try {
      await db.delete('recados', where: 'excluidoEm IS NOT NULL');
    } catch (e) {
      throw Exception('Erro ao limpar recados excluídos: $e');
    }
  }
}
