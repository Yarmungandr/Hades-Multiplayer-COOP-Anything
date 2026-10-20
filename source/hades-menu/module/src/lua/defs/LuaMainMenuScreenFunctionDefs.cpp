//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#include "pch.h"

#include "LuaMainMenuScreenFunctionDefs.h"

#include "lua/lua.hpp"

#include "LibraryComponents.h"

// MainMenuOpenProfiles()
static int MainMenuOpenProfiles(lua_State *L) {
    auto* menu = LibraryComponents::Instance()->GetMenuHandler()->GetMainMenu();
    if (!menu) {
        lua_pushboolean(L, false);
        return 1;
    }

    menu->OpenProfiles();
    lua_pushboolean(L, true);
    return 1;
}

void LuaMainMenuScreenFunctionDefs::Load(lua_State *L) {
#define REGISTER(fun) lua_register(L, #fun, fun)

    REGISTER(MainMenuOpenProfiles);

#undef REGISTER
}
