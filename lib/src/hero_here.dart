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
import 'package:flutter/rendering.dart';

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
  late _SwitchingState _switchingState = _Prepare(this);
  Widget? _child;
  StateSetter setChildState = (_) {};
  StateSetter setSkyState = (_) {};
  RawImage? _childScreenshot;
  bool _childOffstage = false;

  Iterable<_Flight> get flights => _flightsByTag.values;

  Iterable<Object> get flightTags => _flightsByTag.keys;

  @override
  void dispose() {
    for (final flight in flights) {
      flight.dispose();
    }
    super.dispose();
  }

  Set<_Hero> findHeroes() => _childKey.currentContext?.findHeroes() ?? const {};

  _Flight? getFlight(Object tag) => _flightsByTag[tag];

  RawImage? takeChildScreenshot() {
    try {
      final renderObject = _childKey.currentContext!.findRenderObject();
      final image = (renderObject as RenderRepaintBoundary).toImageSync(
        pixelRatio: MediaQuery.devicePixelRatioOf(_childKey.currentContext!),
      );
      return RawImage(
        width: renderObject.size.width,
        height: renderObject.size.height,
        image: image,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) => Material(
        child: Stack(
          children: [
            StatefulBuilder(builder: (context, setState) {
              setChildState = setState;
              return _buildChild();
            }),
            StatefulBuilder(builder: (context, setState) {
              setSkyState = setState;
              return _buildSky();
            }),
          ],
        ),
      );

  Widget _buildChild() {
    _switchingState.execute();

    return Stack(
      children: [
        Offstage(
          offstage: _childOffstage,
          child: RepaintBoundary(
            key: _childKey,
            child: _child,
          ),
        ),
        if (_childScreenshot != null) _childScreenshot!,
      ],
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
  final Set<_Hero>? prevSwitchHeroes;

  _SwitchingState(
    this.switcher, {
    this.prevSwitchHeroes,
  });

  void notifyWillSwitch(Iterable<_Hero> heroes) {
    for (final hero in heroes) {
      hero.willSwitch();
    }
  }

  void execute();
}

class _Idle extends _SwitchingState {
  _Idle(
    super.switcher, {
    super.prevSwitchHeroes,
  });

  @override
  void execute() {
    switcher._child = switcher.widget.child;
    switcher._switchingState = _Prepare(
      switcher,
      prevSwitchHeroes: prevSwitchHeroes,
    );
  }
}

class _Prepare extends _SwitchingState {
  _Prepare(
    super.switcher, {
    super.prevSwitchHeroes,
  });

  @override
  void execute() =>
      WidgetsBinding.instance.addPostFrameCallback(_prepareSwitch);

  void _prepareSwitch(_) {
    final curHeroes = switcher.findHeroes();

    notifyWillSwitch(curHeroes);

    switcher.setChildState(() {
      switcher._childScreenshot = switcher.takeChildScreenshot();
      switcher._child = switcher.widget.child;
      switcher._childOffstage = true;
      switcher._switchingState = _Execute(
        switcher,
        prevSwitchHeroes: prevSwitchHeroes,
        curHeroes: curHeroes,
      );
    });
  }
}

class _Execute extends _SwitchingState {
  final Set<_Hero> curHeroes;

  _Execute(
    super.switcher, {
    super.prevSwitchHeroes,
    required this.curHeroes,
  });

  @override
  void execute() => WidgetsBinding.instance.addPostFrameCallback(_switch);

  void _switch(_) {
    final nextHeroes = switcher.findHeroes();
    final flightManifestsByTag = _getFlightManifests(nextHeroes);

    notifyWillSwitch(nextHeroes);

    _offstageRedundantNextHeroes(nextHeroes, flightManifestsByTag);

    _dispatchFlights(flightManifestsByTag);

    switcher.setChildState(() {
      switcher._childScreenshot = null;
      switcher._childOffstage = false;
      switcher._switchingState = _Idle(
        switcher,
        prevSwitchHeroes: nextHeroes,
      );
    });
  }

  Map<Object, _FlightManifest> _getFlightManifests(Set<_Hero> nextHeroes) {
    final result = <Object, _FlightManifest>{};

    for (final x in nextHeroes) {
      final manifest = result.putIfAbsent(
          x.tag, () => _FlightManifest(tag: x.tag, from: x, to: x));
      manifest.to = x;
    }

    for (final manifest in result.values) {
      final existingFlight = switcher.getFlight(manifest.tag);
      if (existingFlight?.manifest.from == manifest.to) {
        manifest.from = existingFlight!.manifest.to;
      } else if (existingFlight != null) {
        manifest.from = existingFlight.manifest.from;
      } else {
        manifest.from = curHeroes
                .where((x) => x.tag == manifest.tag)
                .where((x) => x.onstage)
                .where((x) => prevSwitchHeroes?.contains(x) ?? false)
                .firstOrNull ??
            curHeroes
                .where((x) => x.tag == manifest.tag)
                .where((x) => x.onstage)
                .firstOrNull ??
            manifest.from;
      }
    }
    return result;
  }

  void _offstageRedundantNextHeroes(
    Set<_Hero> nextHeroes,
    Map<Object, _FlightManifest> flightManifestsByTag,
  ) {
    for (final hero in nextHeroes) {
      final manifest = flightManifestsByTag[hero.tag];
      if (manifest?.from != hero && manifest?.to != hero) {
        hero.offstage = true;
      }
    }
  }

  void _dispatchFlights(Map<Object, _FlightManifest> flightManifestsByTag) {
    final tags =
        flightManifestsByTag.keys.followedBy(switcher.flightTags).toSet();

    for (final tag in tags) {
      final flightManifest = flightManifestsByTag[tag];
      final existingFlight = switcher.getFlight(tag);

      if (flightManifest == null || flightManifest.isIdle) {
        existingFlight?.abort();
        continue;
      }

      if (existingFlight != null) {
        existingFlight.update(flightManifest);
      } else {
        _Flight.start(
          switcher: switcher,
          manifest: flightManifest,
        );
      }
    }
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
  final _childKey = GlobalKey();
  bool _offstage = false;
  Rect? _placeholderRect;

  Key get key => widget.key!;

  Object get tag => widget.tag;

  set offstage(bool value) {
    if (_offstage == value) return;
    _setState(() => _offstage = value);
  }

  bool get offstage => _offstage;

  bool get onstage => !offstage;

  Rect? get placeholderRect => _placeholderRect;

  @override
  void initState() {
    super.initState();

    final switcher = context.findAncestorStateOfType<_Switcher>();
    final existingFlight = switcher?.getFlight(tag);

    if (existingFlight != null) {
      _initState(existingFlight);
    }
  }

  void willSwitch() => _placeholderRect = computeGlobalRect();

  Rect? computeGlobalRect() =>
      _childKey.currentContext?.findRenderObject()?.computeGlobalRect();

  @override
  Widget build(BuildContext context) => SizedBox(
        width: offstage ? _placeholderRect?.width : null,
        height: offstage ? _placeholderRect?.height : null,
        child: Offstage(
          offstage: offstage,
          child: KeyedSubtree(
            key: _childKey,
            child: widget.child,
          ),
        ),
      );

  @override
  bool operator ==(Object other) =>
      (other is _Hero && tag == other.tag) && key == other.key;

  @override
  int get hashCode => Object.hash(tag, key);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      "_Hero(tag: '$tag', key: $key, offstage: $offstage)";

  void _initState(_Flight existingFlight) {
    if (key == existingFlight.manifest.from.key) {
      existingFlight.manifest.from = this;
      _placeholderRect = existingFlight.manifest.from.placeholderRect;
    }

    if (key == existingFlight.manifest.to.key) {
      existingFlight.manifest.to = this;
      _placeholderRect = existingFlight.manifest.to.placeholderRect;
    }

    _offstage = true;
  }

  void _setState(VoidCallback cb) {
    if (!mounted) return cb();
    setState(cb);
  }
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

  factory _Flight.start({
    required _Switcher switcher,
    required _FlightManifest manifest,
  }) {
    final flight = _Flight(
      switcher: switcher,
      manifest: manifest,
    );

    if(kDebugMode) {
      print('START FLIGHT $manifest');
    }

    manifest.from.offstage = true;

    // TODO: implement

    return flight;
  }

  void update(_FlightManifest flightManifest) {
    // TODO: implement
  }

  void abort() {
    // TODO: implement
  }
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

  bool get isIdle => from == to;

  @override
  int get hashCode => Object.hash(from, to);

  @override
  bool operator ==(Object other) =>
      (other is _FlightManifest && from == other.from) && to == other.to;

  @override
  String toString() => '_FlightManifest(from: $from, to: $to)';
}

extension _RenderObject on RenderObject {
  Rect? computeGlobalRect() {
    if (this is! RenderBox) return null;
    final renderBox = this as RenderBox;
    if (!renderBox.hasSize) return null;
    return renderBox.localToGlobal(Offset.zero) & renderBox.size;
  }
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
