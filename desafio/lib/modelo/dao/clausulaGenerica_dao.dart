import 'package:desafio/comum/config/banco/conexao.dart';
import 'package:desafio/modelo/entidades/clausulaGenerica/clausulaGenerica.dart';
import 'package:sqflite/sqflite.dart';

class ClausulaGenericaDAO {
  static final ClausulaGenericaDAO _instance = ClausulaGenericaDAO._internal();
  factory ClausulaGenericaDAO() => _instance;
  ClausulaGenericaDAO._internal();

  Future<Database> get _db async => await Conexao().database;

  Future<ClausulaGenerica?> criarClausulaGenerica({
    required String nomeClausula,
    required String conteudo,
    int? recadoId,
  }) async {
    final db = await _db;
    try {
      final agora = DateTime.now();
      final id = await db.insert('clausulas_genericas', {
        'nomeClausula': nomeClausula,
        'conteudo': conteudo,
        'recado_id': recadoId,
        'criadoEm': agora.toIso8601String(),
        'atualizadoEm': agora.toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      return ClausulaGenerica(
        id: id,
        nomeClausula: nomeClausula,
        conteudo: conteudo,
        recadoId: recadoId,
        criadoEm: agora,
        atualizadoEm: agora,
      );
    } catch (e) {
      throw Exception('Erro ao criar cláusula genérica: $e');
    }
  }

  Future<ClausulaGenerica?> buscarPorId(int id) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'clausulas_genericas',
      where: 'id = ? AND excluidoEm IS NULL',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return ClausulaGenerica.fromMap(maps.first);
    }
    return null;
  }

  Future<List<ClausulaGenerica>> listarTodas({int? limite, int? offset}) async {
    final db = await _db;
    String query =
        'SELECT * FROM clausulas_genericas WHERE excluidoEm IS NULL ORDER BY criadoEm DESC';
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
      return ClausulaGenerica.fromMap(maps[i]);
    });
  }

  Future<bool> atualizarClausulaGenerica(
    ClausulaGenerica clausulaGenerica,
  ) async {
    final db = await _db;
    try {
      clausulaGenerica.atualizadoEm = DateTime.now();
      final count = await db.update(
        'clausulas_genericas',
        {
          'nomeClausula': clausulaGenerica.nomeClausula,
          'conteudo': clausulaGenerica.conteudo,
          'atualizadoEm': clausulaGenerica.atualizadoEm!.toIso8601String(),
        },
        where: 'id = ? AND excluidoEm IS NULL',
        whereArgs: [clausulaGenerica.id],
      );
      return count > 0;
    } catch (e) {
      throw Exception('Erro ao atualizar cláusula genérica: $e');
    }
  }

  Future<bool> excluirClausulaGenerica(int id) async {
    final db = await _db;
    try {
      final agora = DateTime.now();
      final count = await db.update(
        'clausulas_genericas',
        {
          'excluidoEm': agora.toIso8601String(),
          'atualizadoEm': agora.toIso8601String(),
        },
        where: 'id = ? AND excluidoEm IS NULL',
        whereArgs: [id],
      );
      return count > 0;
    } catch (e) {
      throw Exception('Erro ao excluir cláusula genérica: $e');
    }
  }

  Future<int> contarClausulasGenericas({bool? apenasExcluidas}) async {
    final db = await _db;
    String where = '';
    if (apenasExcluidas == true) {
      where = 'excluidoEm IS NOT NULL';
    } else if (apenasExcluidas == false) {
      where = 'excluidoEm IS NULL';
    }
    final List<Map<String, dynamic>> result = await db.query(
      'clausulas_genericas',
      columns: ['COUNT(*) as count'],
      where: where.isNotEmpty ? where : null,
    );
    return result.first['count'] as int;
  }
}
