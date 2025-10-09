class ObjetoSocial {
  int? id;
  String atividadesEconomicas;
  String atividadesExercidas;
  DateTime? criadoEm;
  DateTime? atualizadoEm;
  DateTime? excluidoEm;

  ObjetoSocial({
    this.id,
    required this.atividadesEconomicas,
    required this.atividadesExercidas,
    this.criadoEm,
    this.atualizadoEm,
    this.excluidoEm,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'atividadesEconomicas': atividadesEconomicas,
      'atividadesExercidas': atividadesExercidas,
      'criadoEm': criadoEm?.toIso8601String(),
      'atualizadoEm': atualizadoEm?.toIso8601String(),
      'excluidoEm': excluidoEm?.toIso8601String(),
    };
  }

  factory ObjetoSocial.fromMap(Map<String, dynamic> map) {
    return ObjetoSocial(
      id: map['id'],
      atividadesEconomicas: map['atividadesEconomicas'] ?? '',
      atividadesExercidas: map['atividadesExercidas'] ?? '',
      criadoEm: map['criadoEm'] != null ? DateTime.parse(map['criadoEm']) : null,
      atualizadoEm: map['atualizadoEm'] != null ? DateTime.parse(map['atualizadoEm']) : null,
      excluidoEm: map['excluidoEm'] != null ? DateTime.parse(map['excluidoEm']) : null,
    );
  }

  ObjetoSocial copyWith({
    int? id,
    String? atividadesEconomicas,
    String? atividadesExercidas,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    DateTime? excluidoEm,
  }) {
    return ObjetoSocial(
      id: id ?? this.id,
      atividadesEconomicas: atividadesEconomicas ?? this.atividadesEconomicas,
      atividadesExercidas: atividadesExercidas ?? this.atividadesExercidas,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      excluidoEm: excluidoEm ?? this.excluidoEm,
    );
  }
}
