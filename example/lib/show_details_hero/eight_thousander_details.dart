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

import 'config.dart';
import 'eight_thousander.dart';

class EightThousanderDetails extends StatefulWidget {
  final EightThousander eightThousander;
  final VoidCallback? onClose;

  const EightThousanderDetails({
    super.key,
    required this.eightThousander,
    this.onClose,
  });

  @override
  State<EightThousanderDetails> createState() => _EightThousanderDetailsState();
}

class _EightThousanderDetailsState extends State<EightThousanderDetails> {
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
            child: Image(
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              image: AssetImage(widget.eightThousander.image),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.eightThousander.name,
              style: titleStyle,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              widget.eightThousander.description,
              softWrap: true,
              maxLines: null,
            ),
          ),
          const SizedBox(height: 32),
        ],
      );
}
