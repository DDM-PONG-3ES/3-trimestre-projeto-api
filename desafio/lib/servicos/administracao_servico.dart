import 'package:flutter/foundation.dart';
import 'package:desafio/modelo/dao/administracao_dao.dart';
import 'package:desafio/modelo/entidades/administracao/administracao.dart';

class AdministracaoServico extends ChangeNotifier {
  static final AdministracaoServico _instance = AdministracaoServico._internal();
  factory AdministracaoServico() => _instance;
  AdministracaoServico._internal();

  final AdministracaoDAO _administracaoDAO = AdministracaoDAO();

  List<Administracao> _administracoes = [];
  bool _isCarregando = false;
  String? _erro;

  List<Administracao> get administracoes => _administracoes;
  bool get isCarregando => _isCarregando;
  String? get erro => _erro;

  Future<void> carregarAdministracoes() async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      _administracoes = await _administracaoDAO.listarTodas();
    } catch (e) {
      _erro = 'Erro ao carregar administrações: $e';
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<void> carregarAdministracoesPorClausula(int clausulaId) async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      _administracoes = await _administracaoDAO.listarPorClausula(clausulaId);
    } catch (e) {
      _erro = 'Erro ao carregar administrações da cláusula: $e';
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<bool> criarAdministracao({
    required String nomeAdministrador,
    required String poderesAdministrativos,
    required int clausulaId,
  }) async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      if (nomeAdministrador.trim().isEmpty) {
        throw Exception('O nome do administrador é obrigatório');
      }

      if (poderesAdministrativos.trim().isEmpty) {
        throw Exception('Os poderes administrativos são obrigatórios');
      }

      final administracao = await _administracaoDAO.criar(
        nomeAdministrador.trim(),
        poderesAdministrativos.trim(),
        clausulaId,
      );

      if (administracao != null) {
        _administracoes.insert(0, administracao);
        notifyListeners();
        return true;
      }

      throw Exception('Erro ao criar administração');
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<bool> atualizarAdministracao(Administracao administracao) async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      if (administracao.nomeAdministrador?.trim().isEmpty == true) {
        throw Exception('O nome do administrador é obrigatório');
      }

      if (administracao.poderesAdministrativos?.trim().isEmpty == true) {
        throw Exception('Os poderes administrativos são obrigatórios');
      }

      final sucesso = await _administracaoDAO.atualizar(administracao);

      if (sucesso) {
        final index = _administracoes.indexWhere((a) => a.id == administracao.id);
        if (index != -1) {
          _administracoes[index] = administracao;
          notifyListeners();
        }
        return true;
      }

      throw Exception('Erro ao atualizar administração');
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<bool> excluirAdministracao(int id) async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      final sucesso = await _administracaoDAO.excluir(id);

      if (sucesso) {
        _administracoes.removeWhere((administracao) => administracao.id == id);
        notifyListeners();
        return true;
      }

      throw Exception('Erro ao excluir administração');
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  void limparErro() {
    _erro = null;
    notifyListeners();
  }
}