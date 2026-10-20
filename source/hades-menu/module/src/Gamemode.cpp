//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#include "pch.h"

#include "Gamemode.h"

#include "lua/lua.hpp"
#include "lua/LuaManager.h"

void Gamemode::Activate() const {
    lua_State *L = LuaManager::GetLuaState();
    callback.PushFunction(L);
    lua_pushstring(L, name.c_str());
    LuaManager::lua_pcallk(L, 1, 0, 0, 0, 0);
}
