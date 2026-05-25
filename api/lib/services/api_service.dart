import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class ApiService {
  // 1. Busca um Pokémon específico pelo Nome ou ID (O código da imagem corrigido)
  static Future<Pokemon> buscarPokemon(String query) async {
    // Remove espaços e converte para letras minúsculas antes de enviar
    final busca = query.trim().toLowerCase(); 
    final url = Uri.parse('https://pokeapi.co/api/v2/pokemon/$busca');
    
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final dados = jsonDecode(response.body);
        return Pokemon.fromJson(dados);
      } else if (response.statusCode == 404) {
        throw PokemonNotFoundException();
      } else {
        throw Exception('Erro ao buscar Pokémon: ${response.statusCode}');
      }
    } on SocketException catch (_) {
      throw NetworkException();
    }
  }

  // 2. Busca a lista com os 20 primeiros Pokémon para a Home
  static Future<List<Pokemon>> buscarListaInicial() async {
    final url = Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=20');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final dados = jsonDecode(response.body);
        final List resultados = dados['results'];
        
        List<Pokemon> listaPokemons = [];
        
        // Como o endpoint de lista retorna apenas nome e uma URL de detalhes,
        // extraímos o ID direto da URL para montar o objeto de forma eficiente
        for (var item in resultados) {
          String urlDetalhes = item['url'];
          List<String> partes = urlDetalhes.split('/');
          int id = int.parse(partes[partes.length - 2]);
          
          listaPokemons.add(Pokemon(
            id: id,
            nome: item['name'],
            urlImagem: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png',
          ));
        }
        return listaPokemons;
      } else {
        throw Exception('Erro ao carregar a lista: ${response.statusCode}');
      }
    } on SocketException catch (_) {
      throw NetworkException();
    }
  }

}

// Exceções customizadas para tratar erros de forma clara na UI
class PokemonNotFoundException implements Exception {}
class NetworkException implements Exception {}