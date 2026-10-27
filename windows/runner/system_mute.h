#ifndef RUNNER_SYSTEM_MUTE_H_
#define RUNNER_SYSTEM_MUTE_H_

#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include <memory>

void RegisterSystemMuteChannel(
    flutter::BinaryMessenger* messenger);

#endif  // RUNNER_SYSTEM_MUTE_H_