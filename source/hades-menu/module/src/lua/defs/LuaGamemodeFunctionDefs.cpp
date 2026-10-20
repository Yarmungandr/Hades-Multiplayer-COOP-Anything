//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#include "pch.h"
#include "LuaGamemodeFunctionDefs.h"

#include "GamemodeManager.h"
#include "lua/helpers/LuaCallback.h"
#include "lua/lua.hpp"

// string MainMenuAPIGetSelectedGamemode()
static int MainMenuAPIGetSelectedGamemode(lua_State *L) {
    const Gamemode* gamemode = GamemodeManager::Instance().GetCurrentGamemode();
    if (gamemode)
        lua_pushstring(L, gamemode->GetName().c_str());
    else
        lua_pushnil(L);

    return 1;
}

// MainMenuAPIAddGamemode(string name, function onSelected)
static int MainMenuAPIAddGamemode(lua_State *L) {
    if (!lua_isstring(L, 1)) {
        return luaL_error(L, "Argument 1 must be a string");
    }

    if (!lua_isfunction(L, 2)) {
        return luaL_error(L, "Argument 2 must be a function");
    }

    const char *name = lua_tostring(L, 1);
    LuaCallback cb{L, 2};

    GamemodeManager::Instance().AddGamemode(name, cb);
    return 0;
}

void LuaGamemodeFunctionDefs::Load(lua_State* L) {
    #define REGISTER(fun) lua_register(L, #fun, fun)

    REGISTER(MainMenuAPIGetSelectedGamemode);
    REGISTER(MainMenuAPIAddGamemode);

    #undef REGISTER
}
