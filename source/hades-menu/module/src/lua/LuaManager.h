//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#pragma once

#include "defs/LuaGamemodeFunctionDefs.h"
#include "defs/LuaGUIComponentButtonFunctionDefs.h"
#include "defs/LuaMenuScreenDefs.h"
#include "defs/LuaMainMenuScreenFunctionDefs.h"
#include "defs/LuaGUIComponentFunctionDefs.h"
#include "defs/LuaGUIComponentTextBoxFunctionDefs.h"

#include "HookTable.h"

class lua_State;
typedef int (*lua_CFunction)(lua_State *L);

class LuaManager {
  public:
    static void Initialize(lua_State *state) {
        luaState = state;

        LuaGUIComponentFunctionDefs::Load(state);
        LuaGamemodeFunctionDefs::Load(state);
        LuaMenuScreenFunctionDefs::Load(state);
        LuaGUIComponentButtonFunctionDefs::Load(state);
        LuaMainMenuScreenFunctionDefs::Load(state);
        LuaGUIComponentTextBoxFunctionDefs::Load(state);
    }

    static lua_State *GetLuaState() { return luaState; };

    static int lua_pcallk(lua_State *L, int nargs, int nresults, int errfunc, int ctx, lua_CFunction k) {
        return GET_HOOK(lua_pcallk, int64_t(__fastcall *)(lua_State *, int, int, int, int, lua_CFunction))(L, nargs, nresults, errfunc, ctx, k);
    }

  private:
    static inline lua_State *luaState{};
};
