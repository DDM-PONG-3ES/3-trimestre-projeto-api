import 'package:desafio/modelo/dao/objetoSocial_dao.dart';
import 'package:desafio/modelo/entidades/objetoSocial/objetoSocial.dart';
import 'package:flutter/foundation.dart';

class ObjetoSocialServico extends ChangeNotifier {
  static final ObjetoSocialServico _instance = ObjetoSocialServico._internal();
  factory ObjetoSocialServico() => _instance;
  ObjetoSocialServico._internal();

  final ObjetoSocialDao _objetoSocialDao = ObjetoSocialDao();

  List<ObjetoSocial> _objetosSociais = [];
  bool _isCarregando = false;
  String? _erro;

  List<ObjetoSocial> get objetosSociais => _objetosSociais;
  bool get isCarregando => _isCarregando;
  String? get erro => _erro;

  Future<void> carregarObjetosSociais() async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      _objetosSociais = await _objetoSocialDao.listarTodos();
    } catch (e) {
      _erro = 'Erro ao carregar objetos sociais: $e';
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<bool> criarObjetoSocial(ObjetoSocial objetoSocial) async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      if (objetoSocial.atividadesEconomicas.trim().isEmpty) {
        throw Exception('Atividades econômicas são obrigatórias');
      }
      if (objetoSocial.atividadesExercidas.trim().isEmpty) {
        throw Exception('Atividades exercidas são obrigatórias');
      }

      final id = await _objetoSocialDao.inserir(objetoSocial);
      if (id > 0) {
        objetoSocial.id = id;
        _objetosSociais.insert(0, objetoSocial);
        notifyListeners();
        return true;
      }

      throw Exception('Erro ao criar objeto social');
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<bool> atualizarObjetoSocial(ObjetoSocial objetoSocial) async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      if (objetoSocial.id == null) {
        throw Exception('ID do objeto social não pode ser nulo');
      }
      if (objetoSocial.atividadesEconomicas.trim().isEmpty) {
        throw Exception('Atividades econômicas são obrigatórias');
      }

      final sucesso = await _objetoSocialDao.atualizar(objetoSocial);
      if (sucesso > 0) {
        final index = _objetosSociais.indexWhere((o) => o.id == objetoSocial.id);
        if (index != -1) {
          _objetosSociais[index] = objetoSocial;
          notifyListeners();
        }
        return true;
      }

      throw Exception('Erro ao atualizar objeto social');
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<bool> deletarObjetoSocial(int id) async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      final sucesso = await _objetoSocialDao.deletar(id);
      if (sucesso > 0) {
        _objetosSociais.removeWhere((obj) => obj.id == id);
        notifyListeners();
        return true;
      }

      throw Exception('Erro ao deletar objeto social');
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<bool> deletarObjetoSocialPermanente(int id) async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      final sucesso = await _objetoSocialDao.deletarPermanente(id);
      if (sucesso > 0) {
        _objetosSociais.removeWhere((obj) => obj.id == id);
        notifyListeners();
        return true;
      }

      throw Exception('Erro ao deletar objeto social permanentemente');
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<ObjetoSocial?> buscarObjetoSocialPorId(int id) async {
    try {
      return await _objetoSocialDao.buscarPorId(id);
    } catch (e) {
      _erro = 'Erro ao buscar objeto social: $e';
      notifyListeners();
      return null;
    }
  }

  Future<List<ObjetoSocial>> buscarPorAtividade(String atividade) async {
    try {
      if (atividade.trim().isEmpty) {
        return _objetosSociais;
      }
      return await _objetoSocialDao.buscarPorAtividade(atividade.trim());
    } catch (e) {
      _erro = 'Erro ao buscar objetos sociais por atividade: $e';
      notifyListeners();
      return [];
    }
  }

  Future<int> contarObjetosSociais() async {
    try {
      return await _objetoSocialDao.contarObjetosSociais();
    } catch (e) {
      _erro = 'Erro ao contar objetos sociais: $e';
      notifyListeners();
      return 0;
    }
  }

  void limparErro() {
    _erro = null;
    notifyListeners();
  }
}
