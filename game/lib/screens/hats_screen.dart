import "package:flutter/material.dart";
import "package:flame/flame.dart";
import "package:flame/game.dart";

import "game/hats.dart";
import "game/player.dart";

import "../game_data.dart";

import "../ui/button.dart";
import "../ui/background.dart";
import "../ui/label.dart";
import "../ui/title_header.dart";

class Preview extends BaseGame {
  Preview(Size size, Hat hat) {

    this.size = size;

    final player = Player(this, hat: hat);
    player.y = size.height - 50;

    add(player);
  }
}


class HatsScreen extends StatefulWidget {
  Hat current;
  List<Hat> owned;
  int currentCoins;

  HatsScreen({ this.current, this.owned, this.currentCoins });

  @override
  State<StatefulWidget> createState() => _HatsScreenState();
}

class _HatsScreenState extends State<HatsScreen> {
  Hat _current;
  Hat _selected;
  List<Hat> _owned;
  int _currentCoins;

  Hat get current => _current ?? widget.current;
  Hat get selected => _selected ?? widget.current;
  List<Hat> get owned => _owned ?? widget.owned;
  int get currentCoins => _currentCoins ?? widget.currentCoins;
  int get price => (owned.length * 50) + 10;

  void _equipHat() async {
    await GameData.setCurrentHat(selected);
    setState(() {
      _current = selected;
    });
  }

  void _buyHat() async {
    List<Hat> hats = List.from(owned);
    hats.add(selected);

    final newBalance = currentCoins - price;

    await GameData.setCurrentHat(selected);
    await GameData.setOwnedHats(hats);
    await GameData.updateCoins(newBalance);

    setState(() {
      _owned = hats;
      _currentCoins = newBalance;
      _current = _selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Background(
            child: Column(
                children: [
                  TitleHeader("Hats store"),
                  Label(label: "Current coins: $currentCoins"),
                  SizedBox(
                      height: 150,
                      width: 300,
                      child: Preview(const Size(300, 150), selected).widget,
                  ),

                  SizedBox(height: 50),

                  selected == null
                    ? Label(label: "No hat selected")
                    : owned.contains(selected)
                      ? selected == current
                        ? Label(label: "In use")
                        : PrimaryButton(label: "Equip", onPress: () { _equipHat(); })
                      :  currentCoins >= price
                        ? PrimaryButton(label: "Buy", onPress: () { _buyHat(); })
                        : Label(label: "Not enough coins"),

                  SizedBox(height: 25),

                  Label(label: "Next hat price: $price"),
                  SizedBox(height: 25),
                  Expanded(child: GridView.count(
                      crossAxisCount: 3,
                      children: Hat.values.map((hatType) {
                        final hatSprite = HatSprite(hatType, imageName: "hats-background.png");

                        return  FutureBuilder(
                            future: hatSprite.load(),
                            builder: (BuildContext context, AsyncSnapshot snapshot) {
                              if (snapshot.connectionState == ConnectionState.done) {
                                return  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selected = hatType;
                                      });
                                    },
                                    child: Column(
                                               children: [
                                                 Flame.util.spriteAsWidget(const Size(90, 80), hatSprite.hatSprite),
                                                 Label(label: hatSprite.label, fontSize: 14),
                                               ]
                                           )
                                );
                              }

                              return Label(label: "Loading");
                            }
                        );
                      }).toList()
                  ))
                ]
            )
        )
      );
  }
}