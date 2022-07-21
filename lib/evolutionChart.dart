import 'package:flutter/material.dart';
import 'package:startup_namer/pokedexEntry.dart';

import 'main.dart';

class EvolutionChart extends StatelessWidget {
  const EvolutionChart({super.key, required this.depth, required this.chain});

  final int depth;
  final List<EvolutionLink> chain;

  @override
  Widget build(BuildContext context) {
    return Center(child: Row(children: chainToColumns()));
  }

  List<Widget> chainToColumns() {
    List<Widget> columns = [];
    columns.add(Column(
        children: [getEvoRow(chain[0].name, chain[0].id, isFirst: true)]));
    columns.add(Column(
        children: chain[0]
            .evolvesInto
            .map<Widget>((mon) => getEvoRow(mon.name, mon.id))
            .toList()));
    if (depth == 3) {
      List<Widget> thirdColumn = [];
      for (var midEvo in chain[0].evolvesInto) {
        for (var thirdEvo in midEvo.evolvesInto) {
          thirdColumn.add(getEvoRow(thirdEvo.name, thirdEvo.id));
        }
      }
      columns.add(Column(children: thirdColumn));
    }
    return columns;
  }
}

Widget getEvoRow(String name, int id, {bool isFirst = false}) {
  List<Widget> row = isFirst
      ? []
      : [
          const Icon(
            Icons.arrow_forward,
            color: Colors.black,
            size: 24.0,
          )
        ];

  row.add(Column(children: [
    Image.network(
        "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png",
        scale: 10),
    Text(capitalize(name))
  ]));

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: row,
  );
}
