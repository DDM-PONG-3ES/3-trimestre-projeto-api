import 'package:desafio/comum/config/banco/conexao.dart';
import 'package:desafio/modelo/entidades/usuario/usuario.dart';
import 'package:sqflite/sqflite.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class UsuarioDAO {
  static final UsuarioDAO _instance = UsuarioDAO._internal();
  factory UsuarioDAO() => _instance;
  UsuarioDAO._internal();

  Future<Database> get _db async => await Conexao().database;

  String _hashSenha(String senha) {
    var bytes = utf8.encode(senha);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<Usuario?> criarUsuario(String nome, String email, String senha) async {
    final db = await _db;

    try {
      // Verificar se email já existe
      final existingUser = await buscarPorEmail(email);
      if (existingUser != null) {
        throw Exception('Email já cadastrado');
      }

      final senhaHash = _hashSenha(senha);
      final id = await db.insert('usuarios', {
        'nome': nome,
        'email': email,
        'senha': senhaHash,
        'criadoEm': DateTime.now().toIso8601String(),
        'atualizadoEm': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.abort);

      return Usuario(
        id: id,
        nome: nome,
        email: email,
        criadoEm: DateTime.now(),
        atualizadoEm: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Erro ao criar usuário: $e');
    }
  }

  Future<Usuario?> buscarPorEmail(String email) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'email = ? AND excluidoEm IS NULL',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      return Usuario(
        id: map['id'],
        nome: map['nome'],
        email: map['email'],
        criadoEm:
            map['criadoEm'] != null ? DateTime.parse(map['criadoEm']) : null,
        atualizadoEm:
            map['atualizadoEm'] != null
                ? DateTime.parse(map['atualizadoEm'])
                : null,
        excluidoEm:
            map['excluidoEm'] != null
                ? DateTime.parse(map['excluidoEm'])
                : null,
      );
    }
    return null;
  }

  Future<Usuario?> autenticar(String email, String senha) async {
    final db = await _db;
    final senhaHash = _hashSenha(senha);

    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'email = ? AND senha = ? AND excluidoEm IS NULL',
      whereArgs: [email, senhaHash],
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      return Usuario(
        id: map['id'],
        nome: map['nome'],
        email: map['email'],
        criadoEm:
            map['criadoEm'] != null ? DateTime.parse(map['criadoEm']) : null,
        atualizadoEm:
            map['atualizadoEm'] != null
                ? DateTime.parse(map['atualizadoEm'])
                : null,
        excluidoEm:
            map['excluidoEm'] != null
                ? DateTime.parse(map['excluidoEm'])
                : null,
      );
    }
    return null;
  }

  Future<Usuario?> buscarPorId(int id) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'id = ? AND excluidoEm IS NULL',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      return Usuario(
        id: map['id'],
        nome: map['nome'],
        email: map['email'],
        criadoEm:
            map['criadoEm'] != null ? DateTime.parse(map['criadoEm']) : null,
        atualizadoEm:
            map['atualizadoEm'] != null
                ? DateTime.parse(map['atualizadoEm'])
                : null,
        excluidoEm:
            map['excluidoEm'] != null
                ? DateTime.parse(map['excluidoEm'])
                : null,
      );
    }
    return null;
  }

  Future<List<Usuario>> listarTodos() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'excluidoEm IS NULL',
      orderBy: 'nome ASC',
    );

    return List.generate(maps.length, (i) {
      final map = maps[i];
      return Usuario(
        id: map['id'],
        nome: map['nome'],
        email: map['email'],
        criadoEm:
            map['criadoEm'] != null ? DateTime.parse(map['criadoEm']) : null,
        atualizadoEm:
            map['atualizadoEm'] != null
                ? DateTime.parse(map['atualizadoEm'])
                : null,
        excluidoEm:
            map['excluidoEm'] != null
                ? DateTime.parse(map['excluidoEm'])
                : null,
      );
    });
  }
}
