import 'package:desafio/comum/entity/entidade_base.dart';

class Recado extends EntidadeBase {
  String? nome;
  String? erroIA;

  Recado({
    super.id,
    super.criadoEm,
    super.atualizadoEm,
    super.excluidoEm,
    this.nome,
    this.erroIA,
  });

  factory Recado.fromJson(Map<String, dynamic> json) {
    return Recado(
      id: json['id'],
      nome: json['nome'],
      erroIA: json['erroIA'],
      criadoEm: json['criadoEm'] != null
          ? DateTime.parse(json['criadoEm'])
          : null,
      atualizadoEm: json['atualizadoEm'] != null
          ? DateTime.parse(json['atualizadoEm'])
          : null,
      excluidoEm: json['excluidoEm'] != null
          ? DateTime.parse(json['excluidoEm'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'erroIA': erroIA,
      'criadoEm': criadoEm?.toIso8601String(),
      'atualizadoEm': atualizadoEm?.toIso8601String(),
      'excluidoEm': excluidoEm?.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'erroIA': erroIA,
      'criadoEm': criadoEm?.toIso8601String(),
      'atualizadoEm': atualizadoEm?.toIso8601String(),
      'excluidoEm': excluidoEm?.toIso8601String(),
    };
  }

  factory Recado.fromMap(Map<String, dynamic> map) {
    return Recado(
      id: map['id'],
      nome: map['nome'],
      erroIA: map['erroIA'],
      criadoEm: map['criadoEm'] != null
          ? DateTime.parse(map['criadoEm'])
          : null,
      atualizadoEm: map['atualizadoEm'] != null
          ? DateTime.parse(map['atualizadoEm'])
          : null,
      excluidoEm: map['excluidoEm'] != null
          ? DateTime.parse(map['excluidoEm'])
          : null,
    );
  }
}
