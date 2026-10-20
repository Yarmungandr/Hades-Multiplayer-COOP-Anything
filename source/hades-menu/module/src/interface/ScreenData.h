//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#pragma once

#include "HookTable.h"

namespace SGG {
class MenuScreen;

class ScreenData {
  public:
    // This fucntion reads json
    void ReadXml(MenuScreen *menuScreen, const char *path) {
        GET_HOOK(ScreenData_ReadXml, void(__fastcall *)(void *, void *, const char *))(this, menuScreen, path);
    }

  private:
    char pad_0[0x118];
};

static_assert(sizeof(ScreenData) == 0x118, "Incorrect SGG::ScreenData size");
} // namespace SGG
