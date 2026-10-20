//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#include "pch.h"

#include "LuaGUIComponentFunctionDefs.h"
#include "lua/classes/GuiComponentUserData.h"
#include "lua/helpers/LuaCallback.h"
#include "lua/LuaManager.h"

static int SetText(lua_State *L) {
    auto *wrapper = checkclass<GuiComponentUserData>(L, 1);
    const char *text = luaL_checkstring(L, 2);
    if (!text) {
        return luaL_error(L, "Argument 2 should be text");
    }
    wrapper->Get()->SetText(text);
    return 0;
}

static int SetTextLocalizationKey(lua_State *L) {
    auto *wrapper = checkclass<GuiComponentUserData>(L, 1);
    const char *text = luaL_checkstring(L, 2);
    if (!text) {
        return luaL_error(L, "Argument 2 should be text");
    }

    bool updateText = true;
    if (lua_isboolean(L, 3)) {
        updateText = lua_toboolean(L, 3);
    }

    auto &componentDef = wrapper->Get()->GetComponentData().GetDef();
    componentDef.mHelpTextId = text;

    if (updateText) {
        wrapper->Get()->UseDefaultText();
    }
    return 0;
}

static int UseDefaultText(lua_State *L) {
    auto *wrapper = checkclass<GuiComponentUserData>(L, 1);
    wrapper->Get()->UseDefaultText();
    return 0;
}

static int AddActivationHandler(lua_State *L) {
    auto *wrapper = checkclass<GuiComponentUserData>(L, 1);
    if (!lua_isfunction(L, 2)) {
        return luaL_error(L, "Argument 2 must be a function");
    }

    LuaCallback cb{L, 2};
    wrapper->Get()->GetActivateAction().AddCallBack([cb, L]() {
        cb.PushFunction(L);
        LuaManager::lua_pcallk(L, 0, 0, 0, 0, 0);
    });

    return 0;
}

static const luaL_Reg metatable[] = {
    //
    {"SetText", SetText},
    {"UseDefaultText", UseDefaultText},
    {"SetTextLocalizationKey", SetTextLocalizationKey},
    {"AddActivationHandler", AddActivationHandler},
    {nullptr, nullptr}
    //
};

void LuaGUIComponentFunctionDefs::Load(lua_State *L) { RegisterLuaClass<GuiComponentUserData>(L, metatable); }
