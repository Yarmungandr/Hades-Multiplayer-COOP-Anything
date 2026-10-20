//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#pragma once

#include "../include/HadesModApi.h"

#define GET_HOOK(name, type) (reinterpret_cast<type>(HookTable::Instance().name))

struct HookTable {
    static HookTable& Instance();
    void Init(IModApi::GetSymbolAddress_t GetSymbolAddress);

    uintptr_t _aligned_malloc;

    uintptr_t MenuScreen_constructor;
    uintptr_t MenuScreen_destructor;
    uintptr_t MenuScreen_constructor_ScreenManager;
    uintptr_t MenuScreen_CreateBack;
    uintptr_t MenuScreen_CreateBackground;
    uintptr_t MenuScreen_CreateTitleText;
    uintptr_t MenuScreen_CreateCancelButton;
    uintptr_t MenuScreen_vft;

    uintptr_t MainMenuScreen_MainMenuScreen;
    uintptr_t MainMenuScreen_OpenProfiles;

    uintptr_t GUIComponentButton_GUIComponentButton;
    uintptr_t GUIComponentButton_UseDefaultText;

    uintptr_t GUIComponentTextBox_GUIComponentTextBox;

    uintptr_t vector8x8_push;

    uintptr_t GUIComponentReflectionHelper_ReflectComponent_GUIComponentButton;
    uintptr_t GUIComponentReflectionHelper_ReflectComponent_GUIComponentTextBox;

    uintptr_t ScreenManager_AddScreen_screen;

    uintptr_t ScreenData_ReadXml;

    uintptr_t lua_pcallk;
};
