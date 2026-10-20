//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#pragma once

#include "GUIComponent.h"
#include "HookTable.h"

namespace SGG {

class GUIComponentButton : public GUIComponent {
  public:
    void UseDefaultText() {
        reinterpret_cast<void (*)(void *)>(HookTable::Instance().GUIComponentButton_UseDefaultText)(this);
    }

  private:
    char pad[0x98];
};
static_assert(sizeof(GUIComponentButton) == 0xA88, "Incorrect SGG::GUIComponentButton size");
} // namespace SGG
