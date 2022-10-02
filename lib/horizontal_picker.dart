import 'dart:math';

import 'package:flutter/material.dart';

import 'item_widget.dart';

enum InitialPosition { start, center, end }

class HorizontalPicker extends StatefulWidget {
  final double minValue, maxValue;
  final int divisions;
  final double height;
  final Function(double) onChanged;
  final InitialPosition initialPosition;
  final Color backgroundColor;
  final bool showCursor;
  final Color cursorColor;
  final Color activeItemTextColor;
  final Color passiveItemsTextColor;
  final String suffix;

  HorizontalPicker({
    required this.minValue,
    required this.maxValue,
    required this.divisions,
    required this.height,
    required this.onChanged,
    this.initialPosition = InitialPosition.center,
    this.backgroundColor = Colors.white,
    this.showCursor = true,
    this.cursorColor = Colors.red,
    this.activeItemTextColor = Colors.blue,
    this.passiveItemsTextColor = Colors.grey,
    this.suffix = "",
  }) : assert(minValue < maxValue);

  @override
  _HorizontalPickerState createState() => _HorizontalPickerState();
}

class _HorizontalPickerState extends State<HorizontalPicker> {
  // *DARIO* Similar to a standard [ScrollController] but with the added convenience
  // mechanisms to read and go to item indices rather than a raw pixel scroll
  late FixedExtentScrollController _scrollController;
  late int curItem;
  List<Map> valueMap = [];

  @override
  void initState() {
    super.initState();

    // *DARIO* this define each item in the horizontal scale according to number of
    // divisions and according to widget minValue and maxValue:
    // *IMPORTANT* I need to customize it
    //TODO I need to define a "value" a "primary_value" a "secondary_value (minutes and seconds
    for (var i = 0; i <= widget.divisions; i++) {
      valueMap.add({
        "value": widget.minValue +
            ((widget.maxValue - widget.minValue) / widget.divisions) * i,
        "fontSize": 14.0,
        "color": widget.passiveItemsTextColor,
      });
    }
    setScrollController();
  }

  void setScrollController() {
    int initialItem;
    switch (widget.initialPosition) {
      case InitialPosition.start:
        initialItem = 0;
        break;
      case InitialPosition.center:
        initialItem = (valueMap.length ~/ 2);
        break;
      case InitialPosition.end:
        initialItem = valueMap.length - 1;
        break;
    }

    _scrollController = FixedExtentScrollController(initialItem: initialItem);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      height: widget.height,
      alignment: Alignment.center,
      color: widget.backgroundColor,
      child: Stack( //*DARIO* use a stack here in order to show the (optional) cursor on top of the scrollview
        children: <Widget>[
          RotatedBox( //*DARIO* needed to make ListWheelScrollView horizontal
            quarterTurns: 3,
            child: ListWheelScrollView(
                controller: _scrollController,
                itemExtent: 60, //the size in pixel of each item in the scale
                useMagnifier: false, //*DARIO* magnification of center item
                magnification: 1.0,  //*DARIO* magnification of center item (not continuous)
                squeeze: 1, //*DARIO* squeeze factor for item size (itemExtent) to show more items
                diameterRatio :2, //default is 2.0 (the smaller it is the smallest is the wheel diameter (more compression at border
                perspective : 0.001, //default is 0.003 (must be 0<p <0.01) (how farthest item in the circle are shown with reduced size
                onSelectedItemChanged: (item) {
                  curItem = item;
                  int decimalCount = 1;
                  num fac = pow(10, decimalCount);
                  valueMap[item]["value"] =
                      (valueMap[item]["value"] * fac).round() / fac;
                  widget.onChanged(valueMap[item]["value"]);
                  for (var i = 0; i < valueMap.length; i++) {
                    if (i == item) {
                      valueMap[item]["color"] = widget.activeItemTextColor;
                      valueMap[item]["fontSize"] = 15.0;
                      valueMap[item]["hasBorders"] = true; //*DARIO* currently "hasBorders" attribute is ignored
                    } else {
                      valueMap[i]["color"] = widget.passiveItemsTextColor;
                      valueMap[i]["fontSize"] = 14.0;
                      valueMap[i]["hasBorders"] = false;
                    }
                  }
                  setState(() {});
                },
                children: valueMap.map((Map curValue) {
                  return ItemWidget(
                    curValue,
                    widget.backgroundColor,
                    widget.suffix,
                  );
                }).toList()),
          ),
          Visibility( //*DARIO* visibility modifier to make the cursor optional
            visible: widget.showCursor,
            child: Container(
              alignment: Alignment.center, //put it at the center
              padding: const EdgeInsets.all(5), //*DARIO* this padding define how close to top and bottom border the cursor get
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10), //*DARIO* this is the radius at the top and bottom of the cursor: it is almost invisible
                  ),
                  color: widget.cursorColor.withOpacity(0.3), //*dario* make the cursor semi-transparent
                ),
                width: 3, //*DARIO* this is the width of the cursor
              ),
            ),
          )
        ],
      ),
    );
  }
}
