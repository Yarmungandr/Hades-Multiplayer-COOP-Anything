//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#pragma once

#include "lua/helpers/LuaClass.h"
#include "interface/GuiComponentButton.h"
#include "GuiComponentUserData.h"

class GuiComponentButtonUserData : public LuaClassWrapper<SGG::GUIComponentButton> {
  public:
    using Parent = GuiComponentUserData;
    static constexpr const char *LuaClassMeta = "MainMenuApi.GUIComponentButton";
    static constexpr const char *LuaClassName = "GUIComponentButton";
};
