import 'package:flutter/foundation.dart';
import 'package:desafio/modelo/dao/sede_dao.dart';
import 'package:desafio/modelo/entidades/sede/sede.dart';

class SedeServico extends ChangeNotifier {
  static final SedeServico _instance = SedeServico._internal();
  factory SedeServico() => _instance;
  SedeServico._internal();

  final SedeDAO _sedeDAO = SedeDAO();

  List<Sede> _sedes = [];
  bool _isCarregando = false;
  String? _erro;

  List<Sede> get sedes => _sedes;
  bool get isCarregando => _isCarregando;
  String? get erro => _erro;

  Future<void> carregarSedes() async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      _sedes = await _sedeDAO.listarTodas();
    } catch (e) {
      _erro = 'Erro ao carregar sedes: $e';
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<void> carregarSedesPorClausula(int clausulaId) async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      _sedes = await _sedeDAO.listarPorClausula(clausulaId);
    } catch (e) {
      _erro = 'Erro ao carregar sedes da cláusula: $e';
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<bool> criarSede({
    required String enderecoCompleto,
    required int clausulaId,
  }) async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      if (enderecoCompleto.trim().isEmpty) {
        throw Exception('O endereço completo é obrigatório');
      }

      final sede = await _sedeDAO.criar(enderecoCompleto.trim(), clausulaId);

      if (sede != null) {
        _sedes.insert(0, sede);
        notifyListeners();
        return true;
      }

      throw Exception('Erro ao criar sede');
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<bool> atualizarSede(Sede sede) async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      if (sede.enderecoCompleto?.trim().isEmpty == true) {
        throw Exception('O endereço completo é obrigatório');
      }

      final sucesso = await _sedeDAO.atualizar(sede);

      if (sucesso) {
        final index = _sedes.indexWhere((s) => s.id == sede.id);
        if (index != -1) {
          _sedes[index] = sede;
          notifyListeners();
        }
        return true;
      }

      throw Exception('Erro ao atualizar sede');
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<bool> excluirSede(int id) async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      final sucesso = await _sedeDAO.excluir(id);

      if (sucesso) {
        _sedes.removeWhere((sede) => sede.id == id);
        notifyListeners();
        return true;
      }

      throw Exception('Erro ao excluir sede');
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
