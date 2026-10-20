//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#include "HookTable.h"

static HookTable g_HookTable{};

HookTable &HookTable::Instance() { return g_HookTable; }

void HookTable::Init(IModApi::GetSymbolAddress_t GetSymbolAddress) {
    _aligned_malloc = GetSymbolAddress("__imp__aligned_malloc");
    MenuScreen_constructor = GetSymbolAddress("sgg::MenuScreen::MenuScreen");
    MenuScreen_destructor = GetSymbolAddress("sgg::MenuScreen::~MenuScreen");
    MenuScreen_constructor_ScreenManager = GetSymbolAddress("??0MenuScreen@sgg@@QEAA@PEAVScreenManager@1@@Z");
    MenuScreen_CreateBack = GetSymbolAddress("sgg::MenuScreen::CreateBack");
    MenuScreen_CreateBackground = GetSymbolAddress("sgg::MenuScreen::CreateBackground");
    MenuScreen_CreateTitleText = GetSymbolAddress("sgg::MenuScreen::CreateTitleText");
    MenuScreen_CreateCancelButton = GetSymbolAddress("sgg::MenuScreen::CreateCancelButton");
    MenuScreen_vft = GetSymbolAddress("??_7MenuScreen@sgg@@6BGameScreen@1@@");

    MainMenuScreen_MainMenuScreen = GetSymbolAddress("sgg::MainMenuScreen::MainMenuScreen");
    MainMenuScreen_OpenProfiles = GetSymbolAddress("sgg::MainMenuScreen::OpenProfiles");
    GUIComponentButton_GUIComponentButton = GetSymbolAddress("sgg::GUIComponentButton::GUIComponentButton");
    GUIComponentButton_UseDefaultText = GetSymbolAddress("?UseDefaultText@GUIComponentButton@sgg@@UEAAXXZ");

    GUIComponentTextBox_GUIComponentTextBox = GetSymbolAddress("??0GUIComponentTextBox@sgg@@QEAA@AEBVVector2@Vectormath@@@Z");

    vector8x8_push = GetSymbolAddress(
        "eastl::stack<sgg::IUndoRedoRecord *,eastl::vector<sgg::IUndoRedoRecord *,eastl::allocator_forge> >::push");

    GUIComponentReflectionHelper_ReflectComponent_GUIComponentButton = GetSymbolAddress("sgg::GUIComponentReflectionHelper::ReflectComponent<sgg::GUIComponentButton *>");
    GUIComponentReflectionHelper_ReflectComponent_GUIComponentTextBox =
        GetSymbolAddress("sgg::GUIComponentReflectionHelper::ReflectComponent<sgg::GUIComponentTextBox *>");

    ScreenManager_AddScreen_screen = GetSymbolAddress("?AddScreen@ScreenManager@sgg@@QEAAXPEAVGameScreen@2@@Z");

    ScreenData_ReadXml = GetSymbolAddress("sgg::ScreenData::ReadXml");

    lua_pcallk = GetSymbolAddress("lua_pcallk");
    return;
}
