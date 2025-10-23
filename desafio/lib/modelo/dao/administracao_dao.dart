import 'package:desafio/comum/config/banco/conexao.dart';
import 'package:desafio/modelo/entidades/administracao/administracao.dart';
import 'package:sqflite/sqflite.dart';

class AdministracaoDAO {
  static final AdministracaoDAO _instance = AdministracaoDAO._internal();
  factory AdministracaoDAO() => _instance;
  AdministracaoDAO._internal();

  Future<Database> get _db async => await Conexao().database;

  Future<Administracao?> criar(
    String nomeAdministrador,
    String poderesAdministrativos,
    int clausulaId,
  ) async {
    final db = await _db;

    try {
      final agora = DateTime.now();
      final id = await db.insert('administracoes', {
        'nomeAdministrador': nomeAdministrador,
        'poderesAdministrativos': poderesAdministrativos,
        'clausula_id': clausulaId,
        'criadoEm': agora.toIso8601String(),
        'atualizadoEm': agora.toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      return Administracao(
        id: id,
        nomeAdministrador: nomeAdministrador,
        poderesAdministrativos: poderesAdministrativos,
        clausulaId: clausulaId,
        criadoEm: agora,
        atualizadoEm: agora,
      );
    } catch (e) {
      throw Exception('Erro ao criar administração: $e');
    }
  }

  Future<Administracao?> buscarPorId(int id) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'administracoes',
      where: 'id = ? AND excluidoEm IS NULL',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Administracao.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Administracao>> listarTodas({int? limite, int? offset}) async {
    final db = await _db;

    String query =
        'SELECT * FROM administracoes WHERE excluidoEm IS NULL ORDER BY criadoEm DESC';
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
      return Administracao.fromMap(maps[i]);
    });
  }

  Future<List<Administracao>> listarPorClausula(int clausulaId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'administracoes',
      where: 'clausula_id = ? AND excluidoEm IS NULL',
      whereArgs: [clausulaId],
      orderBy: 'criadoEm DESC',
    );

    return List.generate(maps.length, (i) {
      return Administracao.fromMap(maps[i]);
    });
  }

  Future<bool> atualizar(Administracao administracao) async {
    final db = await _db;

    try {
      administracao.atualizadoEm = DateTime.now();

      final count = await db.update(
        'administracoes',
        {
          'nomeAdministrador': administracao.nomeAdministrador,
          'poderesAdministrativos': administracao.poderesAdministrativos,
          'clausula_id': administracao.clausulaId,
          'atualizadoEm': administracao.atualizadoEm!.toIso8601String(),
        },
        where: 'id = ? AND excluidoEm IS NULL',
        whereArgs: [administracao.id],
      );

      return count > 0;
    } catch (e) {
      throw Exception('Erro ao atualizar administração: $e');
    }
  }

  Future<bool> excluir(int id) async {
    final db = await _db;

    try {
      final agora = DateTime.now();
      final count = await db.update(
        'administracoes',
        {
          'excluidoEm': agora.toIso8601String(),
          'atualizadoEm': agora.toIso8601String(),
        },
        where: 'id = ? AND excluidoEm IS NULL',
        whereArgs: [id],
      );

      return count > 0;
    } catch (e) {
      throw Exception('Erro ao excluir administração: $e');
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
      'administracoes',
      columns: ['COUNT(*) as count'],
      where: where.isNotEmpty ? where : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );

    return result.first['count'] as int;
  }
}