#import "GeoformPlugin.h"
#if __has_include(<geoform/geoform-Swift.h>)
#import <geoform/geoform-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "geoform-Swift.h"
#endif

@implementation GeoformPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftGeoformPlugin registerWithRegistrar:registrar];
}
@end
