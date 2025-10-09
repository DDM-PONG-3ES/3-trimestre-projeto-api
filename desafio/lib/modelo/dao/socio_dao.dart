import 'package:desafio/comum/config/banco/conexao.dart';
import 'package:desafio/modelo/entidades/socio/socio.dart';
import 'package:sqflite/sqflite.dart';

class SocioDao {
  final Conexao _conexao = Conexao();

  Future<int> inserir(Socio socio) async {
    final db = await _conexao.database;
    socio.criadoEm = DateTime.now();
    socio.atualizadoEm = DateTime.now();
    return await db.insert('socios', socio.toMap());
  }

  Future<int> atualizar(Socio socio) async {
    final db = await _conexao.database;
    socio.atualizadoEm = DateTime.now();
    return await db.update(
      'socios',
      socio.toMap(),
      where: 'id = ?',
      whereArgs: [socio.id],
    );
  }

  Future<int> deletar(int id) async {
    final db = await _conexao.database;
    return await db.update(
      'socios',
      {'excluidoEm': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deletarPermanente(int id) async {
    final db = await _conexao.database;
    return await db.delete(
      'socios',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Socio?> buscarPorId(int id) async {
    final db = await _conexao.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'socios',
      where: 'id = ? AND excluidoEm IS NULL',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Socio.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Socio>> listarTodos() async {
    final db = await _conexao.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'socios',
      where: 'excluidoEm IS NULL',
      orderBy: 'criadoEm DESC',
    );

    return List.generate(maps.length, (i) => Socio.fromMap(maps[i]));
  }

  Future<List<Socio>> buscarPorNome(String nome) async {
    final db = await _conexao.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'socios',
      where: 'nome LIKE ? AND excluidoEm IS NULL',
      whereArgs: ['%$nome%'],
      orderBy: 'nome ASC',
    );

    return List.generate(maps.length, (i) => Socio.fromMap(maps[i]));
  }

  Future<List<Socio>> buscarPorStatus(String status) async {
    final db = await _conexao.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'socios',
      where: 'statusSocial = ? AND excluidoEm IS NULL',
      whereArgs: [status],
      orderBy: 'nome ASC',
    );

    return List.generate(maps.length, (i) => Socio.fromMap(maps[i]));
  }

  Future<int> contarSocios() async {
    final db = await _conexao.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as total FROM socios WHERE excluidoEm IS NULL',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
