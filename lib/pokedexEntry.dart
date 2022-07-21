import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:startup_namer/evolutionChart.dart';

class Pokemon {
  final String name;
  final List<String> types;
  final String? imageUrl;
  final String speciesUrl;
  List<EvolutionLink> evolutionChain;

  Pokemon(
    this.name,
    this.types,
    this.imageUrl,
    this.speciesUrl, [
    this.evolutionChain = const [],
  ]);
}

class EvolutionLink {
  final String name;
  final int id;
  final List<EvolutionLink> evolvesInto;

  EvolutionLink(this.name, this.id, [this.evolvesInto = const []]);
}

class PokemonEntry extends StatefulWidget {
  const PokemonEntry({super.key, required this.name, required this.url});

  final String name;
  // url to query API
  final String url;

  @override
  State<PokemonEntry> createState() => _PokemonState();
}

class _PokemonState extends State<PokemonEntry> {
  final _biggerFont = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
  late Pokemon _pokemon = Pokemon(widget.name, [], null, '');
  int evolutionDepth = 0;

  @override
  void initState() {
    super.initState();
    fetchPokemon();
  }

  EvolutionLink buildChain(dynamic evolution, int depth) {
    if (depth > evolutionDepth) {
      evolutionDepth = depth;
    }
    List<EvolutionLink> evolvesTo = evolution['evolves_to'].length != 0
        ? evolution['evolves_to']
            .map<EvolutionLink>((evo) => buildChain(evo, depth + 1))
            .toList()
        : [];
    return EvolutionLink(evolution['species']['name'],
        getIdFromUrl(evolution['species']['url']), evolvesTo);
  }

  void fetchPokemon() async {
    var pokemon = _pokemon;

    http.Response pokemonResponse = await http.get(Uri.parse(widget.url));
    if (pokemonResponse.statusCode == 200) {
      final pokeInfo = json.decode(pokemonResponse.body);
      pokemon = Pokemon(
          widget.name,
          pokeInfo['types']
              .map<String>((type) => type['type']['name'] as String)
              .toList(),
          pokeInfo['sprites']['other']['official-artwork']['front_default'],
          pokeInfo['species']['url']);
    }

    http.Response speciesResponse =
        await http.get(Uri.parse(pokemon.speciesUrl));

    if (speciesResponse.statusCode == 200) {
      http.Response evolutionChainResponse = await http.get(Uri.parse(
          json.decode(speciesResponse.body)['evolution_chain']['url']));

      if (evolutionChainResponse.statusCode == 200) {
        final evolutionChain = json.decode(evolutionChainResponse.body);
        pokemon.evolutionChain = [buildChain(evolutionChain['chain'], 1)];
      }
    }

    setState(() {
      _pokemon = pokemon;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_pokemon.name),
          backgroundColor: Colors.red[600],
        ),
        body: Column(children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _pokemon.types.length,
            padding: const EdgeInsets.only(top: 10),
            itemBuilder: (context, i) {
              return Column(children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Type ${i + 1}: ${_pokemon.types[i]}",
                    style: _biggerFont,
                  ),
                )
              ]);
            },
            separatorBuilder: (context, index) => const SizedBox(
              height: 10,
            ),
          ),
          _pokemon.imageUrl != null
              ? Image.network(_pokemon.imageUrl!)
              : Container(),
          evolutionDepth > 1
              ? EvolutionChart(
                  depth: evolutionDepth, chain: _pokemon.evolutionChain)
              : Container(),
        ]));
  }
}

int getIdFromUrl(String url) {
  var sanitizedUrl = url.substring(0, url.length - 1);
  sanitizedUrl = sanitizedUrl.substring(sanitizedUrl.lastIndexOf('/') + 1);
  return int.parse(sanitizedUrl);
}
