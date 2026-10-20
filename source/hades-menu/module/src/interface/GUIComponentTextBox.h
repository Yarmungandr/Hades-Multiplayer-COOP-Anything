//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#pragma once

#include "GUIComponent.h"

namespace SGG {

class GUIComponentTextBox : public GUIComponent {
  private:
    char pad[0x2F0];
};
static_assert(sizeof(GUIComponentTextBox) == 0xCE0, "Incorrect SGG::GUIComponentTextBox size");
} // namespace SGG
