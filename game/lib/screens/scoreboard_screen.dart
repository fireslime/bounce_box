import "package:flutter/material.dart";
import "package:flame/flame.dart";

import "../ui/button.dart" as buttons;
import "../ui/background.dart";
import "../ui/label.dart";
import "../ui/title_header.dart";

import "./game/hats.dart";

import "../scoreboard.dart";
import "../main.dart";

class ScoreboardScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final builder = FutureBuilder(
        future: ScoreBoard.fetchScoreboard(),
        builder: (BuildContext context, AsyncSnapshot<List<ScoreBoardEntry>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting: {
              return Center(child: Label(label: "Loading results..."));
            }
            case ConnectionState.done: {
              if (snapshot.hasError) {
                return Center(child: Label(label: "Could not fetch scoreboard."));
              }
              final _entries = snapshot.data;
              int i = 1;
              return ListView(
                padding: const EdgeInsets.all(10),
                children: _entries == null
                ? []
                : _entries.map((entry) =>
                    Container(
                        child: Row(
                            children: [
                              SizedBox(width: 120, child:
                                      Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Flame.util.spriteAsWidget(Size(60, 40), HatSprite(entry.hat, image: Main.hatsWithBackground).hatSprite),
                                            Label(label: "#${i++} ", fontSize: 14),
                                          ],
                                      )
                              ),
                              Expanded(child: SizedBox(height: 40, child:
                                      Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Label(label: "${entry.playerId}", fontSize: 14),
                                            Label(label: "${entry.points}", fontSize: 14),
                                          ]
                                      )
                              )),
                            ]
                        )
                    )
                ).toList()
            );
            }
          }
        }
    );

    return Scaffold(
        body: Background(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stack(
                      children: [
                        Positioned(
                            left: 5,
                            top: 0,
                            child: buttons.BackButton(onPress: () {
                              Navigator.pushNamed(context, "/");
                            }),
                        ),
                        Center(
                            child: TitleHeader("Scoreboard")
                        )
                      ],
                  ),
                  Expanded( child: builder)
                ]
            )
          )
      );
  }
}
