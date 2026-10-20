//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#pragma once

#include "lua/helpers/LuaClass.h"
#include "interface/GuiComponentTextBox.h"
#include "GuiComponentUserData.h"

class GuiComponentTextBoxUserData : public LuaClassWrapper<SGG::GUIComponentTextBox> {
  public:
    using Parent = GuiComponentUserData;
    static constexpr const char *LuaClassMeta = "MainMenuApi.GUIComponentTextBox";
    static constexpr const char *LuaClassName = "GUIComponentTextBox";
};
