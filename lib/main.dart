// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'pokedexEntry.dart';

class PokemonListing {
  final String name;
  final String url;

  PokemonListing(this.name, this.url);
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Startup Name Generator',
      home: PokemonList(),
    );
  }
}

class PokemonList extends StatefulWidget {
  const PokemonList({super.key});

  @override
  State<PokemonList> createState() => _PokemonListState();
}

class _PokemonListState extends State<PokemonList> {
  final _biggerFont = const TextStyle(fontSize: 18);
  List<PokemonListing> _pokemon = [];

  @override
  void initState() {
    super.initState();
    fetchPokemonList();
  }

  void fetchPokemonList() async {
    http.Response response = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=100000&offset=0'));
    List<PokemonListing> pokeList;
    if (response.statusCode == 200) {
      pokeList = json
          .decode(response.body)['results']
          .map<PokemonListing>((mon) => PokemonListing(mon['name'], mon['url']))
          .toList();
      setState(() {
        _pokemon = pokeList;
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
      body: ListView.builder(
        itemCount: _pokemon.length,
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          if (i.isOdd || _pokemon.isEmpty) return const Divider();

          return ListTile(
            title: Text(
              _pokemon[i].name,
              style: _biggerFont,
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => PokemonEntry(url: _pokemon[i].url),
              ));
            },
          );
        },
      ),
    );
  }
}
