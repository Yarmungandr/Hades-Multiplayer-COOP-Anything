//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#include "pch.h"

#include <memory>
#include "../include/HadesModApi.h"
#include "HookTable.h"
#include "LibraryComponents.h"
#include "GamemodeScreen.h"
#include "GamemodeManager.h"
#include "lua/LuaManager.h"

void InstallPauseRecoveryMenu(uintptr_t constructor);

HADES_MOD_API void _cdecl HadesModLuaCreated(lua_State *luaState) {
    LuaManager::Initialize(luaState);
    // Reset gamemode list and wait next MainMenuAPIAddGamemode
    GamemodeManager::Instance().Reset();
};

HADES_MOD_API bool _cdecl HadesModInit(const IModApi *modApi) {
    if (modApi->version < MOD_API_VERSION)
        return false;

    HookTable::Instance().Init(modApi->GetSymbolAddress);

    HookedMenuScreen::VTBL.Initialize();
    LibraryComponents::Initialize();
    InstallPauseRecoveryMenu(modApi->GetSymbolAddress("sgg::PauseScreen::PauseScreen"));
    return true;
};

HADES_MOD_API bool _cdecl HadesModStart() { return true; };

HADES_MOD_API bool _cdecl HadesModStop() { return true; };
