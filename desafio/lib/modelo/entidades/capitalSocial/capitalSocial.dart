import 'package:desafio/comum/entity/entidade_base.dart';

class CapitalSocial extends EntidadeBase {
  double? valorTotal;
  String? divisaoQuotas;
  String? formaIntegralizacao;
  int? clausulaId;

  CapitalSocial({
    super.id,
    super.criadoEm,
    super.atualizadoEm,
    super.excluidoEm,
    this.valorTotal,
    this.divisaoQuotas,
    this.formaIntegralizacao,
    this.clausulaId,
  });

  factory CapitalSocial.fromMap(Map<String, dynamic> map) {
    return CapitalSocial(
      id: map['id'],
      valorTotal:
          map['valorTotal'] != null
              ? (map['valorTotal'] as num).toDouble()
              : null,
      divisaoQuotas: map['divisaoQuotas'],
      formaIntegralizacao: map['formaIntegralizacao'],
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
      'valorTotal': valorTotal,
      'divisaoQuotas': divisaoQuotas,
      'formaIntegralizacao': formaIntegralizacao,
      'clausula_id': clausulaId,
      'criadoEm': criadoEm?.toIso8601String(),
      'atualizadoEm': atualizadoEm?.toIso8601String(),
      'excluidoEm': excluidoEm?.toIso8601String(),
    };
  }

  factory CapitalSocial.fromJson(Map<String, dynamic> json) {
    return CapitalSocial(
      id: json['id'],
      valorTotal:
          json['valorTotal'] != null
              ? (json['valorTotal'] as num).toDouble()
              : null,
      divisaoQuotas: json['divisaoQuotas'],
      formaIntegralizacao: json['formaIntegralizacao'],
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
      'valorTotal': valorTotal,
      'divisaoQuotas': divisaoQuotas,
      'formaIntegralizacao': formaIntegralizacao,
      'clausulaId': clausulaId,
      'criadoEm': criadoEm?.toIso8601String(),
      'atualizadoEm': atualizadoEm?.toIso8601String(),
      'excluidoEm': excluidoEm?.toIso8601String(),
    };
  }
}
