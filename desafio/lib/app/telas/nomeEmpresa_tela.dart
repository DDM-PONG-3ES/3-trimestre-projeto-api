import 'package:desafio/modelo/entidades/nomeEmpresa/nomeEmpresa.dart';
import 'package:desafio/servicos/nomeEmpresa_servico.dart';
import 'package:flutter/material.dart';
import 'dart:async';
// Importe suas classes aqui
// import 'nome_empresa.dart';
// import 'nome_empresa_service.dart';

class NomeEmpresaScreen extends StatefulWidget {
  const NomeEmpresaScreen({Key? key}) : super(key: key);

  @override
  State<NomeEmpresaScreen> createState() => _NomeEmpresaScreenState();
}

class _NomeEmpresaScreenState extends State<NomeEmpresaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _razaoSocialController = TextEditingController();
  final _nomeFantasiaController = TextEditingController();
  final _service = NomeEmpresaService();

  List<NomeEmpresa> _empresas = [];
  bool _isLoading = false;
  bool _isSaving = false;
  StreamSubscription<List<NomeEmpresa>>? _empresasSubscription;

  @override
  void initState() {
    super.initState();
    _setupEmpresasListener();
    _loadEmpresas();
  }

  @override
  void dispose() {
    _razaoSocialController.dispose();
    _nomeFantasiaController.dispose();
    _empresasSubscription?.cancel();
    super.dispose();
  }

  // Configurar listener para mudanças automáticas na lista
  void _setupEmpresasListener() {
    _empresasSubscription = _service.empresasStream.listen(
      (empresas) {
        if (mounted) {
          setState(() {
            _empresas = empresas;
            _isLoading = false;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          _showErrorSnackBar('Erro ao atualizar lista: $error');
          setState(() {
            _isLoading = false;
          });
        }
      },
    );
  }

  // Carregar todas as empresas
  Future<void> _loadEmpresas() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final empresas = await _service.listarTodasEmpresas();
      if (mounted) {
        setState(() {
          _empresas = empresas;
        });
      }
    } on EmpresaException catch (e) {
      _showErrorSnackBar(e.message);
    } catch (e) {
      _showErrorSnackBar('Erro inesperado: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Salvar nova empresa usando a service
  Future<void> _saveEmpresa() async {
    if (!_formKey.currentState!.validate() || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final empresa = NomeEmpresa(
        id: 0, // Será gerado automaticamente
        razaoSocial: _razaoSocialController.text.trim(),
        nomeFantasia: _nomeFantasiaController.text.trim(),
      );

      await _service.salvarEmpresa(empresa);

      // Limpar os campos após sucesso
      _razaoSocialController.clear();
      _nomeFantasiaController.clear();

      _showSuccessSnackBar('Empresa salva com sucesso!');

      // Remover foco dos campos
      FocusScope.of(context).unfocus();
    } on EmpresaException catch (e) {
      _showErrorSnackBar(e.message);
    } catch (e) {
      _showErrorSnackBar('Erro inesperado: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // Deletar empresa usando a service
  Future<void> _deleteEmpresa(NomeEmpresa empresa) async {
    final confirmed = await _showDeleteConfirmation(empresa);
    if (!confirmed) return;

    try {
      await _service.deletarEmpresa(empresa.id);
      _showSuccessSnackBar('Empresa deletada com sucesso!');
    } on EmpresaException catch (e) {
      _showErrorSnackBar(e.message);
    } catch (e) {
      _showErrorSnackBar('Erro inesperado: $e');
    }
  }

  // Buscar empresas por nome fantasia
  Future<void> _searchByNomeFantasia(String query) async {
    if (query.trim().isEmpty) {
      await _loadEmpresas();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final empresas = await _service.buscarPorNomeFantasia(query.trim());
      if (mounted) {
        setState(() {
          _empresas = empresas;
        });
      }
    } on EmpresaException catch (e) {
      _showErrorSnackBar(e.message);
    } catch (e) {
      _showErrorSnackBar('Erro na busca: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Mostrar informações detalhadas da empresa
  void _showEmpresaDetails(NomeEmpresa empresa) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(empresa.nomeFantasia),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('ID:', empresa.id.toString()),
                const SizedBox(height: 8),
                _buildDetailRow('Razão Social:', empresa.razaoSocial),
                const SizedBox(height: 8),
                _buildDetailRow('Nome Fantasia:', empresa.nomeFantasia),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fechar'),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }

  // Mostrar diálogo de confirmação para deletar
  Future<bool> _showDeleteConfirmation(NomeEmpresa empresa) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Confirmar Exclusão'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Deseja realmente deletar a empresa:'),
                    const SizedBox(height: 8),
                    Text(
                      '"${empresa.nomeFantasia}"',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      empresa.razaoSocial,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Deletar'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  // Mostrar SnackBar de sucesso
  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Mostrar SnackBar de erro
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Empresas'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadEmpresas,
            icon:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Icon(Icons.refresh),
            tooltip: 'Recarregar lista',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              switch (value) {
                case 'count':
                  try {
                    final count = await _service.contarEmpresas();
                    _showSuccessSnackBar('Total de empresas: $count');
                  } catch (e) {
                    _showErrorSnackBar('Erro ao contar: $e');
                  }
                  break;
                case 'clear_cache':
                  _service.limparCache();
                  _showSuccessSnackBar('Cache limpo com sucesso');
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'count',
                    child: Row(
                      children: [
                        Icon(Icons.analytics),
                        SizedBox(width: 8),
                        Text('Contar empresas'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'clear_cache',
                    child: Row(
                      children: [
                        Icon(Icons.clear_all),
                        SizedBox(width: 8),
                        Text('Limpar cache'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Formulário para adicionar nova empresa
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cadastrar Nova Empresa',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _razaoSocialController,
                    decoration: const InputDecoration(
                      labelText: 'Razão Social',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business),
                      helperText: 'Entre 3 e 200 caracteres',
                    ),
                    maxLength: 200,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Razão Social é obrigatória';
                      }
                      if (value.trim().length < 3) {
                        return 'Razão Social deve ter pelo menos 3 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nomeFantasiaController,
                    decoration: const InputDecoration(
                      labelText: 'Nome Fantasia',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.store),
                      helperText: 'Entre 2 e 100 caracteres',
                    ),
                    maxLength: 100,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nome Fantasia é obrigatório';
                      }
                      if (value.trim().length < 2) {
                        return 'Nome Fantasia deve ter pelo menos 2 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveEmpresa,
                      icon:
                          _isSaving
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Icon(Icons.save),
                      label: Text(_isSaving ? 'Salvando...' : 'Salvar Empresa'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Barra de busca
          Container(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nome fantasia...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _loadEmpresas(),
                  tooltip: 'Limpar busca',
                ),
              ),
              onChanged: _searchByNomeFantasia,
            ),
          ),

          // Lista de empresas
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Empresas (${_empresas.length})',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child:
                        _isLoading
                            ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text('Carregando empresas...'),
                                ],
                              ),
                            )
                            : _empresas.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.business_outlined,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Nenhuma empresa encontrada',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Cadastre sua primeira empresa acima',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : ListView.builder(
                              itemCount: _empresas.length,
                              itemBuilder: (context, index) {
                                final empresa = _empresas[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8.0),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.blue.shade100,
                                      child: Text(
                                        empresa.nomeFantasia[0].toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      empresa.nomeFantasia,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          empresa.razaoSocial,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        Text(
                                          'ID: ${empresa.id}',
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed:
                                              () =>
                                                  _showEmpresaDetails(empresa),
                                          icon: const Icon(
                                            Icons.info_outline,
                                            color: Colors.blue,
                                          ),
                                          tooltip: 'Ver detalhes',
                                        ),
                                        IconButton(
                                          onPressed:
                                              () => _deleteEmpresa(empresa),
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                          ),
                                          tooltip: 'Deletar empresa',
                                        ),
                                      ],
                                    ),
                                    onTap: () => _showEmpresaDetails(empresa),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
