import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alphabet_list_scroll_view/alphabet_list_scroll_view.dart';

void main() {
  const MethodChannel channel = MethodChannel('alphabet_list_scroll_view');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

//  test('getPlatformVersion', () async {
//    expect(await AlphabetListScrollView.platformVersion, '42');
//  });
}
