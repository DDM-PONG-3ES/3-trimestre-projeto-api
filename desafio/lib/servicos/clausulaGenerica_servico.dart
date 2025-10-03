import 'package:flutter/foundation.dart';
import 'package:desafio/modelo/dao/clausulaGenerica_dao.dart';
import 'package:desafio/modelo/entidades/clausulaGenerica/clausulaGenerica.dart';

class ClausulaGenericaServico extends ChangeNotifier {
  static final ClausulaGenericaServico _instance =
      ClausulaGenericaServico._internal();
  factory ClausulaGenericaServico() => _instance;
  ClausulaGenericaServico._internal();

  final ClausulaGenericaDAO _clausulaGenericaDAO = ClausulaGenericaDAO();
  List<ClausulaGenerica> _clausulasGenericas = [];
  bool _isCarregando = false;
  String? _erro;

  List<ClausulaGenerica> get clausulasGenericas => _clausulasGenericas;
  bool get isCarregando => _isCarregando;
  String? get erro => _erro;

  Future<void> carregarClausulasGenericas() async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();
    try {
      _clausulasGenericas = await _clausulaGenericaDAO.listarTodas();
    } catch (e) {
      _erro = 'Erro ao carregar cláusulas genéricas: $e';
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<bool> criarClausulaGenerica({
    required String nomeClausula,
    required String conteudo,
  }) async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();
    try {
      if (nomeClausula.trim().isEmpty) {
        throw Exception('O nome da cláusula é obrigatório');
      }
      if (conteudo.trim().isEmpty) {
        throw Exception('O conteúdo da cláusula é obrigatório');
      }
      final clausulaGenerica = await _clausulaGenericaDAO.criarClausulaGenerica(
        nomeClausula: nomeClausula.trim(),
        conteudo: conteudo.trim(),
      );
      if (clausulaGenerica != null) {
        _clausulasGenericas.insert(0, clausulaGenerica);
        notifyListeners();
        return true;
      }
      throw Exception('Erro ao criar cláusula genérica');
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<bool> atualizarClausulaGenerica(
    ClausulaGenerica clausulaGenerica,
  ) async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();
    try {
      if (clausulaGenerica.nomeClausula?.trim().isEmpty == true) {
        throw Exception('O nome da cláusula é obrigatório');
      }
      if (clausulaGenerica.conteudo?.trim().isEmpty == true) {
        throw Exception('O conteúdo da cláusula é obrigatório');
      }
      final sucesso = await _clausulaGenericaDAO.atualizarClausulaGenerica(
        clausulaGenerica,
      );
      if (sucesso) {
        final index = _clausulasGenericas.indexWhere(
          (c) => c.id == clausulaGenerica.id,
        );
        if (index != -1) {
          _clausulasGenericas[index] = clausulaGenerica;
          notifyListeners();
        }
        return true;
      }
      throw Exception('Erro ao atualizar cláusula genérica');
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<bool> excluirClausulaGenerica(int id) async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();
    try {
      final sucesso = await _clausulaGenericaDAO.excluirClausulaGenerica(id);
      if (sucesso) {
        _clausulasGenericas.removeWhere(
          (clausulaGenerica) => clausulaGenerica.id == id,
        );
        notifyListeners();
        return true;
      }
      throw Exception('Erro ao excluir cláusula genérica');
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
