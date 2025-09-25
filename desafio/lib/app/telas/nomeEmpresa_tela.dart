import 'package:desafio/modelo/dao/nomeEmpresa_dao.dart';
import 'package:desafio/modelo/entidades/nomeEmpresa/nomeEmpresa.dart';
import 'package:flutter/material.dart';
// Importe suas classes aqui
// import 'nome_empresa.dart';
// import 'nomeEmpresa_dao.dart';

class NomeEmpresaScreen extends StatefulWidget {
  const NomeEmpresaScreen({Key? key}) : super(key: key);

  @override
  State<NomeEmpresaScreen> createState() => _NomeEmpresaScreenState();
}

class _NomeEmpresaScreenState extends State<NomeEmpresaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _razaoSocialController = TextEditingController();
  final _nomeFantasiaController = TextEditingController();
  final _dao = NomeEmpresaDao();

  List<NomeEmpresa> _empresas = [];
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadEmpresas();
  }

  @override
  void dispose() {
    _razaoSocialController.dispose();
    _nomeFantasiaController.dispose();
    super.dispose();
  }

  // Carregar todas as empresas salvas
  Future<void> _loadEmpresas() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final empresas = await _dao.findAll();
      setState(() {
        _empresas = empresas;
      });
    } catch (e) {
      _showErrorSnackBar('Erro ao carregar empresas: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Salvar nova empresa
  Future<void> _saveEmpresa() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final empresa = NomeEmpresa(
        id: 0, // Será gerado automaticamente pelo banco
        razaoSocial: _razaoSocialController.text.trim(),
        nomeFantasia: _nomeFantasiaController.text.trim(),
      );

      await _dao.insert(empresa);

      // Limpar os campos
      _razaoSocialController.clear();
      _nomeFantasiaController.clear();

      // Recarregar a lista
      await _loadEmpresas();

      _showSuccessSnackBar('Empresa salva com sucesso!');

      // Remover foco dos campos
      FocusScope.of(context).unfocus();
    } catch (e) {
      _showErrorSnackBar('Erro ao salvar empresa: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  // Deletar empresa
  Future<void> _deleteEmpresa(NomeEmpresa empresa) async {
    final confirmed = await _showDeleteConfirmation(empresa);
    if (!confirmed) return;

    try {
      await _dao.delete(empresa);
      await _loadEmpresas();
      _showSuccessSnackBar('Empresa deletada com sucesso!');
    } catch (e) {
      _showErrorSnackBar('Erro ao deletar empresa: $e');
    }
  }

  // Mostrar diálogo de confirmação para deletar
  Future<bool> _showDeleteConfirmation(NomeEmpresa empresa) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Confirmar Exclusão'),
                content: Text(
                  'Deseja realmente deletar a empresa "${empresa.nomeFantasia}"?',
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Mostrar SnackBar de erro
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Empresas'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 2,
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
                    ),
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
                    ),
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

          // Lista de empresas salvas
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Empresas Cadastradas (${_empresas.length})',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      IconButton(
                        onPressed: _isLoading ? null : _loadEmpresas,
                        icon:
                            _isLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.refresh),
                        tooltip: 'Atualizar lista',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child:
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
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
                                    'Nenhuma empresa cadastrada',
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
                                    subtitle: Text(
                                      empresa.razaoSocial,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      onPressed: () => _deleteEmpresa(empresa),
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      tooltip: 'Deletar empresa',
                                    ),
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
