import 'package:flutter/foundation.dart';
import 'package:desafio/modelo/dao/contrato_dao.dart';
import 'package:desafio/modelo/entidades/contrato/contrato.dart';

class ContratoServico extends ChangeNotifier {
  static final ContratoServico _instance = ContratoServico._internal();
  factory ContratoServico() => _instance;
  ContratoServico._internal();

  final ContratoDAO _contratoDAO = ContratoDAO();

  List<Contrato> _contratos = [];
  bool _isCarregando = false;
  String? _erro;

  List<Contrato> get contratos => _contratos;
  bool get isCarregando => _isCarregando;
  String? get erro => _erro;

  Future<void> carregarContratos() async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      _contratos = await _contratoDAO.listarTodos();
    } catch (e) {
      _erro = 'Erro ao carregar contratos: $e';
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<bool> criarContrato({
    required String titulo,
    required String nomeEmpresa,
    required String status,
    required String descricao,
    required String dataGeracao,
    required String link,
  }) async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      if (titulo.trim().isEmpty) {
        throw Exception('O título do contrato é obrigatório');
      }

      if (nomeEmpresa.trim().isEmpty) {
        throw Exception('O nome da empresa é obrigatório');
      }

      final contrato = await _contratoDAO.criarContrato(
        titulo.trim(),
        nomeEmpresa.trim(),
        status.trim(),
        descricao.trim(),
        dataGeracao.trim(),
        link.trim(),
      );

      if (contrato != null) {
        _contratos.insert(0, contrato);
        notifyListeners();
        return true;
      }

      throw Exception('Erro ao criar contrato');
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<bool> atualizarContrato(Contrato contrato) async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      if (contrato.titulo?.trim().isEmpty == true) {
        throw Exception('O título do contrato é obrigatório');
      }

      if (contrato.nomeEmpresa?.trim().isEmpty == true) {
        throw Exception('O nome da empresa é obrigatório');
      }

      final sucesso = await _contratoDAO.atualizarContrato(contrato);

      if (sucesso) {
        final index = _contratos.indexWhere((c) => c.id == contrato.id);
        if (index != -1) {
          _contratos[index] = contrato;
          notifyListeners();
        }
        return true;
      }

      throw Exception('Erro ao atualizar contrato');
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<bool> excluirContrato(int id) async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      final sucesso = await _contratoDAO.excluirContrato(id);

      if (sucesso) {
        _contratos.removeWhere((contrato) => contrato.id == id);
        notifyListeners();
        return true;
      }

      throw Exception('Erro ao excluir contrato');
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<List<Contrato>> buscarPorTitulo(String titulo) async {
    try {
      if (titulo.trim().isEmpty) {
        return _contratos;
      }
      return await _contratoDAO.buscarPorTitulo(titulo.trim());
    } catch (e) {
      _erro = 'Erro ao buscar contratos: $e';
      notifyListeners();
      return [];
    }
  }

  Future<List<Contrato>> listarPorStatus(String status) async {
    try {
      return await _contratoDAO.listarPorStatus(status);
    } catch (e) {
      _erro = 'Erro ao carregar contratos por status: $e';
      notifyListeners();
      return [];
    }
  }

  void limparErro() {
    _erro = null;
    notifyListeners();
  }
}
