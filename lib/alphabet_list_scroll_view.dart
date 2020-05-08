import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

typedef IndexedHeight = double Function(int);

class AlphabetScrollListHeader {
  AlphabetScrollListHeader(
      {@required this.widgetList,
        @required this.icon,
        @required this.indexedHeaderHeight});

  final List<Widget> widgetList;
  final Icon icon;
  final IndexedHeight indexedHeaderHeight;
}

class _SpecialHeaderAlphabet {
  _SpecialHeaderAlphabet(this.id, this.icon);

  final String id;
  final Icon icon;
}

class AlphabetListScrollView extends StatefulWidget {
  const AlphabetListScrollView(
      {Key key,
        @required this.strList,
        this.itemBuilder,
        this.highlightTextStyle = const TextStyle(color: Colors.red),
        this.normalTextStyle = const TextStyle(color: Colors.black),
        this.showPreview = false,
        this.headerWidgetList = const <AlphabetScrollListHeader>[],
        @required this.indexedHeight,
        this.keyboardUsage = false})
      : super(key: key);

  final List<String> strList;
  final IndexedHeight indexedHeight;
  final IndexedWidgetBuilder itemBuilder;
  final TextStyle highlightTextStyle;
  final TextStyle normalTextStyle;
  final bool showPreview;
  final bool keyboardUsage;
  final List<AlphabetScrollListHeader> headerWidgetList;

  @override
  _AlphabetListScrollViewState createState() => _AlphabetListScrollViewState();
}

class _AlphabetListScrollViewState extends State<AlphabetListScrollView> {
  List<String> alphabetList = <String>[];

  ScrollController controller = ScrollController();
  VoidCallback _callback;
  final GlobalKey _screenKey = GlobalKey();
  final GlobalKey _mainKey = GlobalKey();
  final GlobalKey _sideKey = GlobalKey();
  double screenHeight = 0;
  double sideHeight = 0;
  int selectedIndex = 0;
  String selectedChar = 'A';
  Map<String, int> strMap = <String, int>{};
  Map<String, double> heightMap = <String, double>{};
  int savedIndex = 0;
  bool isXFlag = false;
  Timer _debounce;
  bool _visible = false;
  final StreamController<double> _pixelUpdates = StreamController<double>();
  double totalHeight = 0.0;
  List<double> heightList = <double>[];
  double maxLimit = 0;
  List<_SpecialHeaderAlphabet> specialList = <_SpecialHeaderAlphabet>[];

  List<String> strList = <String>[];

  void _initScrollCallback() => _pixelUpdates.stream.listen((double pixels) {
    final int childLength = strList.length;
    final double maxScrollExtent = controller.position.maxScrollExtent > 0
        ? controller.position.maxScrollExtent
        : 1;
    int tempSelectedIndex =
    ((pixels / maxScrollExtent) * childLength).toInt();
    if (tempSelectedIndex >= childLength) {
      tempSelectedIndex = childLength - 1;
    }
    String mapKey;
    if (tempSelectedIndex < 0 || tempSelectedIndex >= strList.length) {
      return;
    }
    if (strList[tempSelectedIndex].contains(RegExp('^x\\d\$'))) {
      mapKey = strList[tempSelectedIndex];
    } else {
      mapKey = strList[tempSelectedIndex][0].toUpperCase();
    }

    if (tempSelectedIndex != selectedIndex && selectedChar != mapKey) {
      final int tempIndex = alphabetList.indexOf(mapKey);

      if (tempIndex != -1) {
        setState(() {
          selectedIndex = tempIndex;
          selectedChar = mapKey;
        });
      }
    }
  });

  @override
  void initState() {
    _initList();
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    super.initState();
    _updateStrList();
    _initScrollCallback();
    _callback = () {
      _pixelUpdates.add(controller.position.pixels);
    };
    controller.addListener(_callback);
  }

  void _updateStrList() {
    strList = <String>[];
    for (int i = 0; i < widget.headerWidgetList.length; i++) {
      final AlphabetScrollListHeader header = widget.headerWidgetList[i];
      for (int j = 0; j < header.widgetList.length; j++) {
        strList.add('x$i');
      }
    }
    strList.addAll(widget.strList);
  }

  @override
  void didUpdateWidget(AlphabetListScrollView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initList();
    _updateHeightMap();
    _updateStrList();
  }

