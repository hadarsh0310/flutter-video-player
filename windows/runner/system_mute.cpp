
#include "system_mute.h"

#include <windows.h>
#include <mmdeviceapi.h>
#include <endpointvolume.h>
#include <wrl/client.h>

using Microsoft::WRL::ComPtr;

void RegisterSystemMuteChannel(
    flutter::BinaryMessenger* messenger) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          messenger,
          "video_player/system_mute",
          &flutter::StandardMethodCodec::GetInstance());

  channel->SetMethodCallHandler(
      [](const auto& call, auto result) {
        if (call.method_name() != "setMute") {
          result->NotImplemented();
          return;
        }

        const auto* arguments =
            std::get_if<flutter::EncodableMap>(call.arguments());

        if (arguments == nullptr) {
          result->Error("INVALID_ARGUMENT", "Expected a map.");
          return;
        }

        const auto it = arguments->find(
            flutter::EncodableValue("muted"));

        if (it == arguments->end() ||
            !std::holds_alternative<bool>(it->second)) {
          result->Error("INVALID_ARGUMENT", "Expected a boolean 'muted'.");
          return;
        }

        const bool muted = std::get<bool>(it->second);

        const HRESULT init_result =
            CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

        if (FAILED(init_result) && init_result != RPC_E_CHANGED_MODE) {
          result->Error("COM_ERROR", "Could not initialize Windows audio.");
          return;
        }

        ComPtr<IMMDeviceEnumerator> enumerator;
        ComPtr<IMMDevice> device;
        ComPtr<IAudioEndpointVolume> endpoint;

        HRESULT hr = CoCreateInstance(
            __uuidof(MMDeviceEnumerator),
            nullptr,
            CLSCTX_ALL,
            IID_PPV_ARGS(&enumerator));

        if (SUCCEEDED(hr)) {
          hr = enumerator->GetDefaultAudioEndpoint(
              eRender, eMultimedia, &device);
        }

        if (SUCCEEDED(hr)) {
          hr = device->Activate(
              __uuidof(IAudioEndpointVolume),
              CLSCTX_ALL,
              nullptr,
              reinterpret_cast<void**>(endpoint.GetAddressOf()));
        }

        if (SUCCEEDED(hr)) {
          hr = endpoint->SetMute(muted, nullptr);
        }

        if (SUCCEEDED(init_result)) {
          CoUninitialize();
        }

        if (FAILED(hr)) {
          result->Error("AUDIO_ERROR", "Could not change Windows mute state.");
          return;
        }

        result->Success();
      });
}
