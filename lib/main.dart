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
  List<PokemonListing> _loadedMon = [];
  List<PokemonListing> _filteredMon = [];
  final _biggerFont = const TextStyle(fontSize: 18);
  String _filter = "";
  final TextEditingController _textController = TextEditingController();

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
          .map<PokemonListing>((mon) =>
              PokemonListing(capitalize(mon['name'].toString()), mon['url']))
          .toList();
      setState(() {
        _loadedMon = pokeList;
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
        body: Column(children: [
          TextField(
            controller: _textController,
            decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'Enter a search term',
                suffixIcon: IconButton(
                    onPressed: () {
                      _textController.clear();
                      setState(() {
                        _filter = "";
                      });
                    },
                    icon: const Icon(Icons.clear, color: Colors.red))),
            onChanged: (String value) {
              setState(() {
                _filter = value;
              });
            },
          ),
          Expanded(
              child: ListView.builder(
            itemCount: _filteredMon.length,
            padding: const EdgeInsets.all(16.0),
            itemBuilder: (context, i) {
              return Column(children: [
                ListTile(
                  title: Text(
                    _filteredMon[i].name,
                    style: _biggerFont,
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => PokemonEntry(
                          name: _filteredMon[i].name, url: _filteredMon[i].url),
                    ));
                  },
                ),
                const Divider(),
              ]);
            },
          ))
        ]));
  }

  @override
  void setState(VoidCallback fn) {
    fn();

    if (_filter.isEmpty) {
      _filteredMon = _loadedMon;
    } else {
      _filteredMon = _loadedMon
          .where((f) => f.name.toLowerCase().contains(_filter.toLowerCase()))
          .toList();
    }

    super.setState(() {});
  }
}

String capitalize(String text) {
  return text.substring(0, 1).toUpperCase() + text.substring(1);
}
