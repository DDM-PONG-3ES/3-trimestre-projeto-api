import 'package:desafio/comum/entity/entidade_base.dart';

class ClausulaGenerica extends EntidadeBase {
  String? nomeClausula;
  String? conteudo;
  int? recadoId;

  ClausulaGenerica({
    super.id,
    super.criadoEm,
    super.atualizadoEm,
    super.excluidoEm,
    this.nomeClausula,
    this.conteudo,
    this.recadoId,
  });

  factory ClausulaGenerica.fromMap(Map<String, dynamic> map) {
    return ClausulaGenerica(
      id: map['id'],
      nomeClausula: map['nomeClausula'],
      conteudo: map['conteudo'],
      recadoId: map['recado_id'],
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
      'nomeClausula': nomeClausula,
      'conteudo': conteudo,
      'recado_id': recadoId,
      'criadoEm': criadoEm?.toIso8601String(),
      'atualizadoEm': atualizadoEm?.toIso8601String(),
      'excluidoEm': excluidoEm?.toIso8601String(),
    };
  }

  factory ClausulaGenerica.fromJson(Map<String, dynamic> json) {
    return ClausulaGenerica(
      id: json['id'],
      nomeClausula: json['nomeClausula'],
      conteudo: json['conteudo'],
      recadoId: json['recado_id'],
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
      'nomeClausula': nomeClausula,
      'conteudo': conteudo,
      'recado_id': recadoId,
      'criadoEm': criadoEm?.toIso8601String(),
      'atualizadoEm': atualizadoEm?.toIso8601String(),
      'excluidoEm': excluidoEm?.toIso8601String(),
    };
  }
}
