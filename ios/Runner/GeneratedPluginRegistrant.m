//
//  Generated file. Do not edit.
//

#import "GeneratedPluginRegistrant.h"
#import <android_alarm_manager/AndroidAlarmManagerPlugin.h>
#import <flutter_local_notifications/FlutterLocalNotificationsPlugin.h>
#import <geolocator/GeolocatorPlugin.h>
#import <google_api_availability/GoogleApiAvailabilityPlugin.h>
#import <google_maps_flutter/GoogleMapsPlugin.h>
#import <permission_handler/PermissionHandlerPlugin.h>
#import <sqflite/SqflitePlugin.h>

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [FLTAndroidAlarmManagerPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTAndroidAlarmManagerPlugin"]];
  [FlutterLocalNotificationsPlugin registerWithRegistrar:[registry registrarForPlugin:@"FlutterLocalNotificationsPlugin"]];
  [GeolocatorPlugin registerWithRegistrar:[registry registrarForPlugin:@"GeolocatorPlugin"]];
  [GoogleApiAvailabilityPlugin registerWithRegistrar:[registry registrarForPlugin:@"GoogleApiAvailabilityPlugin"]];
  [FLTGoogleMapsPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTGoogleMapsPlugin"]];
  [PermissionHandlerPlugin registerWithRegistrar:[registry registrarForPlugin:@"PermissionHandlerPlugin"]];
  [SqflitePlugin registerWithRegistrar:[registry registrarForPlugin:@"SqflitePlugin"]];
}

@end
