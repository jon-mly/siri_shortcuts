#import "SiriShortcutsPlugin.h"
#if __has_include(<siri_shortcuts/siri_shortcuts-Swift.h>)
#import <siri_shortcuts/siri_shortcuts-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "siri_shortcuts-Swift.h"
#endif

@implementation SiriShortcutsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    if (@available(iOS 12.0, *)) {
        [SwiftSiriShortcutsPlugin registerWithRegistrar:registrar];
    } else {
        // Fallback on earlier versions
    }
}
@end
