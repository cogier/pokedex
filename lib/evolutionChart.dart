import 'package:flutter/material.dart';
import 'package:startup_namer/pokedexEntry.dart';

import 'main.dart';

class EvolutionChart extends StatelessWidget {
  const EvolutionChart({super.key, required this.depth, required this.chain});

  final int depth;
  final List<EvolutionLink> chain;

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: chainToColumns());
  }

  List<Widget> chainToColumns() {
    List<Widget> columns = [];
    columns.add(Column(children: [getEvoMon(chain[0].name, chain[0].id)]));
    columns.add(Column(children: const [
      Icon(
        Icons.arrow_forward,
        color: Colors.black,
        size: 24.0,
      )
    ]));
    columns.add(Column(
        children: chain[0]
            .evolvesInto
            .map<Widget>((mon) => getEvoMon(mon.name, mon.id))
            .toList()));
    if (depth == 3) {
      columns.add(Column(children: const [
        Icon(
          Icons.arrow_forward,
          color: Colors.black,
          size: 24.0,
        )
      ]));
      List<Widget> thirdColumn = [];
      for (var midEvo in chain[0].evolvesInto) {
        for (var thirdEvo in midEvo.evolvesInto) {
          thirdColumn.add(getEvoMon(thirdEvo.name, thirdEvo.id));
        }
      }
      columns.add(Column(children: thirdColumn));
    }
    return columns;
  }
}

Widget getEvoMon(String name, int id) {
  return Column(children: [
    Image.network(
        "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png",
        scale: 10),
    Text(capitalize(name))
  ]);
}
