// Copyright 2024 Igor Kurilenko
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hero_here/hero_here.dart';

import 'config.dart';
import 'eight_thousander_details_hero.dart';
import 'eight_thousander_preview_hero.dart';

void main() {
  timeDilation = 10;
  runApp(
      MaterialApp(
        title: 'HeroHere Example',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, brightness: Brightness.light),
        darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
        home: const ShowDetailsExample(),
      ),
    );
}

class ShowDetailsExample extends StatefulWidget {
  const ShowDetailsExample({super.key});

  @override
  State<ShowDetailsExample> createState() => _ShowDetailsExampleState();
}

class _ShowDetailsExampleState extends State<ShowDetailsExample> {
  int? _showDetailsIndex;

  bool get detailsVisible => _showDetailsIndex != null;

  @override
  Widget build(BuildContext context) => Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: _buildAppBar(),
        body: _buildBody(),
      );

  AppBar _buildAppBar() => AppBar(
        forceMaterialTransparency: true,
        leading: AnimatedSwitcher(
          duration: HeroHere.defaultFlightAnimationDuration,
          child: detailsVisible
              ? Material(
                  color: Colors.transparent,
                  key: UniqueKey(),
                  child: IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _closeDetails,
                  ),
                )
              : SizedBox(key: UniqueKey()),
        ),
      );

  Widget _buildBody() => HeroHereSwitcher(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: ConstrainedBox(
                constraints: kGridViewConstraints,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    AnimatedOpacity(
                      duration: HeroHere.defaultFlightAnimationDuration,
                      curve: HeroHere.defaultFlightAnimationCurve,
                      opacity: detailsVisible ? kGridViewOpacityOnOpen : 1.0,
                      child: IgnorePointer(
                        ignoring: detailsVisible,
                        child: GridView.builder(
                          clipBehavior: Clip.none,
                          padding: const EdgeInsets.all(8),
                          gridDelegate: kGridViewDelegate,
                          itemCount: kEightThousanders.length,
                          itemBuilder: _buildGridItem,
                        ),
                      ),
                    ),
                    if (detailsVisible) _buildDetails(_showDetailsIndex!),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildGridItem(BuildContext context, int index) {
    final eightThousander = kEightThousanders[index];

    return EightThousanderPreviewHero(
      tag: eightThousander.image,
      eightThousander: eightThousander,
      onTap: () => _showDetails(index),
    );
  }

  Widget _buildDetails(int index) {
    final eightThousander = kEightThousanders[index];

    return EightThousanderDetailsHero(
      tag: eightThousander.image,
      eightThousander: eightThousander,
      onClose: _closeDetails,
    );
  }

  void _showDetails(int index) => setState(() => _showDetailsIndex = index);

  void _closeDetails() => setState(() => _showDetailsIndex = null);
}
