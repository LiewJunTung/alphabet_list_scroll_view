import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:vibration/vibration.dart';

class AlphabetListScrollView extends StatefulWidget {
  final List<String> strList;
  final IndexedWidgetBuilder itemBuilder;
  final TextStyle highlightTextStyle;
  final TextStyle normalTextStyle;
  final bool showPreview;

  const AlphabetListScrollView({
    Key key,
    @required this.strList,
    this.itemBuilder,
    this.highlightTextStyle = const TextStyle(color: Colors.red),
    this.normalTextStyle = const TextStyle(color: Colors.black),
    this.showPreview = false,
  }) : super(key: key);

  @override
  _AlphabetListScrollViewState createState() => _AlphabetListScrollViewState();
}

class _AlphabetListScrollViewState extends State<AlphabetListScrollView> {
  List<String> alphabetList = [];

  var controller = AutoScrollController();
  VoidCallback _callback;
  GlobalKey _mainKey = GlobalKey();
  GlobalKey _sideKey = GlobalKey();
  double alphabetHeight = 0;
  double sideHeight = 0;
  int selectedIndex = 0;
  Map<String, int> strMap = {};
  int savedIndex = 0;
  bool isXFlag = false;
  Timer _debounce;
  bool _visible = false;

  @override
  void initState() {
    _initList();
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    super.initState();
    _callback = () {
      if (isXFlag) {
        return;
      }
      var pixels = controller.position.pixels;
      var tempSelectedIndex = ((pixels / controller.position.maxScrollExtent) *
              widget.strList.length)
          .toInt();
      if (tempSelectedIndex >= 0 && tempSelectedIndex < widget.strList.length) {
        var mapKey = widget.strList[tempSelectedIndex][0].toUpperCase();

        setState(() {
          selectedIndex = alphabetList.indexOf(mapKey);
        });
      }
      isXFlag = false;
    };
    controller.addListener(_callback);
  }

  _afterLayout(_) {
    _getSizes();
    _getSideSizes();
  }

  _initList() {
    String currentAlphabet = "";
    var tempList = widget.strList;
    tempList.sort();
    tempList.sort((a, b) {
      if (a.codeUnitAt(0) < 65 ||
          a.codeUnitAt(0) > 122 &&
              b.codeUnitAt(0) >= 65 &&
              b.codeUnitAt(0) <= 122) {
        return 1;
      } else if (b.codeUnitAt(0) < 65 ||
          b.codeUnitAt(0) > 122 &&
              a.codeUnitAt(0) >= 65 &&
              a.codeUnitAt(0) <= 122) {
        return -1;
      }
      return a.compareTo(b);
    });
    for (var i = 0; i < tempList.length; i++) {
      var currentStr = tempList[i][0];
      if (currentStr.codeUnitAt(0) < 65 || currentStr.codeUnitAt(0) > 122) {
        strMap["#"] = i;
        alphabetList.add("#");
        currentAlphabet = "#";
        break;
      } else if (currentAlphabet != currentStr) {
        strMap[currentStr] = i;
        alphabetList.add(currentStr);
        currentAlphabet = currentStr;
      }
    }
  }

  _getSideSizes() {
    final RenderBox renderBoxRed = _sideKey.currentContext.findRenderObject();
    final sizeRed = renderBoxRed.size;
    sideHeight = sizeRed.height;
  }

  _getSizes() {
    final RenderBox renderBoxRed = _mainKey.currentContext.findRenderObject();
    final sizeRed = renderBoxRed.size;
    alphabetHeight = sizeRed.height;
  }

