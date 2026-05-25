class Pokemon {
  final int id;
  final String nome;
  final String urlImagem;

  Pokemon({
    required this.id,
    required this.nome,
    required this.urlImagem,
  });

  // Construtor factory: Transforma o Map (JSON) em Objeto Dart 
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final int id = json['id'];
    final sprite = json['sprites']?['front_default'];
    final imageUrl = sprite ?? 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';

    return Pokemon(
      id: id,
      nome: json['name'],
      urlImagem: imageUrl,
    );
  }
}