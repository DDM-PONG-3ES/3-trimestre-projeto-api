import 'package:desafio/modelo/dao/socio_dao.dart';
import 'package:desafio/modelo/entidades/socio/socio.dart';
import 'package:flutter/foundation.dart';

class SocioServico extends ChangeNotifier {
  static final SocioServico _instance = SocioServico._internal();
  factory SocioServico() => _instance;
  SocioServico._internal();

  final SocioDao _socioDao = SocioDao();

  List<Socio> _socios = [];
  bool _isCarregando = false;
  String? _erro;

  List<Socio> get socios => _socios;
  bool get isCarregando => _isCarregando;
  String? get erro => _erro;

  Future<void> carregarSocios() async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      _socios = await _socioDao.listarTodos();
    } catch (e) {
      _erro = 'Erro ao carregar sócios: $e';
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<bool> criarSocio(Socio socio) async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      if (socio.nome.trim().isEmpty) {
        throw Exception('Nome é obrigatório');
      }
      if (socio.cpf.trim().isEmpty) {
        throw Exception('CPF é obrigatório');
      }
      if (!validarCPF(socio.cpf)) {
        throw Exception('CPF inválido');
      }

      final id = await _socioDao.inserir(socio);
      if (id > 0) {
        socio.id = id;
        _socios.insert(0, socio);
        notifyListeners();
        return true;
      }

      throw Exception('Erro ao criar sócio');
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<bool> atualizarSocio(Socio socio) async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      if (socio.id == null) {
        throw Exception('ID do sócio não pode ser nulo');
      }
      if (socio.nome.trim().isEmpty) {
        throw Exception('Nome é obrigatório');
      }

      final sucesso = await _socioDao.atualizar(socio);
      if (sucesso > 0) {
        final index = _socios.indexWhere((s) => s.id == socio.id);
        if (index != -1) {
          _socios[index] = socio;
          notifyListeners();
        }
        return true;
      }

      throw Exception('Erro ao atualizar sócio');
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<bool> deletarSocio(int id) async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      final sucesso = await _socioDao.deletar(id);
      if (sucesso > 0) {
        _socios.removeWhere((socio) => socio.id == id);
        notifyListeners();
        return true;
      }

      throw Exception('Erro ao deletar sócio');
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<bool> deletarSocioPermanente(int id) async {
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      final sucesso = await _socioDao.deletarPermanente(id);
      if (sucesso > 0) {
        _socios.removeWhere((socio) => socio.id == id);
        notifyListeners();
        return true;
      }

      throw Exception('Erro ao deletar sócio permanentemente');
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<Socio?> buscarSocioPorId(int id) async {
    try {
      return await _socioDao.buscarPorId(id);
    } catch (e) {
      _erro = 'Erro ao buscar sócio: $e';
      notifyListeners();
      return null;
    }
  }

  Future<List<Socio>> buscarSociosPorNome(String nome) async {
    try {
      if (nome.trim().isEmpty) {
        return _socios;
      }
      return await _socioDao.buscarPorNome(nome.trim());
    } catch (e) {
      _erro = 'Erro ao buscar sócios por nome: $e';
      notifyListeners();
      return [];
    }
  }

  Future<List<Socio>> buscarSociosPorStatus(String status) async {
    try {
      return await _socioDao.buscarPorStatus(status);
    } catch (e) {
      _erro = 'Erro ao buscar sócios por status: $e';
      notifyListeners();
      return [];
    }
  }

  Future<int> contarSocios() async {
    try {
      return await _socioDao.contarSocios();
    } catch (e) {
      _erro = 'Erro ao contar sócios: $e';
      notifyListeners();
      return 0;
    }
  }

  bool validarCPF(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cpf.length != 11) return false;
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) return false;

    int soma = 0;
    for (int i = 0; i < 9; i++) {
      soma += int.parse(cpf[i]) * (10 - i);
    }
    int digito1 = 11 - (soma % 11);
    if (digito1 >= 10) digito1 = 0;

    soma = 0;
    for (int i = 0; i < 10; i++) {
      soma += int.parse(cpf[i]) * (11 - i);
    }
    int digito2 = 11 - (soma % 11);
    if (digito2 >= 10) digito2 = 0;

    return cpf[9] == digito1.toString() && cpf[10] == digito2.toString();
  }

  void limparErro() {
    _erro = null;
    notifyListeners();
  }
}
