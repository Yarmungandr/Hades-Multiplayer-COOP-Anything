//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#include "pch.h"

#include "lua/helpers/LuaCallback.h"
#include "lua/lua.hpp"

constexpr char const *szUniqueCallbackStorage = "_MainMenuAPICB";

LuaCallback::LuaCallback(lua_State *lusState, int stackIndex) {
    // Ensure the callback storage table exists in the registry
    luaL_getsubtable(lusState, LUA_REGISTRYINDEX, szUniqueCallbackStorage);

    // Get the next available index in the callback storage table
    int nextIndex = lua_rawlen(lusState, -1) + 1;

    // Push the value at stackIndex onto the callback storage table
    lua_pushvalue(lusState, stackIndex);
    lua_rawseti(lusState, -2, nextIndex);

    // Save the index for later use
    callbackIndex = nextIndex;

    // Remove the callback storage table from the stack
    lua_pop(lusState, 1);
}

void LuaCallback::PushFunction(lua_State* lusState) const {
    luaL_getsubtable(lusState, LUA_REGISTRYINDEX, szUniqueCallbackStorage);  

    lua_rawgeti(lusState, -1, callbackIndex);  

    lua_remove(lusState, -2);
}
