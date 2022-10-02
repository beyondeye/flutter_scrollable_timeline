import 'package:flutter/material.dart';

class ItemWidget extends StatefulWidget {
  //*DARIO* data used to customize the item:
  // "value","fontSize","color" in original code
  //TODO this is very inefficient, although it is very flexible
  final Map curItem;
  // *DARIO* potentially independent bg color for each item
  final Color backgroundColor;

  const ItemWidget(
    this.curItem,
    this.backgroundColor,
  {
    Key? key,
  }) : super(key: key);

  @override
  _ItemWidgetState createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  late String minsText, secsText;

  @override
  void initState() {
    super.initState();

    //*DARIO* TODO *IMPORTANT* this code here must be modified in order to customize how
    //        value is translated to actual text to shoiw
    secsText = widget.curItem["value_s"].toString();
    minsText = widget.curItem["value_m"].toString();
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 1,
        ),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: RotatedBox( //*DARIO* this is needed because we rotate ListWheelScrollView to make it horizontal
          quarterTurns: 1,
          child: Column( //*DARIO* we have a column here!
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "|", //*DARIO* this is the top alignment line
                style: TextStyle(fontSize: 8, color: widget.curItem["color"]),
              ),
              const SizedBox(height: 5),
              RichText( //*DARIO* this is the main text  label for this element
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: minsText,
                      style: TextStyle(
                          fontSize: widget.curItem["fontSize"],
                          color: widget.curItem["color"],
                          fontWeight: secsText == "0"
                              ? FontWeight.w800
                              : FontWeight.w400),
                    ),
                  ],
                ),
              ),
              RichText( //*DARIO* this is the main text  label for this element
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: secsText,
                      style: TextStyle(
                          fontSize: widget.curItem["fontSize"],
                          color: widget.curItem["color"]),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "|",
                style: TextStyle(fontSize: 8, color: widget.curItem["color"]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
