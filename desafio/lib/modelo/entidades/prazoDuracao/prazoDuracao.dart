import 'package:desafio/comum/entity/entidade_base.dart';

class PrazoDuracao extends EntidadeBase {
  String? tipoPrazo;

  PrazoDuracao({
    super.id,
    super.criadoEm,
    super.atualizadoEm,
    super.excluidoEm,
    this.tipoPrazo,
  });

  factory PrazoDuracao.fromMap(Map<String, dynamic> map) {
    return PrazoDuracao(
      id: map['id'],
      tipoPrazo: map['tipoPrazo'],
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
      'tipoPrazo': tipoPrazo,
      'criadoEm': criadoEm?.toIso8601String(),
      'atualizadoEm': atualizadoEm?.toIso8601String(),
      'excluidoEm': excluidoEm?.toIso8601String(),
    };
  }

  factory PrazoDuracao.fromJson(Map<String, dynamic> json) {
    return PrazoDuracao(
      id: json['id'],
      tipoPrazo: json['tipoPrazo'],
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
      'tipoPrazo': tipoPrazo,
      'criadoEm': criadoEm?.toIso8601String(),
      'atualizadoEm': atualizadoEm?.toIso8601String(),
      'excluidoEm': excluidoEm?.toIso8601String(),
    };
  }
}
