#import "FoundationModelsFrameworkPlugin.h"
#if __has_include(<foundation_models_framework/foundation_models_framework-Swift.h>)
#import <foundation_models_framework/foundation_models_framework-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "foundation_models_framework-Swift.h"
#endif

@implementation FoundationModelsFrameworkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFoundationModelsFrameworkPlugin registerWithRegistrar:registrar];
}
@end 