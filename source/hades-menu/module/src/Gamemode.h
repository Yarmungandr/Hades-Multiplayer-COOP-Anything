//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#pragma once

#include "lua/helpers/LuaCallback.h"

class Gamemode {
  public:
    Gamemode(const char* name, const LuaCallback &callback) : name(name), callback(callback) {}
    ~Gamemode() = default;

    Gamemode(const Gamemode &other) : name(other.name), callback(other.callback) {}

    Gamemode(Gamemode &&other) noexcept : name(std::move(other.name)), callback(std::move(other.callback)) {}

    Gamemode &operator=(const Gamemode &other) {
        if (this != &other) {
            name = other.name;
            callback = other.callback;
        }
        return *this;
    }

    Gamemode &operator=(Gamemode &&other) noexcept {
        if (this != &other) {
            name = std::move(other.name);
            callback = std::move(other.callback);
        }
        return *this;
    }

    const std::string &GetName() const noexcept { return name; };
    void Activate() const;

  private:
    std::string name;
    LuaCallback callback;
};