  void _updateHeightMap() {
    double maxLimit;
    if (totalHeight - screenHeight > 0) {
      maxLimit = totalHeight - screenHeight;
    } else {
      maxLimit = 0;
    }
    heightMap.forEach((String k, double v) {
      if (v > maxLimit) {
        heightMap[k] = maxLimit;
      }
    });
  }

  void _afterLayout(dynamic _) {
    _getScreenHeight();
    _getSideSizes();
    _updateHeightMap();
  }

  void _initList() {
    alphabetList = <String>[];
    final List<String> tempList = widget.strList;
    tempList.sort();
    tempList.sort((String a, String b) {
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
    if (widget.headerWidgetList.isNotEmpty) {
      totalHeight = 0;
      for (int i = 0; i < widget.headerWidgetList.length; i++) {
        final AlphabetScrollListHeader header = widget.headerWidgetList[i];
        final String id = 'x$i';
        alphabetList.add(id);
        heightMap[id] = totalHeight;
        specialList.add(_SpecialHeaderAlphabet(id, header.icon));
        double headerHeight = 0;
        for (int j = 0; j < header.widgetList.length; j++) {
          headerHeight += header.indexedHeaderHeight(j);
        }
        totalHeight += headerHeight;
      }
    }
    for (int i = 0; i < tempList.length; i++) {
      final String currentStr = tempList[i][0];
      _initAlphabetMap(currentStr, i);
    }
  }

  String _currentAlphabet = '';

  void _initAlphabetMap(String currentStr, int i) {
    final double currentHeight = widget.indexedHeight(i);
    if (_currentAlphabet == '#') {
      return;
    }

    if (currentStr.codeUnitAt(0) < 65 || currentStr.codeUnitAt(0) > 122) {
      strMap['#'] = i;
      alphabetList.add('#');
      _currentAlphabet = '#';
      heightMap['#'] = totalHeight;
    } else if (_currentAlphabet != currentStr) {
      strMap[currentStr] = i;
      alphabetList.add(currentStr);
      _currentAlphabet = currentStr;
      heightMap[currentStr] = totalHeight;
    }
    totalHeight += currentHeight;
  }

  void _getSideSizes() {
    final RenderBox renderBoxRed =
    _sideKey.currentContext.findRenderObject() as RenderBox;
    final dynamic sizeRed = renderBoxRed.size;
    sideHeight = sizeRed.height as double;
  }

  void _getScreenHeight() {
    final RenderBox renderBoxRed =
    _mainKey.currentContext.findRenderObject() as RenderBox;
    final dynamic sizeRed = renderBoxRed.size;
    screenHeight = sizeRed.height as double;
  }

  void _currentWidgetIndex(double position) {
    double tempPosition = position;
    if (position >= sideHeight) {
      tempPosition = sideHeight;
    } else if (position <= 1) {
      tempPosition = 0;
    }
    final double tempHeight = tempPosition / sideHeight;
    double tempIndex = tempHeight * alphabetList.length;

    if (tempIndex >= alphabetList.length - 1) {
      tempIndex = (alphabetList.length - 1).toDouble();
    }

    setState(() {
      selectedIndex = tempIndex.round();
    });

    if (savedIndex != selectedIndex) {
      savedIndex = selectedIndex;
      _select(selectedIndex);

      if (_debounce?.isActive ?? false) {
        _debounce.cancel();
      }
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

  Future<void> _select(int index) async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 20);
    }
    final double height = heightMap[alphabetList[index]];
    controller.jumpTo(height);
//    controller.scrollToIndex(
//      strMap[alphabetList[index]],
//      duration: Duration(milliseconds: 1),
//    );
  }

  @override
  void dispose() {
    super.dispose();
    controller.removeListener(_callback);
  }

  List<SliverList> _headerWidgetList() {
    final List<SliverList> sliverList = <SliverList>[];
    for (int i = 0; i < widget.headerWidgetList.length; i++) {
      final AlphabetScrollListHeader headerWidget = widget.headerWidgetList[i];
      final List<Widget> widgetList = <Widget>[];
      for (int j = 0; j < headerWidget.widgetList.length; j++) {
        widgetList.add(Container(
          height: headerWidget.indexedHeaderHeight(j),
          child: headerWidget.widgetList[j],
        ));
      }
      sliverList.add(SliverList(
        delegate: SliverChildListDelegate(<Widget>[
          ...widgetList,
        ]),
      ));
    }
    return sliverList;
  }

  @override
  Widget build(BuildContext context) {
    Widget textView;
    if (selectedIndex >= 0 && selectedIndex < alphabetList.length) {
      if (alphabetList[selectedIndex].length > 1) {
        final _SpecialHeaderAlphabet header = specialList.firstWhere(
                (_SpecialHeaderAlphabet sp) =>
            sp.id == alphabetList[selectedIndex]);
        textView = IconTheme(
          data: IconThemeData(
            color: Colors.white,
            size: 42,
          ),
          child: header.icon,
        );
      } else {
        textView = Text(
          alphabetList[selectedIndex],
          style: TextStyle(
            color: Colors.white,
            fontSize: 60,
          ),
        );
      }
    } else {
      textView = const Text('');
    }
    return Container(
      key: _screenKey,
      child: Stack(
        children: <Widget>[
          CustomScrollView(
            key: _mainKey,
            controller: controller,
            slivers: <Widget>[
              ..._headerWidgetList(),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                      final int currentIndex = index;
                      return Container(
                        height: widget.indexedHeight(index),
                        child: widget.itemBuilder(context, currentIndex),
                      );
                    }, childCount: widget.strList.length),
              )
            ],
          ),
          if (widget.showPreview)
            IgnorePointer(
              child: AnimatedOpacity(
                opacity: _visible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Center(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(30)),
                    child: Container(
                      width: 160,
                      height: 160,
                      color: Colors.black54,
                      child: Center(child: textView),
                    ),
                  ),
                ),
              ),
            ),
          _AlphabetListScollView(
            insideKey: _sideKey,
            specialHeader: widget.headerWidgetList.isNotEmpty,
            specialList: specialList,
            strList: alphabetList,
            selectedIndex: selectedIndex,
            keyboardUsage: widget.keyboardUsage,
            positionCallback: (double position) {
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
    this.specialHeader = false,
    this.specialList = const <_SpecialHeaderAlphabet>[],
    this.keyboardUsage,
  }) : super(key: key);

