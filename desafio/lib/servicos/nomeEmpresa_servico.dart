import 'dart:async';

import 'package:desafio/modelo/dao/nomeEmpresa_dao.dart';
import 'package:desafio/modelo/entidades/nomeEmpresa/nomeEmpresa.dart';
// Importe suas classes aqui
// import 'nome_empresa.dart';
// import 'nomeEmpresa_dao.dart';

class NomeEmpresaService {
  final NomeEmpresaDao _dao;

  // Singleton pattern
  static final NomeEmpresaService _instance = NomeEmpresaService._internal();
  factory NomeEmpresaService() => _instance;
  NomeEmpresaService._internal() : _dao = NomeEmpresaDao();

  // Stream controller para notificar mudanças na lista de empresas
  final StreamController<List<NomeEmpresa>> _empresasStreamController =
      StreamController<List<NomeEmpresa>>.broadcast();

  // Stream para escutar mudanças nas empresas
  Stream<List<NomeEmpresa>> get empresasStream =>
      _empresasStreamController.stream;

  // Cache das empresas para melhor performance
  List<NomeEmpresa> _cachedEmpresas = [];

  /// Salvar uma nova empresa
  /// Retorna o ID da empresa salva
  Future<int> salvarEmpresa(NomeEmpresa empresa) async {
    try {
      // Validações de negócio
      _validarEmpresa(empresa);

      // Verificar se já existe uma empresa com a mesma razão social
      final existeRazaoSocial = await _verificarRazaoSocialExistente(
        empresa.razaoSocial,
      );
      if (existeRazaoSocial) {
        throw EmpresaException('Já existe uma empresa com esta razão social');
      }

      // Verificar se já existe uma empresa com o mesmo nome fantasia
      final existeNomeFantasia = await _verificarNomeFantasiaExistente(
        empresa.nomeFantasia,
      );
      if (existeNomeFantasia) {
        throw EmpresaException('Já existe uma empresa com este nome fantasia');
      }

      // Salvar no banco
      final id = await _dao.insert(empresa);

      // Atualizar cache e notificar listeners
      await _atualizarCache();

      return id;
    } catch (e) {
      if (e is EmpresaException) {
        rethrow;
      }
      throw EmpresaException('Erro ao salvar empresa: ${e.toString()}');
    }
  }

  /// Atualizar uma empresa existente
  Future<void> atualizarEmpresa(NomeEmpresa empresa) async {
    try {
      // Validações de negócio
      _validarEmpresa(empresa);

      // Verificar se a empresa existe
      final empresaExistente = await _dao.findById(empresa.id);
      if (empresaExistente == null) {
        throw EmpresaException('Empresa não encontrada');
      }

      // Verificar se razão social não conflita com outras empresas
      if (empresaExistente.razaoSocial != empresa.razaoSocial) {
        final existeRazaoSocial = await _verificarRazaoSocialExistente(
          empresa.razaoSocial,
        );
        if (existeRazaoSocial) {
          throw EmpresaException('Já existe uma empresa com esta razão social');
        }
      }

      // Verificar se nome fantasia não conflita com outras empresas
      if (empresaExistente.nomeFantasia != empresa.nomeFantasia) {
        final existeNomeFantasia = await _verificarNomeFantasiaExistente(
          empresa.nomeFantasia,
        );
        if (existeNomeFantasia) {
          throw EmpresaException(
            'Já existe uma empresa com este nome fantasia',
          );
        }
      }

      // Atualizar no banco
      await _dao.update(empresa);

      // Atualizar cache e notificar listeners
      await _atualizarCache();
    } catch (e) {
      if (e is EmpresaException) {
        rethrow;
      }
      throw EmpresaException('Erro ao atualizar empresa: ${e.toString()}');
    }
  }

  /// Deletar uma empresa por ID
  Future<void> deletarEmpresa(int id) async {
    try {
      // Verificar se a empresa existe
      final empresa = await _dao.findById(id);
      if (empresa == null) {
        throw EmpresaException('Empresa não encontrada');
      }

      // Deletar do banco
      await _dao.deleteById(id);

      // Atualizar cache e notificar listeners
      await _atualizarCache();
    } catch (e) {
      if (e is EmpresaException) {
        rethrow;
      }
      throw EmpresaException('Erro ao deletar empresa: ${e.toString()}');
    }
  }

  /// Buscar empresa por ID
  Future<NomeEmpresa?> buscarEmpresaPorId(int id) async {
    try {
      return await _dao.findById(id);
    } catch (e) {
      throw EmpresaException('Erro ao buscar empresa: ${e.toString()}');
    }
  }

  /// Listar todas as empresas
  Future<List<NomeEmpresa>> listarTodasEmpresas() async {
    try {
      if (_cachedEmpresas.isEmpty) {
        await _atualizarCache();
      }
      return List.from(_cachedEmpresas);
    } catch (e) {
      throw EmpresaException('Erro ao listar empresas: ${e.toString()}');
    }
  }

  /// Buscar empresas por razão social
  Future<List<NomeEmpresa>> buscarPorRazaoSocial(String razaoSocial) async {
    try {
      if (razaoSocial.trim().isEmpty) {
        return [];
      }
      return await _dao.findByRazaoSocial(razaoSocial.trim());
    } catch (e) {
      throw EmpresaException(
        'Erro ao buscar por razão social: ${e.toString()}',
      );
    }
  }

