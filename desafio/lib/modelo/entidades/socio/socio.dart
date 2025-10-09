class Socio {
  int? id;
  String nome;
  String statusSocial;
  String dataNascimento;
  String cpf;
  String residencia;
  DateTime? criadoEm;
  DateTime? atualizadoEm;
  DateTime? excluidoEm;

  Socio({
    this.id,
    required this.nome,
    required this.statusSocial,
    required this.dataNascimento,
    required this.cpf,
    required this.residencia,
    this.criadoEm,
    this.atualizadoEm,
    this.excluidoEm,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'statusSocial': statusSocial,
      'dataNascimento': dataNascimento,
      'cpf': cpf,
      'residencia': residencia,
      'criadoEm': criadoEm?.toIso8601String(),
      'atualizadoEm': atualizadoEm?.toIso8601String(),
      'excluidoEm': excluidoEm?.toIso8601String(),
    };
  }

  factory Socio.fromMap(Map<String, dynamic> map) {
    return Socio(
      id: map['id'],
      nome: map['nome'] ?? '',
      statusSocial: map['statusSocial'] ?? '',
      dataNascimento: map['dataNascimento'] ?? '',
      cpf: map['cpf'] ?? '',
      residencia: map['residencia'] ?? '',
      criadoEm: map['criadoEm'] != null ? DateTime.parse(map['criadoEm']) : null,
      atualizadoEm: map['atualizadoEm'] != null ? DateTime.parse(map['atualizadoEm']) : null,
      excluidoEm: map['excluidoEm'] != null ? DateTime.parse(map['excluidoEm']) : null,
    );
  }

  Socio copyWith({
    int? id,
    String? nome,
    String? statusSocial,
    String? dataNascimento,
    String? cpf,
    String? residencia,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    DateTime? excluidoEm,
  }) {
    return Socio(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      statusSocial: statusSocial ?? this.statusSocial,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      cpf: cpf ?? this.cpf,
      residencia: residencia ?? this.residencia,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      excluidoEm: excluidoEm ?? this.excluidoEm,
    );
  }
}
