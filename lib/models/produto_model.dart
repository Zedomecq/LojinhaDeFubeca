class ProdutoModel {
  int? id;
  final String nome;
  final String descricao;
  final String categoria;
  final double valor;

  ProdutoModel({
    this.id,
    required this.nome,
    required this.descricao,
    required this.categoria,
    required this.valor,
  });

  factory ProdutoModel.fromJson(Map<String, dynamic> json) {
    return ProdutoModel(
      id: json['id'] as int?,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String,
      categoria: json['categoria'] as String,
      valor: (json['valor'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'categoria': categoria,
      'valor': valor,
    };
  }
}