  /// Buscar empresas por nome fantasia
  Future<List<NomeEmpresa>> buscarPorNomeFantasia(String nomeFantasia) async {
    try {
      if (nomeFantasia.trim().isEmpty) {
        return [];
      }
      return await _dao.findByNomeFantasia(nomeFantasia.trim());
    } catch (e) {
      throw EmpresaException(
        'Erro ao buscar por nome fantasia: ${e.toString()}',
      );
    }
  }

  /// Buscar empresas com paginação
  Future<List<NomeEmpresa>> buscarComPaginacao({
    int pagina = 1,
    int itensPorPagina = 10,
  }) async {
    try {
      if (pagina < 1) pagina = 1;
      if (itensPorPagina < 1) itensPorPagina = 10;

      final offset = (pagina - 1) * itensPorPagina;
      return await _dao.findWithPagination(
        limit: itensPorPagina,
        offset: offset,
      );
    } catch (e) {
      throw EmpresaException('Erro ao buscar com paginação: ${e.toString()}');
    }
  }

  /// Contar total de empresas
  Future<int> contarEmpresas() async {
    try {
      return await _dao.count();
    } catch (e) {
      throw EmpresaException('Erro ao contar empresas: ${e.toString()}');
    }
  }

  /// Verificar se uma empresa existe
  Future<bool> empresaExiste(int id) async {
    try {
      return await _dao.exists(id);
    } catch (e) {
      throw EmpresaException(
        'Erro ao verificar existência da empresa: ${e.toString()}',
      );
    }
  }

  /// Deletar todas as empresas (usar com cuidado!)
  Future<void> deletarTodasEmpresas() async {
    try {
      await _dao.deleteAll();
      await _atualizarCache();
    } catch (e) {
      throw EmpresaException(
        'Erro ao deletar todas as empresas: ${e.toString()}',
      );
    }
  }

  /// Importar lista de empresas (substitui todas existentes)
  Future<void> importarEmpresas(List<NomeEmpresa> empresas) async {
    try {
      // Validar todas as empresas antes de importar
      for (final empresa in empresas) {
        _validarEmpresa(empresa);
      }

      // Deletar todas as empresas existentes
      await _dao.deleteAll();

      // Inserir as novas empresas
      for (final empresa in empresas) {
        await _dao.insert(empresa);
      }

      // Atualizar cache e notificar listeners
      await _atualizarCache();
    } catch (e) {
      throw EmpresaException('Erro ao importar empresas: ${e.toString()}');
    }
  }

  /// Exportar todas as empresas
  Future<List<NomeEmpresa>> exportarEmpresas() async {
    try {
      return await listarTodasEmpresas();
    } catch (e) {
      throw EmpresaException('Erro ao exportar empresas: ${e.toString()}');
    }
  }

  // Métodos privados de validação e utilitários

  /// Validar dados da empresa
  void _validarEmpresa(NomeEmpresa empresa) {
    if (empresa.razaoSocial.trim().isEmpty) {
      throw EmpresaException('Razão social é obrigatória');
    }

    if (empresa.razaoSocial.trim().length < 3) {
      throw EmpresaException('Razão social deve ter pelo menos 3 caracteres');
    }

    if (empresa.razaoSocial.trim().length > 200) {
      throw EmpresaException(
        'Razão social não pode ter mais de 200 caracteres',
      );
    }

    if (empresa.nomeFantasia.trim().isEmpty) {
      throw EmpresaException('Nome fantasia é obrigatório');
    }

    if (empresa.nomeFantasia.trim().length < 2) {
      throw EmpresaException('Nome fantasia deve ter pelo menos 2 caracteres');
    }

    if (empresa.nomeFantasia.trim().length > 100) {
      throw EmpresaException(
        'Nome fantasia não pode ter mais de 100 caracteres',
      );
    }
  }

  /// Verificar se razão social já existe
  Future<bool> _verificarRazaoSocialExistente(String razaoSocial) async {
    final empresas = await _dao.findByRazaoSocial(razaoSocial.trim());
    return empresas.any(
      (e) => e.razaoSocial.toLowerCase() == razaoSocial.trim().toLowerCase(),
    );
  }

  /// Verificar se nome fantasia já existe
  Future<bool> _verificarNomeFantasiaExistente(String nomeFantasia) async {
    final empresas = await _dao.findByNomeFantasia(nomeFantasia.trim());
    return empresas.any(
      (e) => e.nomeFantasia.toLowerCase() == nomeFantasia.trim().toLowerCase(),
    );
  }

  /// Atualizar cache e notificar listeners
  Future<void> _atualizarCache() async {
    _cachedEmpresas = await _dao.findAll();
    _empresasStreamController.add(List.from(_cachedEmpresas));
  }

  /// Limpar cache
  void limparCache() {
    _cachedEmpresas.clear();
  }

  /// Fechar recursos
  void dispose() {
    _empresasStreamController.close();
  }
}

/// Exception personalizada para erros de negócio relacionados à empresa
class EmpresaException implements Exception {
  final String message;

  const EmpresaException(this.message);

  @override
  String toString() => 'EmpresaException: $message';
}
