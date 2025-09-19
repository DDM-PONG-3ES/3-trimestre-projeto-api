import 'package:desafio/comum/entity/entidade_base.dart';

class Usuario extends EntidadeBase {
  static const int tamanhoMaximoBio = 500;

  String? nome;
  String? email;
  String? senha;

  Usuario({
    super.id,
    super.criadoEm,
    super.atualizadoEm,
    super.excluidoEm,
    this.nome,
    this.email,
    this.senha,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nome: json['name'],
      email: json['email'],
      criadoEm:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      atualizadoEm:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': nome,
      'email': email,
      'createdAt': criadoEm?.toIso8601String(),
      'updatedAt': atualizadoEm?.toIso8601String(),
    };
  }
}
