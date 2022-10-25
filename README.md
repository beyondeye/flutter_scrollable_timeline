[![Pub](https://img.shields.io/pub/v/flutter_scrollable_timeline.svg)](https://pub.dartlang.org/packages/flutter_scrollable_timeline)
[![License](https://img.shields.io/badge/licence-BSD3-blue.svg)](https://github.com/beyondeye/flutter_scrollable_timeline/blob/main/LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/beyondeye/flutter_scrollable_timeline.svg?style=social)](https://github.com/beyondeye/flutter_scrollable_timeline)

# Scrollable Timeline
A scrollable and draggable timeline widget that can be driven by an external time stream,
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

```dart
ScrollableTimeline(
  lengthSecs: 100,
  stepSecs: 2,
  height: 120,
  rulerOutsidePadding: 10,
  showCursor: true,
  showMinutes: true,
  backgroundColor: Colors.lightBlue.shade50,
  activeItemTextColor: Colors.blue.shade800,
  itemTextColor: Colors.blue.shade300,
  onDragEnd: (double t) {
    print("*FLT* drag detected for ScrollableTimelineF to target time $t");
  }
)
```

## Constructor Parameters Reference

Parameter              |Default value | Description
----------             |------------      |------------
``height``             |                  | ``double`` the height of the timeline
``backgroundColor``    | ``Colors.white`` | the background color of the timeline
``lengthSecs``         |                  | ``int`` the total number of seconds shown in the timeline
``stepSecs``           |                  | ``int`` the time step to use between items in the timeline
``shownSecsMultiples`` | ``1``            | ``int``  number of seconds between shown seconds marks
``itemExtent``         |  ``60``          | ``int`` width of each time mark item (with text of minutes and seconds)
``itemTextColor``      | ``Colors.grey``  | ``Color``  color for minutes and seconds texts in the time line
``showMinutes``        | ``true``         | ``bool``  true if both minutes and seconds should be shown in each time mark
``showCursor``         | ``true``         | ``bool`` true if the central cursor indicating the current selected time should be shown
``cursorColor``        | ``Colors.red``   | ``Color`` color for the central cursor indicating the current selected time
``rulerSize``          |  ``8``           | ``double``  size of the top and bottom  ruler marks
``rulerOutsidePadding``|  ``10``          | ``double`` outside padding of the the  ruler marks: top for the top ruler marks, and bottom for the bottom ruler marks
``rulerInsidePadding`` |  ``5``           | ``double`` inside padding of the the  ruler marks: bottom for  the top ruler marks and top for the bottom ruler marks
``timeStream``         |  ``null``        | ``Stream?``  an optional stream of time values. when a value is received the timeline is scrolled to the received time value.
``onDragStart``        |                  | callback when the user start dragging the timeline, called with the current time value when dragging started. When in the dragging state, updates from timeStream are ignored
``onDragEnd``          |                  | callback when the user stops dragging the timeline, called with the selected time value when dragging ended.

## Parameters Legend
1) rulerOutsidePadding
2) rulerSize
3) rulerInsidePadding
4) minutes text
5) seconds text
6) itemExtent
7) cursor

![params legend](https://github.com/beyondeye/flutter_scrollable_timeline/blob/main/example/samples/min_secs_timeline_with_legend_clipped.png)



