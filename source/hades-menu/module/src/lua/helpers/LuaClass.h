//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#pragma once

#include <type_traits>
#include "lua/lua.hpp"

template <class T> class LuaClassWrapper {
  public:
    using GameType = T;

    void Set(T *data) noexcept { pointer = data; }
    T *Get() const noexcept { return pointer; }

  private:
    T *pointer;
};

template <class T, class GameType = T::GameType> static T *NewUserData(lua_State *L, GameType pointer) {
    auto *userdata = static_cast<T *>(lua_newuserdata(L, sizeof(T)));
    luaL_getmetatable(L, T::LuaClassMeta);
    lua_setmetatable(L, -2);
    userdata->Set(pointer);
    return userdata;
}

static void RegisterLuaClass(lua_State *L, const luaL_Reg *functions, const char *name) {
    luaL_newmetatable(L, name);
    for (; functions->name != NULL; functions++) {
        lua_pushcfunction(L, functions->func);
        lua_setfield(L, -2, functions->name);
    }

    lua_pushvalue(L, -1); // metatable.__index = metatable
    lua_setfield(L, -2, "__index");

    lua_pop(L, 1);
};

template <class T, class Parent = T::Parent> static void RegisterLuaClass(lua_State *L, const luaL_Reg *functions) {
    luaL_newmetatable(L, T::LuaClassMeta);

    if constexpr (!std::is_same<Parent, void>::value) {
        luaL_getmetatable(L, Parent::LuaClassMeta);

        lua_pushnil(L);
        while (lua_next(L, -2) != 0) {
            lua_pushvalue(L, -2);
            lua_insert(L, -2);
            lua_settable(L, -5);
        }

        lua_setfield(L, -2, "__parent");
    }

    for (; functions->name != NULL; functions++) {
        lua_pushcfunction(L, functions->func);
        lua_setfield(L, -2, functions->name);
    }

    lua_pushvalue(L, -1); // metatable.__index = metatable
    lua_setfield(L, -2, "__index");

    lua_pop(L, 1);
};

template <class T> static T *GetUserdata(lua_State *L, int pos) {
    return (T *)luaL_testudata(L, pos, T::LuaClassMeta);
};

template <class T> static T *checkclass(lua_State *L, int pos)
{
    luaL_getmetatable(L, T::LuaClassMeta);
    void *p = lua_touserdata(L, pos);

    if (p == nullptr || !lua_getmetatable(L, pos)) {
        lua_pop(L, 1);
        luaL_argcheck(L, p != nullptr, pos, T::LuaClassName);
        return nullptr;
    }

    while (!lua_isnil(L, -1)) {
        if (lua_rawequal(L, -1, -2)) {
            lua_pop(L, 2);
            return reinterpret_cast<T*>(p);
        }

        lua_getfield(L, -1, "__parent");
        lua_remove(L, -2);
    }

    luaL_argcheck(L, false, pos, T::LuaClassName);
    return nullptr;
};
