import 'package:desafio/comum/entity/entidade_base.dart';

class Clausula extends EntidadeBase {
  String? texto;
  String? tipo;
  String? status;
  int? contratoId;

  Clausula({
    super.id,
    super.criadoEm,
    super.atualizadoEm,
    super.excluidoEm,
    this.texto,
    this.tipo,
    this.status,
    this.contratoId,
  });

  factory Clausula.fromMap(Map<String, dynamic> map) {
    return Clausula(
      id: map['id'],
      texto: map['texto'],
      tipo: map['tipo'],
      status: map['status'],
      contratoId: map['contrato_id'],
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
      'texto': texto,
      'tipo': tipo,
      'status': status,
      'contrato_id': contratoId,
      'criadoEm': criadoEm?.toIso8601String(),
      'atualizadoEm': atualizadoEm?.toIso8601String(),
      'excluidoEm': excluidoEm?.toIso8601String(),
    };
  }

  factory Clausula.fromJson(Map<String, dynamic> json) {
    return Clausula(
      id: json['id'],
      texto: json['texto'],
      tipo: json['tipo'],
      status: json['status'],
      contratoId: json['contratoId'],
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
      'texto': texto,
      'tipo': tipo,
      'status': status,
      'contratoId': contratoId,
      'criadoEm': criadoEm?.toIso8601String(),
      'atualizadoEm': atualizadoEm?.toIso8601String(),
      'excluidoEm': excluidoEm?.toIso8601String(),
    };
  }
}
