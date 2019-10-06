#import "AlphabetListScrollViewPlugin.h"
#import <alphabet_list_scroll_view/alphabet_list_scroll_view-Swift.h>

@implementation AlphabetListScrollViewPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAlphabetListScrollViewPlugin registerWithRegistrar:registrar];
}
@end
