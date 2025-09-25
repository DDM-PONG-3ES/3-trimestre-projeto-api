class NomeEmpresa {
  final int id;
  final String razaoSocial;
  final String nomeFantasia;

  NomeEmpresa({
    required this.id,
    required this.razaoSocial,
    required this.nomeFantasia,
  });

  // Construtor para criar uma instância a partir de um Map (útil para JSON/Database)
  factory NomeEmpresa.fromMap(Map<String, dynamic> map) {
    return NomeEmpresa(
      id: map['id']?.toInt() ?? 0,
      razaoSocial: map['razaoSocial'] ?? '',
      nomeFantasia: map['nomeFantasia'] ?? '',
    );
  }

  // Construtor para criar uma instância a partir de JSON
  factory NomeEmpresa.fromJson(Map<String, dynamic> json) {
    return NomeEmpresa.fromMap(json);
  }

  // Converter a instância para Map (útil para JSON/Database)
  Map<String, dynamic> toMap() {
    return {'id': id, 'razaoSocial': razaoSocial, 'nomeFantasia': nomeFantasia};
  }

  // Converter a instância para JSON
  Map<String, dynamic> toJson() {
    return toMap();
  }

  // Método copyWith para criar uma nova instância com alguns campos alterados
  NomeEmpresa copyWith({int? id, String? razaoSocial, String? nomeFantasia}) {
    return NomeEmpresa(
      id: id ?? this.id,
      razaoSocial: razaoSocial ?? this.razaoSocial,
      nomeFantasia: nomeFantasia ?? this.nomeFantasia,
    );
  }

  // Override do método toString para facilitar debug
  @override
  String toString() {
    return 'NomeEmpresa(id: $id, razaoSocial: $razaoSocial, nomeFantasia: $nomeFantasia)';
  }

  // Override dos métodos de igualdade
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NomeEmpresa &&
        other.id == id &&
        other.razaoSocial == razaoSocial &&
        other.nomeFantasia == nomeFantasia;
  }

  @override
  int get hashCode {
    return id.hashCode ^ razaoSocial.hashCode ^ nomeFantasia.hashCode;
  }
}
