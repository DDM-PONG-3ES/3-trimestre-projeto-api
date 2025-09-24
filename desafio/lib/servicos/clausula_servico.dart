import 'package:flutter/foundation.dart';
import 'package:desafio/modelo/dao/clausula_dao.dart';
import 'package:desafio/modelo/entidades/clausula/clausula.dart';

class ClausulaServico extends ChangeNotifier {
  static final ClausulaServico _instance = ClausulaServico._internal();
  factory ClausulaServico() => _instance;
  ClausulaServico._internal();

  final ClausulaDAO _clausulaDAO = ClausulaDAO();

  List<Clausula> _clausulas = [];
  bool _isCarregando = false;
  String? _erro;

  List<Clausula> get clausulas => _clausulas;
  bool get isCarregando => _isCarregando;
  String? get erro => _erro;

  Future<void> carregarClausulas() async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      _clausulas = await _clausulaDAO.listarTodas();
    } catch (e) {
      _erro = 'Erro ao carregar cláusulas: $e';
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<void> carregarClausulasPorContrato(int contratoId) async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      _clausulas = await _clausulaDAO.listarPorContrato(contratoId);
    } catch (e) {
      _erro = 'Erro ao carregar cláusulas do contrato: $e';
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<bool> criarClausula({
    required String texto,
    required String tipo,
    required String status,
    required int contratoId,
  }) async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      if (texto.trim().isEmpty) {
        throw Exception('O texto da cláusula é obrigatório');
      }

      if (tipo.trim().isEmpty) {
        throw Exception('O tipo da cláusula é obrigatório');
      }

      final clausula = await _clausulaDAO.criarClausula(
        texto.trim(),
        tipo.trim(),
        status.trim(),
        contratoId,
      );

      if (clausula != null) {
        _clausulas.insert(0, clausula);
        notifyListeners();
        return true;
      }

      throw Exception('Erro ao criar cláusula');
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<bool> atualizarClausula(Clausula clausula) async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      if (clausula.texto?.trim().isEmpty == true) {
        throw Exception('O texto da cláusula é obrigatório');
      }

      if (clausula.tipo?.trim().isEmpty == true) {
        throw Exception('O tipo da cláusula é obrigatório');
      }

      final sucesso = await _clausulaDAO.atualizarClausula(clausula);

      if (sucesso) {
        final index = _clausulas.indexWhere((c) => c.id == clausula.id);
        if (index != -1) {
          _clausulas[index] = clausula;
          notifyListeners();
        }
        return true;
      }

      throw Exception('Erro ao atualizar cláusula');
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<bool> excluirClausula(int id) async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      final sucesso = await _clausulaDAO.excluirClausula(id);

      if (sucesso) {
        _clausulas.removeWhere((clausula) => clausula.id == id);
        notifyListeners();
        return true;
      }

      throw Exception('Erro ao excluir cláusula');
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<List<Clausula>> buscarPorTipo(String tipo) async {
    try {
      return await _clausulaDAO.buscarPorTipo(tipo);
    } catch (e) {
      _erro = 'Erro ao buscar cláusulas por tipo: $e';
      notifyListeners();
      return [];
    }
  }

  void limparErro() {
    _erro = null;
    notifyListeners();
  }
}
