//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#pragma once

#include "Vector2.h"
#include "TimeSpan.h"
#include "IRectangle.h"
#include "ScreenManager.h"

#include "../libs/EASTL-forge1.51/EABase/eabase.h"
#include "../libs/EASTL-forge1.51/string.h"
#include "../libs/EASTL-forge1.51/vector.h"

namespace SGG {
class InputHandler;
enum class ScreenState : uint32_t;

enum class ScreenType : uint32_t {
    Game = 0x1,
    Menu = 0x3,
    Ingameui = 0x7,
    Shell = 0xB,
    About = 0x1B,
    Announcement = 0x2B,
    DebugKey = 0x43,
    ExitDialog = 0x83,
    Gameplay = 0x101,
    GameStart = 0x203,
    Settings = 0x40B,
    KeyMapping = 0xC0B,
    Language = 0x100B,
    Launch = 0x2003,
    Load = 0x4003,
    LoadMap = 0x8003,
    LoadSave = 0x10003,
    MainMenu = 0x20003,
    MessageDialog = 0x40003,
    PatchNotes = 0x8000B,
    Pause = 0x100003,
    Profile = 0x20000B,
    Resolution = 0x40000B,
    MiscSettings = 0x80040B,
    SettingsMenu = 0x100000B,
    StartNew = 0x200000B,
    CloudSettingsMenu = 0x4000000,
};

class GameScreen {
  public:
    virtual void OnExit() = 0;
    virtual void LoadContent() = 0;
    virtual void UnloadContent() = 0;
    virtual void Update(float, const eastl::vector<InputHandler *, eastl::allocator_forge> *) = 0;
    virtual void HandleInput(InputHandler *, float) = 0;
    virtual void HandleNoInput() = 0;
    virtual void Draw(float) = 0;
    virtual bool IsTextComplete(const eastl::basic_string<char8_t, eastl::allocator_forge> *) = 0;
    virtual void ExitScreen() = 0;
    virtual void Clear() = 0;
    virtual void OnControlSchemeChanged(bool) = 0;
    virtual void Init(ScreenManager *, const eastl::basic_string<char8_t, eastl::allocator_forge> *) = 0;
    virtual eastl::vector<IRectangle, eastl::allocator_forge> *
    ComponentBounds(eastl::vector<IRectangle, eastl::allocator_forge> *result) = 0;

    virtual ScreenType GetType() = 0;
    virtual ~GameScreen() = 0;

    ScreenManager *GetScreenManager() const noexcept { return mScreenManager; }

    void SetLoverInputBlock(bool status) noexcept { mBlockLowerInput = status; }

protected:
    bool mTransitionFinished;
    TimeSpan Zero;
    Vectormath::Vector2 mDrawLocation;
    bool mFullscreenSpriteEffect;
    bool mRemoved;
    bool mIsVisible;
    bool mUseFadeTransition;
    bool mBlockLowerInput;
    bool mAllowAllPlayerInput;
    bool mOverPauseMenu;
    bool mAllowDuplicates;
    bool mBlockContentUnload;
    TimeSpan mTransitionOnTime;
    TimeSpan mTransitionOffTime;
    float mTransitionPosition;
    float mUpwardVelocity;
    float mGravity;
    float mBounceMultiplier;
    ScreenState mScreenState;
    bool mIsExiting;
    ScreenManager *mScreenManager;

};
static_assert(sizeof(GameScreen) == 0x60, "Incorrect SGG::GameScreen size");
} // namespace SGG