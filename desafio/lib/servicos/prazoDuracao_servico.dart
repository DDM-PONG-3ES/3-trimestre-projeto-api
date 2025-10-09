import 'package:flutter/foundation.dart';
import 'package:desafio/modelo/dao/prazoDuracao_dao.dart';
import 'package:desafio/modelo/entidades/prazoDuracao/prazoDuracao.dart';

class PrazoDuracaoServico extends ChangeNotifier {
  static final PrazoDuracaoServico _instance = PrazoDuracaoServico._internal();
  factory PrazoDuracaoServico() => _instance;
  PrazoDuracaoServico._internal();

  final PrazoDuracaoDAO _prazoDuracaoDAO = PrazoDuracaoDAO();
  List<PrazoDuracao> _prazosDuracao = [];
  bool _isCarregando = false;
  String? _erro;

  List<PrazoDuracao> get prazosDuracao => _prazosDuracao;
  bool get isCarregando => _isCarregando;
  String? get erro => _erro;

  Future<void> carregarPrazosDuracao() async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();
    try {
      _prazosDuracao = await _prazoDuracaoDAO.listarTodas();
    } catch (e) {
      _erro = 'Erro ao carregar prazos de duração: $e';
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<bool> criarPrazoDuracao({required String tipoPrazo}) async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();
    try {
      if (tipoPrazo.trim().isEmpty) {
        throw Exception('O tipo de prazo é obrigatório');
      }
      final prazoDuracao = await _prazoDuracaoDAO.criarPrazoDuracao(
        tipoPrazo: tipoPrazo.trim(),
      );
      if (prazoDuracao != null) {
        _prazosDuracao.insert(0, prazoDuracao);
        notifyListeners();
        return true;
      }
      throw Exception('Erro ao criar prazo de duração');
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<bool> atualizarPrazoDuracao(PrazoDuracao prazoDuracao) async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();
    try {
      if (prazoDuracao.tipoPrazo?.trim().isEmpty == true) {
        throw Exception('O tipo de prazo é obrigatório');
      }
      final sucesso = await _prazoDuracaoDAO.atualizarPrazoDuracao(
        prazoDuracao,
      );
      if (sucesso) {
        final index = _prazosDuracao.indexWhere((p) => p.id == prazoDuracao.id);
        if (index != -1) {
          _prazosDuracao[index] = prazoDuracao;
          notifyListeners();
        }
        return true;
      }
      throw Exception('Erro ao atualizar prazo de duração');
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<bool> excluirPrazoDuracao(int id) async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();
    try {
      final sucesso = await _prazoDuracaoDAO.excluirPrazoDuracao(id);
      if (sucesso) {
        _prazosDuracao.removeWhere((prazoDuracao) => prazoDuracao.id == id);
        notifyListeners();
        return true;
      }
      throw Exception('Erro ao excluir prazo de duração');
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
