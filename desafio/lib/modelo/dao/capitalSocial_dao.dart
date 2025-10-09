import 'package:desafio/comum/config/banco/conexao.dart';
import 'package:desafio/modelo/entidades/capitalSocial/capitalSocial.dart';
import 'package:sqflite/sqflite.dart';

class CapitalSocialDAO {
  static final CapitalSocialDAO _instance = CapitalSocialDAO._internal();
  factory CapitalSocialDAO() => _instance;
  CapitalSocialDAO._internal();

  Future<Database> get _db async => await Conexao().database;

  Future<CapitalSocial?> criar(
    double valorTotal,
    String divisaoQuotas,
    String formaIntegralizacao,
    int clausulaId,
  ) async {
    final db = await _db;

    try {
      final agora = DateTime.now();
      final id = await db.insert('capitais_sociais', {
        'valorTotal': valorTotal,
        'divisaoQuotas': divisaoQuotas,
        'formaIntegralizacao': formaIntegralizacao,
        'clausula_id': clausulaId,
        'criadoEm': agora.toIso8601String(),
        'atualizadoEm': agora.toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      return CapitalSocial(
        id: id,
        valorTotal: valorTotal,
        divisaoQuotas: divisaoQuotas,
        formaIntegralizacao: formaIntegralizacao,
        clausulaId: clausulaId,
        criadoEm: agora,
        atualizadoEm: agora,
      );
    } catch (e) {
      throw Exception('Erro ao criar capital social: $e');
    }
  }

  Future<CapitalSocial?> buscarPorId(int id) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'capitais_sociais',
      where: 'id = ? AND excluidoEm IS NULL',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return CapitalSocial.fromMap(maps.first);
    }
    return null;
  }

  Future<List<CapitalSocial>> listarTodos({int? limite, int? offset}) async {
    final db = await _db;

    String query =
        'SELECT * FROM capitais_sociais WHERE excluidoEm IS NULL ORDER BY criadoEm DESC';
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
      return CapitalSocial.fromMap(maps[i]);
    });
  }

  Future<List<CapitalSocial>> listarPorClausula(int clausulaId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'capitais_sociais',
      where: 'clausula_id = ? AND excluidoEm IS NULL',
      whereArgs: [clausulaId],
      orderBy: 'criadoEm DESC',
    );

    return List.generate(maps.length, (i) {
      return CapitalSocial.fromMap(maps[i]);
    });
  }

  Future<bool> atualizar(CapitalSocial capitalSocial) async {
    final db = await _db;

    try {
      capitalSocial.atualizadoEm = DateTime.now();

      final count = await db.update(
        'capitais_sociais',
        {
          'valorTotal': capitalSocial.valorTotal,
          'divisaoQuotas': capitalSocial.divisaoQuotas,
          'formaIntegralizacao': capitalSocial.formaIntegralizacao,
          'clausula_id': capitalSocial.clausulaId,
          'atualizadoEm': capitalSocial.atualizadoEm!.toIso8601String(),
        },
        where: 'id = ? AND excluidoEm IS NULL',
        whereArgs: [capitalSocial.id],
      );

      return count > 0;
    } catch (e) {
      throw Exception('Erro ao atualizar capital social: $e');
    }
  }

  Future<bool> excluir(int id) async {
    final db = await _db;

    try {
      final agora = DateTime.now();
      final count = await db.update(
        'capitais_sociais',
        {
          'excluidoEm': agora.toIso8601String(),
          'atualizadoEm': agora.toIso8601String(),
        },
        where: 'id = ? AND excluidoEm IS NULL',
        whereArgs: [id],
      );

      return count > 0;
    } catch (e) {
      throw Exception('Erro ao excluir capital social: $e');
    }
  }

  Future<int> contar({int? clausulaId, bool? apenasExcluidos}) async {
    final db = await _db;
    String where = '';
    List<dynamic> whereArgs = [];

    if (apenasExcluidos == true) {
      where = 'excluidoEm IS NOT NULL';
    } else if (apenasExcluidos == false) {
      where = 'excluidoEm IS NULL';

      if (clausulaId != null) {
        where += ' AND clausula_id = ?';
        whereArgs.add(clausulaId);
      }
    }

    final List<Map<String, dynamic>> result = await db.query(
      'capitais_sociais',
      columns: ['COUNT(*) as count'],
      where: where.isNotEmpty ? where : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );

    return result.first['count'] as int;
  }
}
