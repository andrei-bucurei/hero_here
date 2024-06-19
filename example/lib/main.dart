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

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hero_here/hero_here.dart';

const kHeroTag = 'hero';
const kAutoHeroSwitchingDuration = Duration(milliseconds: 500);
const kHeroFlightAnimationDuration = Duration(milliseconds: 1000);

void main() => runApp(
      MaterialApp(
        title: 'HeroHere Example',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, brightness: Brightness.light),
        darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
        home: const HeroHereExample(),
      ),
    );

class HeroHereExample extends StatefulWidget {
  const HeroHereExample({super.key});

  @override
  State<HeroHereExample> createState() => _HeroHereExampleState();
}

class _HeroHereExampleState extends State<HeroHereExample> {
  HeroType _curHeroType = HeroType.red;
  bool _paused = true;
  Timer? _timer;

  HeroType get curHeroType => _curHeroType;

  set curHeroType(HeroType value) {
    if (_curHeroType == value) return;
    setState(() => _curHeroType = value);
  }

  bool get paused => _paused;

  set paused(bool value) {
    if (value == _paused) return;
    setState(() {
      (_paused = value) ? _pauseHeroSwitching() : _startHeroSwitching();
    });
  }

  @override
  void initState() {
    super.initState();

    if (!paused) {
      _startHeroSwitching();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: HeroHereSwitcher(
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: curHeroType == HeroType.red
                      ? HeroHere(
                          key: const ValueKey(HeroType.red),
                          tag: kHeroTag,
                          flightAnimationDuration: kHeroFlightAnimationDuration,
                          flightShuttleBuilder: _flightShuttleBuilder,
                          child: Container(color: Colors.red),
                        )
                      : null,
                ),
                SizedBox(
                  width: 150,
                  height: 150,
                  child: curHeroType == HeroType.green
                      ? HeroHere(
                          key: const ValueKey(HeroType.green),
                          tag: kHeroTag,
                          flightAnimationDuration: kHeroFlightAnimationDuration,
                          flightShuttleBuilder: _flightShuttleBuilder,
                          child: Container(color: Colors.green),
                        )
                      : null,
                ),
                SizedBox(
                  width: 100,
                  height: 100,
                  child: curHeroType == HeroType.blue
                      ? HeroHere(
                          key: const ValueKey(HeroType.blue),
                          tag: kHeroTag,
                          flightAnimationDuration: kHeroFlightAnimationDuration,
                          flightShuttleBuilder: _flightShuttleBuilder,
                          child: Container(color: Colors.blue),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => paused = !paused,
                    icon: Icon(_paused ? Icons.play_arrow : Icons.pause),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      paused = true;
                      curHeroType = HeroType.red;
                    },
                    icon: Icon(curHeroType == HeroType.red
                        ? Icons.circle
                        : Icons.radio_button_off),
                    color: curHeroType == HeroType.red
                        ? Colors.red
                        : Theme.of(context).colorScheme.secondary,
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      paused = true;
                      curHeroType = HeroType.green;
                    },
                    icon: Icon(curHeroType == HeroType.green
                        ? Icons.circle
                        : Icons.radio_button_off),
                    color: curHeroType == HeroType.green
                        ? Colors.green
                        : Theme.of(context).colorScheme.secondary,
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      paused = true;
                      curHeroType = HeroType.blue;
                    },
                    icon: Icon(curHeroType == HeroType.blue
                        ? Icons.circle
                        : Icons.radio_button_off),
                    color: curHeroType == HeroType.blue
                        ? Colors.blue
                        : Theme.of(context).colorScheme.secondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _flightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroHere fromHero,
    HeroHere toHero,
  ) =>
      Stack(
        fit: StackFit.expand,
        children: [
          toHero.child,
          FadeTransition(
            opacity: ReverseAnimation(animation),
            child: fromHero.child,
          ),
        ],
      );

  void _startHeroSwitching() {
    _timer = Timer.periodic(kAutoHeroSwitchingDuration, (_) {
      final i = Random().nextInt(HeroType.values.length);
      curHeroType = HeroType.values[i];
    });
  }

  void _pauseHeroSwitching() {
    _timer?.cancel();
  }
}

enum HeroType { red, green, blue }
