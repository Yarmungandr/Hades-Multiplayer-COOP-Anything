//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#include "pch.h"

#include "LuaMenuScreenDefs.h"

#include "HookedMenuScreen.h"

#include "lua/classes/GuiMenuScreenUserData.h"
#include "lua/classes/GuiComponentButtonUserData.h"
#include "lua/classes/GuiComponentTextBoxUserData.h"
#include "HookedClassFactory.h"
#include "LibraryComponents.h"
#include "lua/helpers/LuaCallback.h"

static int CreateMenuScreen(lua_State *L) {
    auto *sceenManager = LibraryComponents::Instance()->GetMenuHandler()->GetMainMenu()->GetScreenManager();
    auto *menu = HookedClassFactory::Create<HookedMenuScreen>(sceenManager);
    sceenManager->AddScreen(menu);

    NewUserData<GuiMenuScreenUserData>(L, menu);
    return 1;
}

static int MenuScreenLoadDefenitions(lua_State* L) {
    auto *menuWrapper = checkclass<GuiMenuScreenUserData>(L, 1);

    if (!lua_isstring(L, 2)) {
        return luaL_error(L, "Argument 2 must be a string");
    }

    auto *menu = menuWrapper->Get();
    menu->GetScreenData().ReadXml(menu, lua_tostring(L, 2));

    return 0;
}

static int MenuScreenCreateBack(lua_State *L) {
    auto *menuWrapper = checkclass<GuiMenuScreenUserData>(L, 1);

    if (!lua_isnumber(L, 2)) {
        return luaL_error(L, "Argument 2 must be a number");
    }

    menuWrapper->Get()->CreateBack((float)lua_tonumber(L, 2));

    return 0;
}

static int MenuScreenCreateBackground(lua_State *L) {
    auto *menuWrapper = checkclass<GuiMenuScreenUserData>(L, 1);

    const char *str = lua_isstring(L, 2) ? lua_tostring(L, 2) : "";
    eastl::string bgName{str};

    menuWrapper->Get()->CreateBackground(&bgName);

    return 0;
}

static int MenuScreenCreateTitleText(lua_State *L) {
    if (!lua_isuserdata(L, 1)) {
        return luaL_error(L, "Argument 1 must be a MenuScreen");
    }

    auto *menu = static_cast<GuiMenuScreenUserData *>(lua_touserdata(L, 1));
    menu->Get()->CreateTitleText(menu->Get());

    return 0;
}

static int MenuScreenCreateCancelButton(lua_State *L) {
    auto *menuWrapper = checkclass<GuiMenuScreenUserData>(L, 1);
    menuWrapper->Get()->CreateCancelButton(menuWrapper->Get());

    if (!lua_isfunction(L, 2)) {
        return luaL_error(L, "Argument 2 must be a function");
    }

    LuaCallback cb{L, 2};

    menuWrapper->Get()->GetCancelButton()->GetActivateAction().AddCallBack([cb, L]() {
        cb.PushFunction(L);
        lua_pcall(L, 0, 0, 0);
    });

    return 0;
}

static int MenuScreenSetLoverInputBlock(lua_State *L) {
    auto *menuWrapper = checkclass<GuiMenuScreenUserData>(L, 1);

    if (!lua_isboolean(L, 2)) {
        return luaL_error(L, "Argument 1 must be a boolean");
    }

    menuWrapper->Get()->SetLoverInputBlock(lua_toboolean(L, 2) == 1);

    return 0;
}

static int MenuScreenExitScreen(lua_State *L) {
    auto *menuWrapper = checkclass<GuiMenuScreenUserData>(L, 1);

    auto *menu = menuWrapper->Get();
    auto *cancelBtn = menu->GetCancelButton();

    menu->ExitScreen();
    return 0;
}

// menu:AddReflection(name, button)
static int MenuScreenAddReflection(lua_State *L) {
    auto *menuWrapper = checkclass<GuiMenuScreenUserData>(L, 1);
    const char *name = luaL_checkstring(L, 2);
    if (!name) {
        return luaL_error(L, "Argument 2 should be a component name");
    }

    if (auto *button = GetUserdata<GuiComponentButtonUserData>(L, 3)) {
        menuWrapper->Get()->GetReflectionHelper().ReflectComponent(name, button->Get());
    } else if (auto *text = GetUserdata<GuiComponentTextBoxUserData>(L, 3)) {
        menuWrapper->Get()->GetReflectionHelper().ReflectComponent(name, text->Get());
    } else {
        return luaL_error(L, "Unsupported type");
    }

    return 0;
};

static const luaL_Reg menuscreen_mt[] = {
    //
    {"Create", CreateMenuScreen},
    {"ExitScreen", MenuScreenExitScreen},
    {"LoadDefenitions", MenuScreenLoadDefenitions},
    {"CreateBack", MenuScreenCreateBack},
    {"CreateBackground", MenuScreenCreateBackground},
    {"CreateTitleText", MenuScreenCreateTitleText},
    {"CreateCancelButton", MenuScreenCreateCancelButton},
    {"SetLowerInputBlock", MenuScreenSetLoverInputBlock},
    {"AddReflection", MenuScreenAddReflection},
    {nullptr, nullptr}
    //
};

void LuaMenuScreenFunctionDefs::Load(lua_State* L) {
    lua_register(L, "CreateMenuScreen", CreateMenuScreen);
    RegisterLuaClass<GuiMenuScreenUserData>(L, menuscreen_mt);
}
