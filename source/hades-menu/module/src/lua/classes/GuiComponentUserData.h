//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#pragma once

#include "interface/GUIComponent.h"
#include "lua/helpers/LuaClass.h"

class GuiComponentUserData : public LuaClassWrapper<SGG::GUIComponent> {
  public:
    using Parent = void;
    static constexpr const char *LuaClassMeta = "MainMenuApi.GUIComponent";
    static constexpr const char *LuaClassName = "GUIComponent";
};
