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

import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef _Hero = _HeroHereState;
typedef _Switcher = _HeroHereSwitcherState;

class HeroHereSwitcher extends StatefulWidget {
  final Widget? child;

  const HeroHereSwitcher({
    super.key,
    this.child,
  });

  @override
  State<HeroHereSwitcher> createState() => _HeroHereSwitcherState();
}

class _HeroHereSwitcherState extends State<HeroHereSwitcher>
    with TickerProviderStateMixin {
  final _childKey = GlobalKey();
  final _flightsByTag = <Object, _Flight>{};
  late _SwitchingState _switchingState = _Idle(switcher: this);

  Iterable<_Flight> get flights => _flightsByTag.values;

  @override
  void dispose() {
    for (final flight in flights) {
      flight.dispose();
    }
    super.dispose();
  }

  Set<_Hero> findHeroes() => _childKey.currentContext?.findHeroes() ?? const {};

  @override
  Widget build(BuildContext context) => Material(
        child: Stack(
          children: [
            _buildChild(),
            _buildSky(),
          ],
        ),
      );

  Widget _buildChild() {
    _switchingState.execute();
    return RepaintBoundary(
      key: _childKey,
      child: widget.child ?? const SizedBox(),
    );
  }

  Widget _buildSky() => Stack(
        children: [
          ...flights.map(
            (flight) => _FlightWidget(
              key: ValueKey(flight.tag),
              flight: flight,
            ),
          ),
        ],
      );
}

abstract class _SwitchingState {
  final _Switcher switcher;

  _SwitchingState({required this.switcher});

  void execute();
}

class _Idle extends _SwitchingState {
  _Idle({required super.switcher});

  @override
  void execute() {
    // TODO: implement

    if (kDebugMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print(switcher.findHeroes());
      });
    }
  }
}

class _Prepare extends _SwitchingState {
  _Prepare({required super.switcher});

  @override
  void execute() {
    // TODO: get current heroes, make and show a stage screenshot, update the switcher's child
  }
}

class _Execute extends _SwitchingState {
  _Execute({required super.switcher});

  @override
  void execute() {
    // TODO: get new heroes, hide screenshot, run flights
  }
}

class HeroHere extends StatefulWidget {
  final Object tag;
  final Widget child;

  const HeroHere({
    required super.key,
    required this.tag,
    required this.child,
  });

  @override
  State<HeroHere> createState() => _HeroHereState();
}

class _HeroHereState extends State<HeroHere> {
  Key get key => widget.key!;

  Object get tag => widget.tag;

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  bool operator ==(Object other) =>
      (other is _Hero && tag == other.tag) && key == other.key;

  @override
  int get hashCode => Object.hash(tag, key);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      "_Hero(tag: '$tag', key: $key)";
}

class _FlightWidget extends StatefulWidget {
  final _Flight flight;
  const _FlightWidget({
    super.key,
    required this.flight,
  });

  @override
  State<_FlightWidget> createState() => _FlightWidgetState();
}

class _FlightWidgetState extends State<_FlightWidget> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Flight extends ChangeNotifier {
  final _Switcher switcher;
  final _FlightManifest manifest;

  _Flight({
    required this.switcher,
    required this.manifest,
  });

  Object get tag => manifest.tag;
}

class _FlightManifest {
  final Object tag;
  _Hero from;
  _Hero to;

  _FlightManifest({
    required this.tag,
    required this.from,
    required this.to,
  });

  @override
  int get hashCode => Object.hash(from, to);

  @override
  bool operator ==(Object other) =>
      (other is _FlightManifest && from == other.from) && to == other.to;

  @override
  String toString() => '_FlightManifest(from: $from, to: $to)';
}

extension _BuildContext on BuildContext {
  Set<_Hero> findHeroes() {
    // ignore: prefer_collection_literals
    final result = LinkedHashSet<_Hero>();

    void findHeroes(Element element) {
      final widget = element.widget;
      if (widget is HeroHere && element is StatefulElement) {
        result.add(element.state as _Hero);
      } else if ((widget is HeroMode && !widget.enabled) ||
          (widget is HeroHereSwitcher) ||
          (widget is _FlightWidget)) {
        return;
      }
      element.visitChildElements(findHeroes);
    }

    visitChildElements(findHeroes);

    return result;
  }
}
