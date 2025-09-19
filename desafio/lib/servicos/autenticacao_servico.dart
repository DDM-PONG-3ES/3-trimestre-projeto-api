import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:desafio/modelo/dao/usuario_dao.dart';
import 'package:desafio/modelo/entidades/usuario/usuario.dart';

class AutenticacaoServico extends ChangeNotifier {
  static final AutenticacaoServico _instance = AutenticacaoServico._internal();
  factory AutenticacaoServico() => _instance;
  AutenticacaoServico._internal();

  final UsuarioDAO _usuarioDAO = UsuarioDAO();
  Usuario? _usuarioAtual;
  bool _isLogado = false;
  bool _isCarregando = false;

  Usuario? get usuarioAtual => _usuarioAtual;
  bool get isLogado => _isLogado;
  bool get isCarregando => _isCarregando;

  Future<void> inicializar() async {
    _isCarregando = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('usuario_id');

      if (userId != null) {
        _usuarioAtual = await _usuarioDAO.buscarPorId(userId);
        _isLogado = _usuarioAtual != null;
      }
    } catch (e) {
      print('Erro ao inicializar autenticação: $e');
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String senha) async {
    _isCarregando = true;
    notifyListeners();

    try {
      if (email.isEmpty || senha.isEmpty) {
        throw Exception('Email e senha são obrigatórios');
      }

      final usuario = await _usuarioDAO.autenticar(email, senha);

      if (usuario != null) {
        _usuarioAtual = usuario;
        _isLogado = true;

        // Salvar ID do usuário no SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('usuario_id', usuario.id!);

        notifyListeners();
        return true;
      } else {
        throw Exception('Email ou senha inválidos');
      }
    } catch (e) {
      print('Erro no login: $e');
      rethrow;
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<bool> registro(String nome, String email, String senha) async {
    _isCarregando = true;
    notifyListeners();

    try {
      if (nome.isEmpty || email.isEmpty || senha.isEmpty) {
        throw Exception('Todos os campos são obrigatórios');
      }

      if (senha.length < 6) {
        throw Exception('A senha deve ter pelo menos 6 caracteres');
      }

      if (!_isEmailValido(email)) {
        throw Exception('Email inválido');
      }

      final usuario = await _usuarioDAO.criarUsuario(nome, email, senha);

      if (usuario != null) {
        _usuarioAtual = usuario;
        _isLogado = true;

        // Salvar ID do usuário no SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('usuario_id', usuario.id!);

        notifyListeners();
        return true;
      } else {
        throw Exception('Erro ao criar usuário');
      }
    } catch (e) {
      print('Erro no registro: $e');
      rethrow;
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isCarregando = true;
    notifyListeners();

    try {
      _usuarioAtual = null;
      _isLogado = false;

      // Remover dados do SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('usuario_id');
    } catch (e) {
      print('Erro no logout: $e');
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  bool _isEmailValido(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
