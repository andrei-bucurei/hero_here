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

import 'package:example/show_details_hero/config.dart';
import 'package:flutter/material.dart';
import 'package:hero_here/hero_here.dart';

import 'eight_thousander.dart';

class EightThousanderPreviewHero extends StatefulWidget {
  final String tag;
  final EightThousander eightThousander;
  final VoidCallback? onTap;

  const EightThousanderPreviewHero({
    super.key,
    required this.tag,
    required this.eightThousander,
    this.onTap,
  });

  @override
  State<EightThousanderPreviewHero> createState() =>
      _EightThousanderPreviewHeroState();
}

class _EightThousanderPreviewHeroState
    extends State<EightThousanderPreviewHero> {
  String get tag => widget.tag;

  TextStyle get titleStyle => Theme.of(context)
      .textTheme
      .titleSmall!
      .copyWith(fontWeight: FontWeight.w900);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildImageHero(),
            ),
            const SizedBox(height: 8),
            _buildTitle(),
            _buildFakeTitleHero(),
            _buildFakeDescriptionHero(),
          ],
        ),
      );

  HeroHere _buildImageHero() => HeroHere(
        key: ValueKey('$kImageHeroTagPrefix$tag'),
        tag: '$kImageHeroTagPrefix$tag',
        child: ClipRRect(
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(32),
          child: Image(
            width: double.infinity,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            image: AssetImage(widget.eightThousander.image),
          ),
        ),
      );

  Text _buildTitle() => Text(
        widget.eightThousander.name,
        style: titleStyle,
      );

  HeroHere _buildFakeDescriptionHero() => HeroHere(
        key: ValueKey('$kDescriptionHeroTagPrefix$tag'),
        tag: '$kDescriptionHeroTagPrefix$tag',
        rectTweenFactory: _createTitleOrDescriptionHeroRectTween,
        flightShuttleBuilder: _buildTitleOrDescriptionHeroFlightShuttle,
        child: const SizedBox(),
      );

  HeroHere _buildFakeTitleHero() => HeroHere(
        key: ValueKey('$kTitleHeroTagPrefix$tag'),
        tag: '$kTitleHeroTagPrefix$tag',
        rectTweenFactory: _createTitleOrDescriptionHeroRectTween,
        flightShuttleBuilder: _buildTitleOrDescriptionHeroFlightShuttle,
        child: const SizedBox(),
      );

  RectTween _createTitleOrDescriptionHeroRectTween(Rect? begin, Rect? end) =>
      RectTween(begin: begin, end: begin);

  Widget _buildTitleOrDescriptionHeroFlightShuttle(
    BuildContext flightContext,
    Animation<double> animation,
    HeroHere fromHero,
    HeroHere toHero,
  ) =>
      FadeTransition(
        opacity: ReverseAnimation(animation),
        child: fromHero.child,
      );
}
