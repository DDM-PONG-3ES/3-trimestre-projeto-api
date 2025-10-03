import 'package:desafio/comum/config/banco/conexao.dart';
import 'package:desafio/modelo/entidades/prazoDuracao/prazoDuracao.dart';
import 'package:sqflite/sqflite.dart';

class PrazoDuracaoDAO {
  static final PrazoDuracaoDAO _instance = PrazoDuracaoDAO._internal();
  factory PrazoDuracaoDAO() => _instance;
  PrazoDuracaoDAO._internal();

  Future<Database> get _db async => await Conexao().database;

  Future<PrazoDuracao?> criarPrazoDuracao({required String tipoPrazo}) async {
    final db = await _db;
    try {
      final agora = DateTime.now();
      final id = await db.insert('prazos_duracao', {
        'tipoPrazo': tipoPrazo,
        'criadoEm': agora.toIso8601String(),
        'atualizadoEm': agora.toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      return PrazoDuracao(
        id: id,
        tipoPrazo: tipoPrazo,
        criadoEm: agora,
        atualizadoEm: agora,
      );
    } catch (e) {
      throw Exception('Erro ao criar prazo de duração: $e');
    }
  }

  Future<PrazoDuracao?> buscarPorId(int id) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'prazos_duracao',
      where: 'id = ? AND excluidoEm IS NULL',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return PrazoDuracao.fromMap(maps.first);
    }
    return null;
  }

  Future<List<PrazoDuracao>> listarTodas({int? limite, int? offset}) async {
    final db = await _db;
    String query =
        'SELECT * FROM prazos_duracao WHERE excluidoEm IS NULL ORDER BY criadoEm DESC';
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
      return PrazoDuracao.fromMap(maps[i]);
    });
  }

  Future<bool> atualizarPrazoDuracao(PrazoDuracao prazoDuracao) async {
    final db = await _db;
    try {
      prazoDuracao.atualizadoEm = DateTime.now();
      final count = await db.update(
        'prazos_duracao',
        {
          'tipoPrazo': prazoDuracao.tipoPrazo,
          'atualizadoEm': prazoDuracao.atualizadoEm!.toIso8601String(),
        },
        where: 'id = ? AND excluidoEm IS NULL',
        whereArgs: [prazoDuracao.id],
      );
      return count > 0;
    } catch (e) {
      throw Exception('Erro ao atualizar prazo de duração: $e');
    }
  }

  Future<bool> excluirPrazoDuracao(int id) async {
    final db = await _db;
    try {
      final agora = DateTime.now();
      final count = await db.update(
        'prazos_duracao',
        {
          'excluidoEm': agora.toIso8601String(),
          'atualizadoEm': agora.toIso8601String(),
        },
        where: 'id = ? AND excluidoEm IS NULL',
        whereArgs: [id],
      );
      return count > 0;
    } catch (e) {
      throw Exception('Erro ao excluir prazo de duração: $e');
    }
  }

  Future<int> contarPrazosDuracao({bool? apenasExcluidas}) async {
    final db = await _db;
    String where = '';
    if (apenasExcluidas == true) {
      where = 'excluidoEm IS NOT NULL';
    } else if (apenasExcluidas == false) {
      where = 'excluidoEm IS NULL';
    }
    final List<Map<String, dynamic>> result = await db.query(
      'prazos_duracao',
      columns: ['COUNT(*) as count'],
      where: where.isNotEmpty ? where : null,
    );
    return result.first['count'] as int;
  }
}
