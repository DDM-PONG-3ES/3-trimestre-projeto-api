import 'package:desafio/comum/entity/entidade_base.dart';

class Sede extends EntidadeBase {
  String? enderecoCompleto;
  int? clausulaId;

  Sede({
    super.id,
    super.criadoEm,
    super.atualizadoEm,
    super.excluidoEm,
    this.enderecoCompleto,
    this.clausulaId,
  });

  factory Sede.fromMap(Map<String, dynamic> map) {
    return Sede(
      id: map['id'],
      enderecoCompleto: map['enderecoCompleto'],
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
      'enderecoCompleto': enderecoCompleto,
      'clausula_id': clausulaId,
      'criadoEm': criadoEm?.toIso8601String(),
      'atualizadoEm': atualizadoEm?.toIso8601String(),
      'excluidoEm': excluidoEm?.toIso8601String(),
    };
  }

  factory Sede.fromJson(Map<String, dynamic> json) {
    return Sede(
      id: json['id'],
      enderecoCompleto: json['enderecoCompleto'],
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
      'enderecoCompleto': enderecoCompleto,
      'clausulaId': clausulaId,
      'criadoEm': criadoEm?.toIso8601String(),
      'atualizadoEm': atualizadoEm?.toIso8601String(),
      'excluidoEm': excluidoEm?.toIso8601String(),
    };
  }
}
