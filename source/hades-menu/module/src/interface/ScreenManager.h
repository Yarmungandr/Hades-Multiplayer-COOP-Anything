//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#pragma once

#include "HookTable.h"

namespace SGG {
class GameScreen;

class ScreenManager {
  public:
    void AddScreen(GameScreen *screen) {
        reinterpret_cast<void(__fastcall *)(void *, GameScreen *)>(
            HookTable::Instance().ScreenManager_AddScreen_screen)(this, screen);
    }

  private:
    char pad_0[0x1D0];
};

static_assert(sizeof(ScreenManager) == 0x1D0, "Incorrect SGG::ScreenManager size");
} // namespace SGG
