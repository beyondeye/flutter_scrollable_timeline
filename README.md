[![Pub](https://img.shields.io/pub/v/flutter_scrollable_timeline.svg)](https://pub.dartlang.org/packages/flutter_scrollable_timeline)
[![License](https://img.shields.io/badge/licence-MIT-blue.svg)](https://github.com/beyondeye/flutter_scrollable_timeline/blob/main/LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/beyondeye/flutter_scrollable_timeline.svg?style=social)](https://github.com/beyondeye/flutter_scrollable_timeline)

# Scrollable Timeline
A scrollable and draggable timeline that can be driven by an external time stream,
for example, the current playing time of a YouTube video. Multiple timelines can be kept synced
and automatically stopped when any of them is dragged.

## Examples
There are 3 different runnables samples that has been tested both on mobile and on web.
Here is a recording of the most complete example, run on a Android device.

![YouTube sample](https://github.com/beyondeye/flutter_scrollable_timeline/blob/main/example/samples/scrollable_timeline_youtube.gif)

### Links to examples code
- [simple example](https://github.com/beyondeye/flutter_scrollable_timeline/blob/main/example/lib/pages/basic_example_page.dart)
- [Expandable example](https://github.com/beyondeye/flutter_scrollable_timeline/blob/main/example/lib/pages/expandable_example_page.dart)
  (using the [expandable library](https://pub.dev/packages/expandable))
- [YouTube example](https://github.com/beyondeye/flutter_scrollable_timeline/blob/main/example/lib/pages/youtube_example_page.dart)
  (using the [youtube_player_iframe library](https://pub.dev/packages/youtube_player_iframe))
## Installation

[Installing section](https://pub.dev/packages/flutter_scrollable_timelin#-installing-tab-)

## Usage Example
```
HorizontalPicker(
  minValue: -10,
  maxValue: 50,
  divisions: 600,
  suffix: " cm",
  showCursor: false,
  backgroundColor: Colors.grey.shade900,
  activeItemTextColor: Colors.white,
  passiveItemsTextColor: Colors.amber,
  onChanged: (value) {},
),
```