  final AlphabetCallback callback;
  final DoubleCallback positionCallback;
  final List<String> strList;
  final Widget child;
  final int selectedIndex;
  final GlobalKey insideKey;
  final TextStyle highlightTextStyle;
  final TextStyle normalTextStyle;
  final bool specialHeader;
  final List<_SpecialHeaderAlphabet> specialList;
  final bool keyboardUsage;

  @override
  _AlphabetListScollViewState createState() => _AlphabetListScollViewState();
}

class _AlphabetListScollViewState extends State<_AlphabetListScollView> {
  int savedIndex = 0;
  double alphabetHeight = 0;
  Map<String, int> strMap = <String, int>{};

  @override
  void initState() {
    super.initState();
  }

  List<Widget> aToZ() {
    final List<Widget> charList = <Padding>[];

    for (int x = 0; x < widget.strList.length; x++) {
      Widget textView;

      if (widget.strList[x].length > 1) {
        final _SpecialHeaderAlphabet header = widget.specialList.firstWhere(
                (_SpecialHeaderAlphabet sp) => sp.id == widget.strList[x]);
        textView = IconTheme(
          data: IconThemeData(
            size: 18,
            color: widget.selectedIndex == x
                ? widget.highlightTextStyle.color
                : widget.normalTextStyle.color,
          ),
          child: header.icon,
        );
      } else {
        textView = Text(
          widget.strList[x],
          textAlign: TextAlign.justify,
          style: widget.selectedIndex == x
              ? widget.highlightTextStyle
              : widget.normalTextStyle,
        );
      }
      charList.add(Padding(
        padding: const EdgeInsets.all(2.0),
        child: textView,
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
          child: Container(
            key: widget.insideKey,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanStart: (DragStartDetails details) {
                  widget.positionCallback(details.localPosition.dy);
                },
                onPanUpdate: (DragUpdateDetails details) {
                  widget.positionCallback(details.localPosition.dy);
                },
                onTapDown: (TapDownDetails details) {
                  widget.positionCallback(details.localPosition.dy);
                },
                child: _column(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _column() {
    if (!widget.keyboardUsage) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: aToZ(),
      );
    } else {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: aToZ(),
        ),
      );
    }
  }
}
