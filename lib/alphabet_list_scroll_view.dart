
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:scroll_to_index/scroll_to_index.dart';


class AlphabetList extends StatefulWidget {
  final List<String> strList;
  final IndexedWidgetBuilder itemBuilder;

  const AlphabetList({Key key, this.strList, this.itemBuilder}) : super(key: key);

  @override
  _AlphabetListState createState() => _AlphabetListState();
}

class _AlphabetListState extends State<AlphabetList> {
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
      if (tempSelectedIndex < widget.strList.length) {
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
    for (var i = 0; i < tempList.length; i++) {
      var currentStr = tempList[i][0];
      if (currentAlphabet != currentStr) {
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
          _AlphabetListScollView(
            insideKey: _sideKey,
            strList: alphabetList,
            selectedIndex: selectedIndex,
            doubleCallback: (position) {
              _currentWidgetIndex(position);
            },
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
  final DoubleCallback doubleCallback;
  final List<String> strList;
  final Widget child;
  final int selectedIndex;
  final GlobalKey insideKey;

  const _AlphabetListScollView({
    Key key,
    this.callback,
    this.strList,
    this.child,
    this.selectedIndex,
    this.doubleCallback,
    this.insideKey,
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
          style: TextStyle(
            color: widget.selectedIndex == x ? Colors.red : Colors.black,
            fontWeight:
            widget.selectedIndex == x ? FontWeight.bold : FontWeight.normal,
          ),
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
              widget.doubleCallback(details.localPosition.dy);
            },
            onPanUpdate: (details) {
              widget.doubleCallback(details.localPosition.dy);
            },
            onTapDown: (details) {
              widget.doubleCallback(details.localPosition.dy);
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
