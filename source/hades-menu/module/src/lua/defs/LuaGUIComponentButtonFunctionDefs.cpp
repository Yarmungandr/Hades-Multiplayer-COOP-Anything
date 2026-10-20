//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#include "pch.h"

#include "LuaGUIComponentButtonFunctionDefs.h"
#include "interface/GUIComponentButton.h"

#include "lua/classes/GuiComponentButtonUserData.h"
#include "lua/classes/GuiMenuScreenUserData.h"
#include "HookedClassFactory.h"

// GUIComponentButton CreateGUIComponentButton(MenuScreen parent)
static int CreateGUIComponentButton(lua_State* L) {
    auto *menuWrapper = checkclass<GuiMenuScreenUserData>(L, 1);
    auto *newBtn = HookedClassFactory::Create<SGG::GUIComponentButton, SGG::MenuScreen *>(menuWrapper->Get());

    auto& compData = newBtn->GetComponentData();
    compData.SetCreated(true);

    newBtn->SetParent(menuWrapper->Get());
    menuWrapper->Get()->AddComponent(newBtn);

    NewUserData<GuiComponentButtonUserData>(L, newBtn);
    return 1;
}

static const luaL_Reg button_mt[] = {
    //
    {nullptr, nullptr}
    //
};

void LuaGUIComponentButtonFunctionDefs::Load(lua_State *L) {
    lua_register(L, "CreateGUIComponentButton", CreateGUIComponentButton);
    RegisterLuaClass<GuiComponentButtonUserData>(L, button_mt);
}
