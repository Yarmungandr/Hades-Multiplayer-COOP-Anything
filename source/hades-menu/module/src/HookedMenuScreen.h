//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#pragma once

#include "interface/MenuScreen.h"

class HookedMenuScreen : public SGG::MenuScreen {
  public:
    struct HookedMenuScreenVtbl {
        void(__fastcall *OnExit)(HookedMenuScreen *self){};
        void(__fastcall *LoadContent)(HookedMenuScreen *self){};
        void(__fastcall *UnloadContent)(HookedMenuScreen *self){};
        void(__fastcall *Update)(HookedMenuScreen *self, float,
                                 const eastl::vector<SGG::InputHandler *, eastl::allocator_forge> *){};
        void(__fastcall *HandleInput)(HookedMenuScreen *self, SGG::InputHandler *, float){};
        void(__fastcall *HandleNoInput)(HookedMenuScreen *self){};
        void(__fastcall *Draw)(HookedMenuScreen *self, float){};
        bool(__fastcall *IsTextComplete)(HookedMenuScreen *self,
                                         const eastl::basic_string<char, eastl::allocator_forge> *){};
        void(__fastcall *ExitScreen)(HookedMenuScreen *self){};
        void(__fastcall *Clear)(HookedMenuScreen *self){};
        void(__fastcall *OnControlSchemeChanged)(HookedMenuScreen *self, bool){};
        void(__fastcall *Init)(HookedMenuScreen *self, SGG::ScreenManager *,
                               const eastl::basic_string<char, eastl::allocator_forge> *){};
        eastl::vector<SGG::IRectangle, eastl::allocator_forge> *(__fastcall *ComponentBounds)(
            HookedMenuScreen *self, eastl::vector<SGG::IRectangle, eastl::allocator_forge> *result){};
        SGG::ScreenType(__fastcall *GetType)(HookedMenuScreen *self) {};
        void(__fastcall *Desctuctor)(HookedMenuScreen *self){};
        void(__fastcall *OnCancel)(HookedMenuScreen *self){};
        void(__fastcall *SetupControls)(HookedMenuScreen *self){};
        bool(__fastcall *WasClickPressed)(HookedMenuScreen *self, SGG::InputHandler *){};
        bool(__fastcall *UpdateTooltip)(HookedMenuScreen *self, SGG::InputHandler *, float){};
        void(__fastcall *SelectComponent)(HookedMenuScreen *self, SGG::GUIComponent *, SGG::InputHandler *){};
        bool(__fastcall *NotifyComponentsOfClick)(HookedMenuScreen *self, const Vectormath::Vector2 *,
                                                  SGG::EControllerIndex::Enum){};
        void(__fastcall *NotifyComponentsOfDoubleClick)(HookedMenuScreen *self, const Vectormath::Vector2 *,
                                                        SGG::EControllerIndex::Enum){};
        void(__fastcall *PostLoad)(HookedMenuScreen *self){};
        void(__fastcall *OnLanguageChanged)(HookedMenuScreen *self){};
        void(__fastcall *Load)(HookedMenuScreen *self, const char *){};
        SGG::GUIComponent *(__fastcall *GetFirstUseableComponent)(HookedMenuScreen *self){};

        void Initialize();
        void Initialize(const HookedMenuScreenVtbl* parent);
    };

    friend HookedMenuScreenVtbl;

    public:
    void IheritedConstrictor(SGG::ScreenManager *screenManager) {
        GET_HOOK(MenuScreen_constructor_ScreenManager,
                 SGG::MenuScreen * (__fastcall *)(SGG::MenuScreen *, SGG::ScreenManager *))(this, screenManager);
        SetVTBL(&VTBL);
    };

    protected:
    void SetVTBL(HookedMenuScreenVtbl *vtbl) { *reinterpret_cast<HookedMenuScreenVtbl **>(this) = vtbl; }
  public:
    static HookedMenuScreenVtbl VTBL;
};
