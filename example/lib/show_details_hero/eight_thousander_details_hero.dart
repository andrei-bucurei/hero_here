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

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:hero_here/hero_here.dart';

import 'config.dart';
import 'eight_thousander.dart';
import 'util.dart';

class EightThousanderDetailsHero extends StatefulWidget {
  final String tag;
  final EightThousander eightThousander;
  final ValueChanged<DragEndDetails>? onClose;

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

class _EightThousanderDetailsHeroState extends State<EightThousanderDetailsHero>
    with SingleTickerProviderStateMixin {
  Offset _curOffset = Offset.zero;
  late AnimationController _offsetController;
  late Animation<Offset> _offsetAnimation;

  String get tag => widget.tag;

  TextStyle get titleStyle => Theme.of(context)
      .textTheme
      .titleLarge!
      .copyWith(fontWeight: FontWeight.w900);

  Size get screenSize => MediaQuery.sizeOf(context);

  Size get imageSize => Size(
      min(screenSize.width, kGridViewConstraints.maxWidth),
      min(screenSize.width, kGridViewConstraints.maxWidth) * kGoldenRatio);

  BorderRadius get imageBorderRadius =>
      BorderRadius.circular(kPreviewImageBorderRadius *
          (min(_curOffset.distance, kDragDistanceToClose) /
              kDragDistanceToClose));

  double get draggedToClose =>
      min(_curOffset.distance, kDragDistanceToClose) / kDragDistanceToClose;

  double get imageScale => 1.0 - (1.0 - kMinImageScaleOnDrag) * draggedToClose;

  double get titleOrDescriptionOpacity {
    return 1.0 - draggedToClose;
    // TODO: checkout
    // return 1.0 -
    //     (min(max(0, _curOffset.dy), kDragDistanceToClose) /
    //         kDragDistanceToClose);
  }

  @override
  void initState() {
    super.initState();
    _offsetController = AnimationController(
      vsync: this,
      lowerBound: kOffsetAnimationControllerLowerBound,
      upperBound: kOffsetAnimationControllerUpperBound,
    )..addListener(() => setState(() => _curOffset = _offsetAnimation.value));
  }

  @override
  void dispose() {
    super.dispose();
    _offsetController.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView(
        padding: EdgeInsets.zero,
        children: [
          Transform.translate(
            offset: _curOffset,
            child: SizedBox(
              width: imageSize.width,
              height: imageSize.height,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: imageSize.width * imageScale,
                  child: GestureDetector(
                    onPanDown: (details) {
                      _offsetController.stop();
                    },
                    onPanUpdate: (details) =>
                        setState(() => _curOffset += details.delta / 2),
                    onPanEnd: (details) {
                      if (_shouldClose(details)) {
                        widget.onClose?.call(details);
                      } else {
                        _runImageOffsetAnimation(
                          velocity: details.getUnitVelocity(screenSize),
                        );
                      }
                    },
                    child: AspectRatio(
                      aspectRatio: 1 / kGoldenRatio,
                      child: ClipRRect(
                        borderRadius: imageBorderRadius,
                        child: _buildImageHero(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(0, _curOffset.dy),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildTitleHero(),
            ),
          ),
          Transform.translate(
            offset: Offset(0, _curOffset.dy),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildDescriptionHero(),
            ),
          ),
          const SizedBox(height: 32),
        ],
      );
  HeroHere _buildImageHero() => HeroHere(
        key: ValueKey('$kDetailsHeroKeyPrefix$kImageHeroTagPrefix$tag'),
        tag: '$kImageHeroTagPrefix$tag',
        payload: imageBorderRadius,
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
        child: Opacity(
          opacity: titleOrDescriptionOpacity,
          child: Text(
            widget.eightThousander.name,
            style: titleStyle,
          ),
        ),
      );

  HeroHere _buildDescriptionHero() => HeroHere(
        key: ValueKey('$kDetailsHeroKeyPrefix$kDescriptionHeroTagPrefix$tag'),
        tag: '$kDescriptionHeroTagPrefix$tag',
        rectTweenFactory: _createTitleOrDescriptionHeroRectTween,
        flightShuttleBuilder: _buildTitleOrDescriptionHeroFlightShuttle,
        child: Opacity(
          opacity: titleOrDescriptionOpacity,
          child: Text(
            widget.eightThousander.description,
            softWrap: true,
            maxLines: null,
          ),
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
                begin: BorderRadius.circular(kPreviewImageBorderRadius),
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

  bool _shouldClose(DragEndDetails details) =>
      (_curOffset.dy > kDragDistanceToClose && _curOffset.dy > 0) ||
      (details.velocity.pixelsPerSecond.dy > kDragDistanceToClose);

  void _runImageOffsetAnimation({
    Offset endOffset = Offset.zero,
    required double velocity,
  }) {
    _offsetAnimation = _offsetController.drive(
      Tween<Offset>(begin: _curOffset, end: endOffset),
    );

    _offsetController.animateWith(
      SpringSimulation(kSpringDesription, 0, 1, velocity),
    );
  }
}