  _currentWidgetIndex(double position) {
    var tempPosition = position;
    if (position >= sideHeight) {
      tempPosition = sideHeight;
    } else if (position <= 1) {
      tempPosition = 0;
    }
    var tempHeight = tempPosition / sideHeight;
    var tempIndex = tempHeight * alphabetList.length;

    if (tempIndex >= alphabetList.length - 1) {
      tempIndex = (alphabetList.length - 1).toDouble();
    }
    setState(() {
      selectedIndex = tempIndex.round();
    });

    if (savedIndex != selectedIndex) {
      savedIndex = selectedIndex;
      _select(selectedIndex);

      if (_debounce?.isActive ?? false) _debounce.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        setState(() {
          _visible = false;
        });
      });
      setState(() {
        _visible = true;
      });
    }
  }

  _select(int index) async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 20);
    }
    controller.scrollToIndex(
      strMap[alphabetList[index]],
      duration: Duration(milliseconds: 1),
    );
  }

  @override
  void dispose() {
    super.dispose();
    controller.removeListener(_callback);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          ListView.builder(
            key: _mainKey,
            controller: controller,
            itemCount: widget.strList.length,
            itemBuilder: (context, index) {
              return AutoScrollTag(
                key: ValueKey(widget.strList[index]),
                controller: controller,
                index: index,
                child: Container(
                  child: widget.itemBuilder(context, index),
                ),
              );
            },
          ),
          if (widget.showPreview)
            AnimatedOpacity(
              opacity: _visible ? 1.0 : 0.0,
              duration: Duration(milliseconds: 500),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  child: Container(
                    width: 160,
                    height: 160,
                    color: Colors.black54,
                    child: Center(
                        child: Text(
                          selectedIndex >= 0
                              ? "${alphabetList[selectedIndex]}"
                              : "",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 60,
                          ),
                        )),
                  ),
                ),
              ),
            ),
          _AlphabetListScollView(
            insideKey: _sideKey,
            strList: alphabetList,
            selectedIndex: selectedIndex,
            positionCallback: (position) {
              _currentWidgetIndex(position);
            },
            highlightTextStyle: widget.highlightTextStyle,
            normalTextStyle: widget.normalTextStyle,
          ),
        ],
      ),
    );
  }
}

typedef AlphabetCallback = Function(int, String);
typedef DoubleCallback = Function(double);

class _AlphabetListScollView extends StatefulWidget {
  final AlphabetCallback callback;
  final DoubleCallback positionCallback;
  final List<String> strList;
  final Widget child;
  final int selectedIndex;
  final GlobalKey insideKey;
  final TextStyle highlightTextStyle;
  final TextStyle normalTextStyle;

  const _AlphabetListScollView({
    Key key,
    this.callback,
    this.strList,
    this.child,
    this.selectedIndex,
    this.positionCallback,
    this.insideKey,
    this.highlightTextStyle = const TextStyle(color: Colors.red),
    this.normalTextStyle = const TextStyle(color: Colors.black),
  }) : super(key: key);

  @override
  _AlphabetListScollViewState createState() => _AlphabetListScollViewState();
}

class _AlphabetListScollViewState extends State<_AlphabetListScollView> {
  int savedIndex = 0;
  double alphabetHeight = 0;
  Map<String, int> strMap = {};

  @override
  void initState() {
    super.initState();
  }

  List<Widget> aToZ() {
    List<Widget> charList = [];

    for (var x = 0; x < widget.strList.length; x++) {
      charList.add(Padding(
        padding: const EdgeInsets.all(2.0),
        child: Text(
          widget.strList[x],
          textAlign: TextAlign.justify,
          style: widget.selectedIndex == x
              ? widget.highlightTextStyle
              : widget.normalTextStyle,
        ),
      ));
    }
    return charList;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Center(
          child: GestureDetector(
            onPanStart: (details) {
              widget.positionCallback(details.localPosition.dy);
            },
            onPanUpdate: (details) {
              widget.positionCallback(details.localPosition.dy);
            },
            onTapDown: (details) {
              widget.positionCallback(details.localPosition.dy);
            },
            child: Container(
              color: Colors.transparent,
              key: widget.insideKey,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: aToZ(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
