import 'package:desafio/modelo/dao/capitalSocial_dao.dart';
import 'package:desafio/modelo/entidades/capitalSocial/capitalSocial.dart';
import 'package:flutter/foundation.dart';

class CapitalSocialServico extends ChangeNotifier {
  static final CapitalSocialServico _instance =
      CapitalSocialServico._internal();
  factory CapitalSocialServico() => _instance;
  CapitalSocialServico._internal();

  final CapitalSocialDAO _capitalSocialDAO = CapitalSocialDAO();

  List<CapitalSocial> _capitaisSociais = [];
  bool _isCarregando = false;
  String? _erro;

  List<CapitalSocial> get capitaisSociais => _capitaisSociais;
  bool get isCarregando => _isCarregando;
  String? get erro => _erro;

  Future<void> carregarCapitaisSociais() async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      _capitaisSociais = await _capitalSocialDAO.listarTodos();
    } catch (e) {
      _erro = 'Erro ao carregar capitais sociais: $e';
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<void> carregarCapitaisSociaisPorClausula(int clausulaId) async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      _capitaisSociais = await _capitalSocialDAO.listarPorClausula(clausulaId);
    } catch (e) {
      _erro = 'Erro ao carregar capitais sociais da cláusula: $e';
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<bool> criarCapitalSocial({
    required double valorTotal,
    required String divisaoQuotas,
    required String formaIntegralizacao,
    required int clausulaId,
  }) async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      if (valorTotal <= 0) {
        throw Exception('O valor total deve ser maior que zero');
      }

      if (divisaoQuotas.trim().isEmpty) {
        throw Exception('A divisão de quotas é obrigatória');
      }

      if (formaIntegralizacao.trim().isEmpty) {
        throw Exception('A forma de integralização é obrigatória');
      }

      final capitalSocial = await _capitalSocialDAO.criar(
        valorTotal,
        divisaoQuotas.trim(),
        formaIntegralizacao.trim(),
        clausulaId,
      );

      if (capitalSocial != null) {
        _capitaisSociais.insert(0, capitalSocial);
        notifyListeners();
        return true;
      }

      throw Exception('Erro ao criar capital social');
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<bool> atualizarCapitalSocial(CapitalSocial capitalSocial) async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      if (capitalSocial.valorTotal == null || capitalSocial.valorTotal! <= 0) {
        throw Exception('O valor total deve ser maior que zero');
      }

      if (capitalSocial.divisaoQuotas?.trim().isEmpty == true) {
        throw Exception('A divisão de quotas é obrigatória');
      }

      if (capitalSocial.formaIntegralizacao?.trim().isEmpty == true) {
        throw Exception('A forma de integralização é obrigatória');
      }

      final sucesso = await _capitalSocialDAO.atualizar(capitalSocial);

      if (sucesso) {
        final index = _capitaisSociais.indexWhere(
          (c) => c.id == capitalSocial.id,
        );
        if (index != -1) {
          _capitaisSociais[index] = capitalSocial;
          notifyListeners();
        }
        return true;
      }

      throw Exception('Erro ao atualizar capital social');
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<bool> excluirCapitalSocial(int id) async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      final sucesso = await _capitalSocialDAO.excluir(id);

      if (sucesso) {
        _capitaisSociais.removeWhere((capitalSocial) => capitalSocial.id == id);
        notifyListeners();
        return true;
      }

      throw Exception('Erro ao excluir capital social');
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
