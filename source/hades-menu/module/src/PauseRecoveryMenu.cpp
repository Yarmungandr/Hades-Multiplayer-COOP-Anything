#include "pch.h"
#include "FunctionHook.h"
#include "HookedClassFactory.h"
#include "interface/MenuScreen.h"
#include "lua/LuaManager.h"
#include "lua/lua.hpp"
#include <memory>

namespace {
bool CallCoop(const char* name) {
    auto* L = LuaManager::GetLuaState();
    if (!L) return false;
    const int top = lua_gettop(L);
    lua_getglobal(L, name);
    bool result = false;
    if (lua_isfunction(L, -1) &&
        LuaManager::lua_pcallk(L, 0, 1, 0, 0, nullptr) == LUA_OK)
        result = lua_toboolean(L, -1) != 0;
    lua_settop(L, top);
    return result;
}
using PauseHook = FunctionHook<"CoopPauseRecovery", SGG::MenuScreen*,
    SGG::MenuScreen*, void*, void*>;
std::unique_ptr<PauseHook> hook;
}

void InstallPauseRecoveryMenu(uintptr_t constructor) {
    if (!constructor || hook) return;
    const unsigned char prologue[] = {0x48,0x8B,0xC4,0x55,0x56,0x57,0x41,0x54,0x41,0x55,0x41,0x56};
    if (std::memcmp(reinterpret_cast<void*>(constructor), prologue, sizeof(prologue)) != 0) return;
    // Steam engine PDB + disassembly: this, ScreenManager*, third argument;
    // first 12 bytes end on an instruction boundary.
    hook = std::make_unique<PauseHook>(reinterpret_cast<void*>(constructor), 12);
    hook->onPostFunction = [](SGG::MenuScreen* screen) {
        if (!CallCoop("TN_CoopCanReviveP1")) return screen;
        auto* style = screen->GetFirstUseableComponent();
        if (!style) return screen;
        auto* button = HookedClassFactory::Create<SGG::GUIComponentButton, SGG::MenuScreen*>(screen);
        button->Load(&style->GetComponentData());
        button->SetParent(screen);
        button->SetLocation({960.0f, 900.0f});
        button->SetText("Revive P1");
        button->SetTextColor(0xFFEECC88);
        screen->AddComponent(button);
        button->GetActivateAction().AddCallBack([screen]() {
            if (CallCoop("TN_CoopQueueReviveP1")) screen->ExitScreen();
        });
        return screen;
    };
    hook->Install();
}
