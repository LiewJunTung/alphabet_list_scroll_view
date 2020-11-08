### Apologize for the lack of updates as I do not have the bandwidth to work on this. But please check out this project https://github.com/flutterchina/azlistview if you need an A-Z list view that have more updates.

# Alphabet List Scroll View
A customizable listview with A-Z side scrollbar to fast jump to the item of the selected character.
Quick scroll through list via dragging through alphabets. 

## API
| name | type | default | description |
| --- | --- | --- | --- |
| strList | List<String> | -  | List of Strings |
| itemBuilder | itemBuilder(context, index) | - | itemBuilder similar to itemBuilder in ListView.builder |
| highlightTextStyle | bool | false | highlight the focused pin box. |
| normalTextStyle | Color | Colors.black | Set color of the focused pin box. |
| showPreview | bool | true | show preview on screen |
| keyboardUsage | bool | true | The alphabet list will be wrapped in scrollview. |
| indexedHeight | double Function(int) | query the height of widget with index |  |
| headerWidgetList | List<AlphabetScrollListHeader> | headers |  |

### AlphabetScrollListHeader
| name | type | default | description|
| ---- | ---- | ------- | ---------- |
| widgetList | List<Widget> | [] |   |
| icon | Icon | | Icon shows in the side alphabet list and the preview|
| indexedHeaderHeight| double Function(int) | | query the height of header with index |

<img src="https://github.com/LiewJunTung/alphabet_list_scroll_view/blob/master/images/device-2019-10-06-171039.png?raw=true" alt="drawing" width="300"/>

---
<img src="https://github.com/LiewJunTung/alphabet_list_scroll_view/blob/master/images/preview1.gif?raw=true" alt="drawing" width="300"/>

