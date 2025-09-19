import 'package:flutter/foundation.dart';
import 'package:desafio/modelo/dao/recado_dao.dart';
import 'package:desafio/modelo/entidades/recado/recado.dart';

class RecadoServico extends ChangeNotifier {
  static final RecadoServico _instance = RecadoServico._internal();
  factory RecadoServico() => _instance;
  RecadoServico._internal();

  final RecadoDAO _recadoDAO = RecadoDAO();

  List<Recado> _recados = [];
  bool _isCarregando = false;
  String? _erro;

  List<Recado> get recados => _recados;
  bool get isCarregando => _isCarregando;
  String? get erro => _erro;

  Future<void> carregarRecados() async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      _recados = await _recadoDAO.listarTodos();
    } catch (e) {
      _erro = 'Erro ao carregar recados: $e';
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<bool> criarRecado({required String nome, String? erroIA}) async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      if (nome.trim().isEmpty) {
        throw Exception('O nome do recado é obrigatório');
      }

      final recado = await _recadoDAO.criarRecado(nome.trim(), erroIA);

      if (recado != null) {
        _recados.insert(0, recado);
        notifyListeners();
        return true;
      }

      throw Exception('Erro ao criar recado');
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<bool> atualizarRecado(Recado recado) async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      if (recado.nome?.trim().isEmpty == true) {
        throw Exception('O nome do recado é obrigatório');
      }

      final sucesso = await _recadoDAO.atualizarRecado(recado);

      if (sucesso) {
        final index = _recados.indexWhere((r) => r.id == recado.id);
        if (index != -1) {
          _recados[index] = recado;
          notifyListeners();
        }
        return true;
      }

      throw Exception('Erro ao atualizar recado');
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<bool> excluirRecado(int id) async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      final sucesso = await _recadoDAO.excluirRecado(id);

      if (sucesso) {
        _recados.removeWhere((recado) => recado.id == id);
        notifyListeners();
        return true;
      }

      throw Exception('Erro ao excluir recado');
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<bool> excluirDefinitivamente(int id) async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      final sucesso = await _recadoDAO.excluirDefinitivamente(id);

      if (sucesso) {
        _recados.removeWhere((recado) => recado.id == id);
        notifyListeners();
        return true;
      }

      throw Exception('Erro ao excluir recado definitivamente');
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<bool> restaurarRecado(int id) async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      final sucesso = await _recadoDAO.restaurarRecado(id);

      if (sucesso) {
        // Recarregar a lista para incluir o recado restaurado
        await carregarRecados();
        return true;
      }

      throw Exception('Erro ao restaurar recado');
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<List<Recado>> buscarPorNome(String nome) async {
    try {
      if (nome.trim().isEmpty) {
        return _recados;
      }
      return await _recadoDAO.buscarPorNome(nome.trim());
    } catch (e) {
      _erro = 'Erro ao buscar recados: $e';
      notifyListeners();
      return [];
    }
  }

  Future<List<Recado>> listarComErros() async {
    try {
      return await _recadoDAO.listarComErros();
    } catch (e) {
      _erro = 'Erro ao carregar recados com erros: $e';
      notifyListeners();
      return [];
    }
  }

  Future<List<Recado>> listarSemErros() async {
    try {
      return await _recadoDAO.listarSemErros();
    } catch (e) {
      _erro = 'Erro ao carregar recados sem erros: $e';
      notifyListeners();
      return [];
    }
  }

  Future<List<Recado>> listarExcluidos() async {
    try {
      return await _recadoDAO.listarExcluidos();
    } catch (e) {
      _erro = 'Erro ao carregar recados excluídos: $e';
      notifyListeners();
      return [];
    }
  }

  Future<Recado?> buscarPorId(int id) async {
    try {
      return await _recadoDAO.buscarPorId(id);
    } catch (e) {
      _erro = 'Erro ao buscar recado: $e';
      notifyListeners();
      return null;
    }
  }

  Future<int> contarRecados({
    bool? apenasComErros,
    bool? apenasExcluidos,
  }) async {
    try {
      return await _recadoDAO.contarRecados(
        apenasComErros: apenasComErros,
        apenasExcluidos: apenasExcluidos,
      );
    } catch (e) {
      _erro = 'Erro ao contar recados: $e';
      notifyListeners();
      return 0;
    }
  }

  Future<void> limparRecadosExcluidos() async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      await _recadoDAO.limparRecadosExcluidos();
    } catch (e) {
      _erro = 'Erro ao limpar recados excluídos: $e';
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
