import 'package:desafio/comum/config/banco/conexao.dart';
import 'package:desafio/modelo/entidades/objetoSocial/objetoSocial.dart';
import 'package:sqflite/sqflite.dart';

class ObjetoSocialDao {
  final Conexao _conexao = Conexao();

  Future<int> inserir(ObjetoSocial objetoSocial) async {
    final db = await _conexao.database;
    objetoSocial.criadoEm = DateTime.now();
    objetoSocial.atualizadoEm = DateTime.now();
    return await db.insert('objetos_sociais', objetoSocial.toMap());
  }

  Future<int> atualizar(ObjetoSocial objetoSocial) async {
    final db = await _conexao.database;
    objetoSocial.atualizadoEm = DateTime.now();
    return await db.update(
      'objetos_sociais',
      objetoSocial.toMap(),
      where: 'id = ?',
      whereArgs: [objetoSocial.id],
    );
  }

  Future<int> deletar(int id) async {
    final db = await _conexao.database;
    return await db.update(
      'objetos_sociais',
      {'excluidoEm': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deletarPermanente(int id) async {
    final db = await _conexao.database;
    return await db.delete(
      'objetos_sociais',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<ObjetoSocial?> buscarPorId(int id) async {
    final db = await _conexao.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'objetos_sociais',
      where: 'id = ? AND excluidoEm IS NULL',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return ObjetoSocial.fromMap(maps.first);
    }
    return null;
  }

  Future<List<ObjetoSocial>> listarTodos() async {
    final db = await _conexao.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'objetos_sociais',
      where: 'excluidoEm IS NULL',
      orderBy: 'criadoEm DESC',
    );

    return List.generate(maps.length, (i) => ObjetoSocial.fromMap(maps[i]));
  }

  Future<List<ObjetoSocial>> buscarPorAtividade(String atividade) async {
    final db = await _conexao.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'objetos_sociais',
      where: 'atividadesEconomicas LIKE ? OR atividadesExercidas LIKE ? AND excluidoEm IS NULL',
      whereArgs: ['%$atividade%', '%$atividade%'],
      orderBy: 'criadoEm DESC',
    );

    return List.generate(maps.length, (i) => ObjetoSocial.fromMap(maps[i]));
  }

  Future<int> contarObjetosSociais() async {
    final db = await _conexao.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as total FROM objetos_sociais WHERE excluidoEm IS NULL',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
