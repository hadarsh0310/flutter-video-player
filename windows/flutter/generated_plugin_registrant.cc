//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <device_volume/device_volume_plugin_c_api.h>
#include <flutter_video_thumbnail_plus/flutter_video_thumbnail_plus_plugin_c_api.h>
#include <media_kit_libs_windows_video/media_kit_libs_windows_video_plugin_c_api.h>
#include <media_kit_video/media_kit_video_plugin_c_api.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  DeviceVolumePluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("DeviceVolumePluginCApi"));
  FlutterVideoThumbnailPlusPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterVideoThumbnailPlusPluginCApi"));
  MediaKitLibsWindowsVideoPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("MediaKitLibsWindowsVideoPluginCApi"));
  MediaKitVideoPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("MediaKitVideoPluginCApi"));
}
