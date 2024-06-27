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

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hero_here/hero_here.dart';

import 'config.dart';
import 'eight_thousander.dart';

class EightThousanderDetailsHero extends StatefulWidget {
  final String tag;
  final EightThousander eightThousander;
  final ValueChanged<Velocity>? onClose;

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
  final _scrollController = ScrollController();
  VelocityTracker? _imageDragVelocityTracker;
  double _factorToClose = 0;

  String get tag => widget.tag;

  TextStyle get titleStyle => Theme.of(context)
      .textTheme
      .titleLarge!
      .copyWith(fontWeight: FontWeight.w900);

  Size get screenSize => MediaQuery.sizeOf(context);

  double get factorToClose => _factorToClose;

  set factorToClose(double value) {
    if (_factorToClose == value) return;
    setState(() => _factorToClose = value);
  }

  Velocity? get imageDragVelocity => _imageDragVelocityTracker?.getVelocity();

  Size get imageSize => Size(
      min(screenSize.width, kGridViewConstraints.maxWidth),
      min(screenSize.width, kGridViewConstraints.maxWidth) * kGoldenRatio);

  BorderRadius get imageBorderRadius =>
      BorderRadius.circular(kPreviewImageBorderRadius * factorToClose);

  double get imageScale => 1.0 - (1.0 - kMinImageScaleOnDrag) * factorToClose;

  double get titleOrDescriptionOpacity => 1.0 - factorToClose;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScrollConfiguration(
        behavior: kScrollBehavior,
        child: ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              width: imageSize.width,
              height: imageSize.height,
              child: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: imageSize.width * imageScale,
                  child: Listener(
                    onPointerDown: _handleImagePointerDown,
                    onPointerMove: _handleImagePointerMove,
                    onPointerUp: _handleImagePointerUp,
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
        ),
      );
  HeroHere _buildImageHero() => HeroHere(
        key: ValueKey('$kDetailsHeroKeyPrefix$kImageHeroTagPrefix$tag'),
        tag: '$kImageHeroTagPrefix$tag',
        payload: imageBorderRadius,
        flightShuttleBuilder: _buildImageHeroFlightShuttle,
        rectTweenFactory: _createImageHeroRectTween,
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

  RectTween _createImageHeroRectTween(Rect? begin, Rect? end) =>
      RectTween(begin: begin, end: end);

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

  void _handleScroll() {
    if (_scrollController.position.pixels > 0) return;

    factorToClose =
        min(_scrollController.position.pixels.abs(), kDragDistanceToClose) /
            kDragDistanceToClose;
  }

  void _handleImagePointerDown(PointerDownEvent event) =>
      _imageDragVelocityTracker = VelocityTracker.withKind(event.kind);

  void _handleImagePointerMove(PointerMoveEvent event) =>
      _imageDragVelocityTracker?.addPosition(event.timeStamp, event.position);

  void _handleImagePointerUp(PointerUpEvent event) {
    final imageDragVelocityDy = imageDragVelocity?.pixelsPerSecond.dy ?? 0;

    if (factorToClose < 1 && imageDragVelocityDy < kDragVelocityToClose) return;

    widget.onClose?.call(_imageDragVelocityTracker!.getVelocity());
  }
}
