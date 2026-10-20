//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#pragma once

#include <vector>
#include "lua/helpers/LuaCallback.h"
#include "Gamemode.h"

class GamemodeManager {
  public:
    GamemodeManager() = default;

    static GamemodeManager &Instance();

    void AddGamemode(const char *name, LuaCallback callback) { gamemodes.emplace_back(Gamemode{name, callback}); };

    void Reset() noexcept {
        selectedGamemode = nullptr;
        gamemodes.clear();
    }

    const Gamemode *GetCurrentGamemode() const noexcept { return selectedGamemode; };

    const auto &GetGamemodes() const noexcept { return gamemodes; };
    auto &GetGamemodes() noexcept { return gamemodes; };

  private:
    Gamemode* selectedGamemode{};
    std::vector<Gamemode> gamemodes{};
};
