import 'package:desafio/comum/entity/entidade_base.dart';

class Administracao extends EntidadeBase {
  String? nomeAdministrador;
  String? poderesAdministrativos;
  int? clausulaId;

  Administracao({
    super.id,
    super.criadoEm,
    super.atualizadoEm,
    super.excluidoEm,
    this.nomeAdministrador,
    this.poderesAdministrativos,
    this.clausulaId,
  });

  factory Administracao.fromMap(Map<String, dynamic> map) {
    return Administracao(
      id: map['id'],
      nomeAdministrador: map['nomeAdministrador'],
      poderesAdministrativos: map['poderesAdministrativos'],
      clausulaId: map['clausula_id'],
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
      'nomeAdministrador': nomeAdministrador,
      'poderesAdministrativos': poderesAdministrativos,
      'clausula_id': clausulaId,
      'criadoEm': criadoEm?.toIso8601String(),
      'atualizadoEm': atualizadoEm?.toIso8601String(),
      'excluidoEm': excluidoEm?.toIso8601String(),
    };
  }

  factory Administracao.fromJson(Map<String, dynamic> json) {
    return Administracao(
      id: json['id'],
      nomeAdministrador: json['nomeAdministrador'],
      poderesAdministrativos: json['poderesAdministrativos'],
      clausulaId: json['clausulaId'],
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
      'nomeAdministrador': nomeAdministrador,
      'poderesAdministrativos': poderesAdministrativos,
      'clausulaId': clausulaId,
      'criadoEm': criadoEm?.toIso8601String(),
      'atualizadoEm': atualizadoEm?.toIso8601String(),
      'excluidoEm': excluidoEm?.toIso8601String(),
    };
  }
}