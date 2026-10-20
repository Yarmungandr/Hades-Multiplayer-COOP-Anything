//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#include "pch.h"

#include "LuaGUIComponentTextBoxFunctionDefs.h"
#include "lua/classes/GuiComponentTextBoxUserData.h"
#include "lua/classes/GuiMenuScreenUserData.h"
#include "HookedClassFactory.h"

static int CreateGUIComponentTextBox(lua_State* L) { 
    auto *menuWrapper = checkclass<GuiMenuScreenUserData>(L, 1);
    auto *textBox = HookedClassFactory::Create<SGG::GUIComponentTextBox>();
    textBox->SetParent(menuWrapper->Get());
    menuWrapper->Get()->AddComponent(textBox);

    NewUserData<GuiComponentTextBoxUserData>(L, textBox);
    return 1;
}

static const luaL_Reg metatable[] = {
    //
    {nullptr, nullptr}
    //
};

void LuaGUIComponentTextBoxFunctionDefs::Load(lua_State *L) {
    lua_register(L, "CreateGUIComponentTextBox", CreateGUIComponentTextBox);
    RegisterLuaClass<GuiComponentTextBoxUserData>(L, metatable);
}
