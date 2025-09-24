import 'package:desafio/comum/entity/entidade_base.dart';

class Contrato extends EntidadeBase {
  String? titulo;
  String? nomeEmpresa;
  String? status;
  String? descricao;
  String? dataGeracao;
  String? link;
  int? usuarioId;

  Contrato({
    super.id,
    super.criadoEm,
    super.atualizadoEm,
    super.excluidoEm,
    this.titulo,
    this.nomeEmpresa,
    this.status,
    this.descricao,
    this.dataGeracao,
    this.link,
    this.usuarioId,
  });

  factory Contrato.fromMap(Map<String, dynamic> map) {
    return Contrato(
      id: map['id'],
      titulo: map['nome'],
      nomeEmpresa: map['nomeEmpresa'],
      status: map['status'],
      descricao: map['descricao'],
      dataGeracao: map['dataGeracao'],
      link: map['caminho'],
      usuarioId: map['usuario_id'],
      criadoEm:
          map['criadoEm'] != null ? DateTime.parse(map['criadoEm']) : null,
      atualizadoEm:
          map['atualizadoEm'] != null
              ? DateTime.parse(map['atualizadoEm'])
              : null,
      excluidoEm:
          map['excluidoEm'] != null ? DateTime.parse(map['excluidoEm']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': titulo,
      'descricao': descricao,
      'status': status,
      'caminho': link,
      'usuario_id': usuarioId,
      'criadoEm': criadoEm?.toIso8601String(),
      'atualizadoEm': atualizadoEm?.toIso8601String(),
      'excluidoEm': excluidoEm?.toIso8601String(),
    };
  }

  factory Contrato.fromJson(Map<String, dynamic> json) {
    return Contrato(
      id: json['id'],
      titulo: json['titulo'],
      nomeEmpresa: json['nomeEmpresa'],
      status: json['status'],
      descricao: json['descricao'],
      dataGeracao: json['dataGeracao'],
      link: json['link'],
      usuarioId: json['usuarioId'],
      criadoEm:
          json['criadoEm'] != null ? DateTime.parse(json['criadoEm']) : null,
      atualizadoEm:
          json['atualizadoEm'] != null
              ? DateTime.parse(json['atualizadoEm'])
              : null,
      excluidoEm:
          json['excluidoEm'] != null
              ? DateTime.parse(json['excluidoEm'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'nomeEmpresa': nomeEmpresa,
      'status': status,
      'descricao': descricao,
      'dataGeracao': dataGeracao,
      'link': link,
      'usuarioId': usuarioId,
      'criadoEm': criadoEm?.toIso8601String(),
      'atualizadoEm': atualizadoEm?.toIso8601String(),
      'excluidoEm': excluidoEm?.toIso8601String(),
    };
  }
}
