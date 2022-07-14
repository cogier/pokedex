import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Pokemon {
  final String name;
  final List<String> types;
  final String? imageUrl;

  Pokemon(this.name, this.types, this.imageUrl);
}

class PokemonEntry extends StatefulWidget {
  const PokemonEntry({super.key, required this.url});

  // url to query API
  final String url;

  @override
  State<PokemonEntry> createState() => _PokemonState();
}

class _PokemonState extends State<PokemonEntry> {
  final _biggerFont = const TextStyle(fontSize: 18);
  late Pokemon _pokemon = Pokemon('loading...', ['loading'], null);

  @override
  void initState() {
    super.initState();
    fetchPokemon();
  }

  void fetchPokemon() async {
    http.Response response = await http.get(Uri.parse(widget.url));
    if (response.statusCode == 200) {
      final pokeInfo = json.decode(response.body);
      setState(() {
        _pokemon = Pokemon(
            pokeInfo['name'],
            pokeInfo['types']
                .map<String>((type) => type['type']['name'] as String)
                .toList(),
            pokeInfo['sprites']['other']['official-artwork']['front_default']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_pokemon.name),
          backgroundColor: Colors.red[600],
        ),
        body: Column(children: [
          Expanded(
            child: ListView.builder(
                itemCount: _pokemon.types.length,
                itemBuilder: (context, i) {
                  return Column(children: [
                    Text(
                      "Type ${i + 1}: ${_pokemon.types[i]}",
                      style: _biggerFont,
                    ),
                  ]);
                }),
          ),
          _pokemon.imageUrl != null
              ? Image.network(_pokemon.imageUrl!)
              : Container()
        ]));
  }
}
