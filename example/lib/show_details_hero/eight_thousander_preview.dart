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

import 'eight_thousander.dart';

class EightThousanderPreview extends StatefulWidget {
  final EightThousander eightThousander;
  final VoidCallback? onTap;

  const EightThousanderPreview({
    super.key,
    required this.eightThousander,
    this.onTap,
  });

  @override
  State<EightThousanderPreview> createState() => _EightThousanderPreviewState();
}

class _EightThousanderPreviewState extends State<EightThousanderPreview> {
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
            ),
            const SizedBox(height: 8),
            Text(
              widget.eightThousander.name,
              style: titleStyle,
            ),
          ],
        ),
      );
}
