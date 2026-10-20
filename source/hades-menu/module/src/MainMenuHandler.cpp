//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#include "pch.h"

#include "MainMenuHandler.h"
#include "HookTable.h"
#include "interface/eastl_string.h"
#include "GamemodeScreen.h"
#include "HookedClassFactory.h"
#include "GamemodeManager.h"

MainMenuHandler::MainMenuHandler() : funHook{(void *)HookTable::Instance().MainMenuScreen_MainMenuScreen, 12 } {
    funHook.Install();
    funHook.onPostFunction = [this](SGG::MainMenuScreen *menuScreen) {
        mainMenuScreen = menuScreen;

        size_t gamemodesCount = GamemodeManager::Instance().GetGamemodes().size();
        if (gamemodesCount > 0)
            InitializeCustomButtons();

        return mainMenuScreen;
    };
}

void MainMenuHandler::InitializeCustomButtons() {
    auto exitBtn = mainMenuScreen->GetExitButton();
    auto exitBtnPos = exitBtn->GetLocation();
    exitBtn->SetLocation({exitBtnPos.mX, exitBtnPos.mY + 90});

    auto *gamemodeBtn = HookedClassFactory::Create<SGG::GUIComponentButton, SGG::MenuScreen *>(mainMenuScreen);
    gamemodeBtn->Load(&exitBtn->GetComponentData());
    auto& componentDef = gamemodeBtn->GetComponentData().GetDef();
    componentDef.mHelpTextId = "MainMenuAPI_SelectGamemode";

    gamemodeBtn->SetLocation(exitBtnPos);
    gamemodeBtn->SetParent(mainMenuScreen);
    gamemodeBtn->UseDefaultText();
    mainMenuScreen->AddComponent(gamemodeBtn);
    mainMenuScreen->MoveComponentComponentBack(gamemodeBtn, 20);

    eastl::string gamemodeBtnText{"Credits_AlegreyaSansSCExtraBold"};
    gamemodeBtn->SetFont(&gamemodeBtnText);
    gamemodeBtn->SetTextColor(0xFFCCCCCC);
    gamemodeBtn->SetFadeOpacity(0.0f);
    gamemodeBtn->SetFadeTarget(1.0f);
    gamemodeBtn->SetFadeDelay(1.05f);

    auto &clickHandler = gamemodeBtn->GetActivateAction();
    clickHandler.AddCallBack([this]() {
        auto *screenMamaner = this->mainMenuScreen->GetScreenManager();
        GamemodeScreen *gamemodeMenu = HookedClassFactory::Create<GamemodeScreen>(screenMamaner);
        screenMamaner->AddScreen(gamemodeMenu);
    });
}
