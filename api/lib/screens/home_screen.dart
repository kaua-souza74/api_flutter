import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // Guardamos o Future que a tela vai observar
  Future<List<Pokemon>>? _futurePokemons;

  @override
  void initState() {
    super.initState();
    // Ao abrir o app, carrega automaticamente os 20 primeiros [cite: 101]
    _carregarListaInicial();
    // Se o usuário limpar o campo de busca, volta para a lista inicial automaticamente
    _searchController.addListener(() {
      if (_searchController.text.isEmpty) {
        _carregarListaInicial();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _carregarListaInicial() {
    setState(() {
      _futurePokemons = ApiService.buscarListaInicial();
    });
  }

  void _buscar() {
    final textoBusca = _searchController.text;
    
    // Se o campo estiver vazio, volta a exibir a lista padrão [cite: 107]
    if (textoBusca.isEmpty) {
      _carregarListaInicial();
      return;
    }

    // Se houver texto, atualiza para exibir o Pokémon pesquisado [cite: 108]
    setState(() {
      _futurePokemons = ApiService.buscarPokemon(textoBusca).then((pokemon) => [pokemon]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'POKÉDEX',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        elevation: 8,
        shadowColor: Colors.black54,
      ),
      body: Column(
        children: [
          // Campo de busca e botão [cite: 105, 106]
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Buscar Pokémon',
                      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFFDC0A15)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFDC0A15), width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFDC0A15), width: 2.5),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _buscar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC0A15),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: const Icon(Icons.search, size: 24),
                ),
              ],
            ),
          ),
          
          // FutureBuilder para desenhar os dados [cite: 78, 79]
          Expanded(
            child: FutureBuilder<List<Pokemon>>(
              future: _futurePokemons,
              builder: (context, snapshot) {
                // Indicador de carregamento enquanto aguarda a API [cite: 74, 110]
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDC0A15)),
                          strokeWidth: 4,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Carregando Pokémons...',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Exibe mensagem de erro amigável
                if (snapshot.hasError) {
                  final error = snapshot.error;
                  String message = 'Erro ao carregar dados.';
                  IconData icon = Icons.error_outline;
                  if (error is PokemonNotFoundException) {
                    message = 'Pokémon não encontrado!\nVerifique o nome ou ID.';
                    icon = Icons.search_off;
                  } else if (error is NetworkException) {
                    message = 'Sem conexão!\nVerifique sua Internet e tente novamente.';
                    icon = Icons.wifi_off;
                  } else if (error is Exception) {
                    message = error.toString();
                  }

                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          size: 64,
                          color: const Color(0xFFDC0A15).withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFDC0A15),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nenhum Pokémon na lista.'));
                }

                final lista = snapshot.data!;

                // Componente de rolagem eficiente para exibir a lista [cite: 102]
                return ListView.builder(
                  itemCount: lista.length,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  itemBuilder: (context, index) {
                    final pokemon = lista[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white,
                            Colors.grey[50]!,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0xFFDC0A15).withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        // Exibe a imagem vinda da internet dinamicamente [cite: 74, 113, 114]
                        leading: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Image.network(
                            pokemon.urlImagem,
                            width: 60,
                            height: 60,
                            fit: BoxFit.contain,
                          ),
                        ),
                        // Exibe o Nome e o ID do Pokémon [cite: 74, 103]
                        title: Text(
                          pokemon.nome.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 0.5,
                            color: Color(0xFFDC0A15),
                          ),
                        ),
                        subtitle: Text(
                          '#${pokemon.id.toString().padLeft(3, '0')}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: const Color(0xFFDC0A15).withValues(alpha: 0.6),
                          size: 28,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}