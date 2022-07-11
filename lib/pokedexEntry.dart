import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Pokemon {
  final String name;
  final List<String> types;

  Pokemon(this.name, this.types);
}

class PokemonEntry extends StatefulWidget {
  const PokemonEntry({super.key, required this.url});

  // url to query API
  final String url;

  @override
  State<PokemonEntry> createState() => _PokemonState(url);
}

class _PokemonState extends State<PokemonEntry> {
  final String url;
  _PokemonState(this.url);

  final _biggerFont = const TextStyle(fontSize: 18);
  late Pokemon _pokemon = Pokemon('name', ['type']);

  @override
  void initState() {
    super.initState();
    fetchPokemon();
  }

  void fetchPokemon() async {
    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final pokeInfo = json.decode(response.body);
      setState(() {
        _pokemon =
            Pokemon(pokeInfo['name'], [pokeInfo['types'][0]['type']['name']]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Pokemon List'),
          backgroundColor: Colors.red[600],
        ),
        body: ListTile(
          title: Text(
            _pokemon.name,
            style: _biggerFont,
          ),
        ));
  }
}
