import 'package:desafio/comum/config/banco/conexao.dart';
import 'package:desafio/modelo/entidades/contrato/contrato.dart';
import 'package:desafio/servicos/autenticacao_servico.dart';
import 'package:sqflite/sqflite.dart';

class ContratoDAO {
  static final ContratoDAO _instance = ContratoDAO._internal();
  factory ContratoDAO() => _instance;
  ContratoDAO._internal();

  Future<Database> get _db async => await Conexao().database;

  Future<Contrato?> criarContrato(
    String titulo,
    String nomeEmpresa,
    String status,
    String descricao,
    String dataGeracao,
    String link,
  ) async {
    final db = await _db;

    try {
      final authService = AutenticacaoServico();
      final usuarioId = authService.usuarioAtual?.id ?? 1;

      final agora = DateTime.now();
      final id = await db.insert('contratos', {
        'nome': titulo,
        'descricao': descricao,
        'status': status,
        'caminho': link,
        'usuario_id': usuarioId,
        'criadoEm': agora.toIso8601String(),
        'atualizadoEm': agora.toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      return Contrato(
        id: id,
        titulo: titulo,
        nomeEmpresa: nomeEmpresa,
        status: status,
        descricao: descricao,
        dataGeracao: dataGeracao,
        link: link,
        usuarioId: usuarioId,
        criadoEm: agora,
        atualizadoEm: agora,
      );
    } catch (e) {
      throw Exception('Erro ao criar contrato: $e');
    }
  }

  Future<Contrato?> buscarPorId(int id) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'contratos',
      where: 'id = ? AND excluidoEm IS NULL',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Contrato.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Contrato>> listarTodos({int? limite, int? offset}) async {
    final db = await _db;

    String query =
        'SELECT * FROM contratos WHERE excluidoEm IS NULL ORDER BY criadoEm DESC';
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
      return Contrato.fromMap(maps[i]);
    });
  }

  Future<List<Contrato>> buscarPorTitulo(String titulo) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'contratos',
      where: 'nome LIKE ? AND excluidoEm IS NULL',
      whereArgs: ['%$titulo%'],
      orderBy: 'criadoEm DESC',
    );

    return List.generate(maps.length, (i) {
      return Contrato.fromMap(maps[i]);
    });
  }

  Future<List<Contrato>> listarPorStatus(String status) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'contratos',
      where: 'status = ? AND excluidoEm IS NULL',
      whereArgs: [status],
      orderBy: 'criadoEm DESC',
    );

    return List.generate(maps.length, (i) {
      return Contrato.fromMap(maps[i]);
    });
  }

  Future<bool> atualizarContrato(Contrato contrato) async {
    final db = await _db;

    try {
      contrato.atualizadoEm = DateTime.now();

      final count = await db.update(
        'contratos',
        {
          'nome': contrato.titulo,
          'descricao': contrato.descricao,
          'status': contrato.status,
          'caminho': contrato.link,
          'atualizadoEm': contrato.atualizadoEm!.toIso8601String(),
        },
        where: 'id = ? AND excluidoEm IS NULL',
        whereArgs: [contrato.id],
      );

      return count > 0;
    } catch (e) {
      throw Exception('Erro ao atualizar contrato: $e');
    }
  }

  Future<bool> excluirContrato(int id) async {
    final db = await _db;

    try {
      final agora = DateTime.now();
      final count = await db.update(
        'contratos',
        {
          'excluidoEm': agora.toIso8601String(),
          'atualizadoEm': agora.toIso8601String(),
        },
        where: 'id = ? AND excluidoEm IS NULL',
        whereArgs: [id],
      );

      return count > 0;
    } catch (e) {
      throw Exception('Erro ao excluir contrato: $e');
    }
  }

  Future<int> contarContratos({String? status, bool? apenasExcluidos}) async {
    final db = await _db;
    String where = '';
    List<dynamic> whereArgs = [];

    if (apenasExcluidos == true) {
      where = 'excluidoEm IS NOT NULL';
    } else if (apenasExcluidos == false) {
      where = 'excluidoEm IS NULL';

      if (status != null) {
        where += ' AND status = ?';
        whereArgs.add(status);
      }
    }

    final List<Map<String, dynamic>> result = await db.query(
      'contratos',
      columns: ['COUNT(*) as count'],
      where: where.isNotEmpty ? where : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );

    return result.first['count'] as int;
  }
}
