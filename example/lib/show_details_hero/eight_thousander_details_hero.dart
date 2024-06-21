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
import 'package:hero_here/hero_here.dart';

import 'config.dart';
import 'eight_thousander.dart';

class EightThousanderDetailsHero extends StatefulWidget {
  final String tag;
  final EightThousander eightThousander;
  final VoidCallback? onClose;

  const EightThousanderDetailsHero({
    super.key,
    required this.tag,
    required this.eightThousander,
    this.onClose,
  });

  @override
  State<EightThousanderDetailsHero> createState() =>
      _EightThousanderDetailsHeroState();
}

class _EightThousanderDetailsHeroState
    extends State<EightThousanderDetailsHero> {
  String get tag => widget.tag;

  TextStyle get titleStyle => Theme.of(context)
      .textTheme
      .titleLarge!
      .copyWith(fontWeight: FontWeight.w900);

  @override
  Widget build(BuildContext context) => ListView(
        padding: EdgeInsets.zero,
        children: [
          AspectRatio(
            aspectRatio: 1 / kGoldenRatio,
            child: _buildImageHero(),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildTitleHero(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildDescriptionHero(),
          ),
          const SizedBox(height: 32),
        ],
      );
  HeroHere _buildImageHero() => HeroHere(
        key: ValueKey('$kDetailsHeroKeyPrefix$kImageHeroTagPrefix$tag'),
        tag: '$kImageHeroTagPrefix$tag',
        flightShuttleBuilder: _buildImageHeroFlightShuttle,
        child: Image(
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          image: AssetImage(widget.eightThousander.image),
        ),
      );

  HeroHere _buildTitleHero() => HeroHere(
        key: ValueKey('$kDetailsHeroKeyPrefix$kTitleHeroTagPrefix$tag'),
        tag: '$kTitleHeroTagPrefix$tag',
        rectTweenFactory: _createTitleOrDescriptionHeroRectTween,
        flightShuttleBuilder: _buildTitleOrDescriptionHeroFlightShuttle,
        child: Text(
          widget.eightThousander.name,
          style: titleStyle,
        ),
      );

  HeroHere _buildDescriptionHero() => HeroHere(
        key: ValueKey('$kDetailsHeroKeyPrefix$kDescriptionHeroTagPrefix$tag'),
        tag: '$kDescriptionHeroTagPrefix$tag',
        rectTweenFactory: _createTitleOrDescriptionHeroRectTween,
        flightShuttleBuilder: _buildTitleOrDescriptionHeroFlightShuttle,
        child: Text(
          widget.eightThousander.description,
          softWrap: true,
          maxLines: null,
        ),
      );

  Widget _buildImageHeroFlightShuttle(
    BuildContext flightContext,
    Animation<double> animation,
    HeroHere fromHero,
    HeroHere toHero,
  ) =>
      Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) => ClipRRect(
              borderRadius: BorderRadiusTween(
                begin: BorderRadius.circular(32),
                end: BorderRadius.zero,
              ).evaluate(animation)!,
              child: child,
            ),
            child: toHero.child,
          ),
        ],
      );

  RectTween _createTitleOrDescriptionHeroRectTween(Rect? begin, Rect? end) =>
      RectTween(begin: end, end: end);

  Widget _buildTitleOrDescriptionHeroFlightShuttle(
    BuildContext flightContext,
    Animation<double> animation,
    HeroHere fromHero,
    HeroHere toHero,
  ) =>
      FadeTransition(
        opacity: animation,
        child: toHero.child,
      );
}
