//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#pragma once

#include "HookTable.h"

namespace SGG {
class GUIComponentButton;
class GUIComponentTextBox;

class GUIComponentReflectionHelper {
public:
    void ReflectComponent(const char *name, GUIComponentButton *component) {
        reinterpret_cast<void (*)(void *, const char *, GUIComponentButton *)>(
            HookTable::Instance().GUIComponentReflectionHelper_ReflectComponent_GUIComponentButton)(this, name,
                                                                                                    component);
    }

    void ReflectComponent(const char *name, GUIComponentTextBox *component) {
        reinterpret_cast<void (*)(void *, const char *, GUIComponentTextBox *)>(
            HookTable::Instance().GUIComponentReflectionHelper_ReflectComponent_GUIComponentTextBox)(this, name,
                                                                                                    component);
    }


  private:
    char pad[0x48];
};
static_assert(sizeof(GUIComponentReflectionHelper) == 0x48, "Incorrect SGG::GUIComponentReflectionHelper size");
} // namespace SGG
