// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// original code from https://github.com/sarbagyastha/youtube_player_flutter/tree/master/packages/youtube_player_iframe/example/lib
class MetaDataSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return YoutubeValueBuilder(
      buildWhen: (o, n) {
        return o.metaData != n.metaData ||
            o.playbackQuality != n.playbackQuality;
      },
      builder: (context, value) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Text('Title', value.metaData.title),
            const SizedBox(height: 10),
            _Text('Channel', value.metaData.author),
            const SizedBox(height: 10),
            _Text(
              'Playback Quality',
              value.playbackQuality ?? '',
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _Text('Video Id', value.metaData.videoId),
                const Spacer(),
                const _Text(
                  'Speed',
                  '',
                ),
                YoutubeValueBuilder( // why I need another internal YoutubeValueBuilder here?:  because this specific child should be changing always when YoutubePlayerController value changes
                  builder: (context, value) {
                    return DropdownButton(
                      value: value.playbackRate,
                      isDense: true,
                      underline: const SizedBox(),
                      items: PlaybackRate.all
                          .map(
                            (rate) => DropdownMenuItem(
                              child: Text(
                                '${rate}x',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              value: rate,
                            ),
                          )
                          .toList(),
                      onChanged: (double? newValue) {
                        if (newValue != null) {
                          // here I am using an extension method to access ytController associated to current context using YoutubePlayerControllerProvider
                          context.ytController.setPlaybackRate(newValue);
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
/// a styled text label (title) and text value(value)
class _Text extends StatelessWidget {
  final String title;
  final String value;

  const _Text(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: '$title : ',
        style: Theme.of(context).textTheme.labelLarge,
        children: [
          TextSpan(
            text: value,
            style: Theme.of(context)
                .textTheme
                .labelMedium!
                .copyWith(fontWeight: FontWeight.w300),
          ),
        ],
      ),
    );
  }
}
