//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#pragma once

#include "HookTable.h"

#include "GamemodeScreen.h"
#include "interface/Vector2.h"

class HookedClassFactory {
  public:
    template <typename T, typename... Args> static T *Create(Args... args);

    template <>
    static SGG::GUIComponentButton *Create<SGG::GUIComponentButton>(SGG::MenuScreen *screenManager) {
        auto constructorPos = HookTable::Instance().GUIComponentButton_GUIComponentButton;
        return CreateHooked<SGG::GUIComponentButton>(constructorPos, screenManager);
    }

    template <> static SGG::GUIComponentTextBox *Create<SGG::GUIComponentTextBox>() {
        auto constructorPos = HookTable::Instance().GUIComponentTextBox_GUIComponentTextBox;
        const Vectormath::Vector2 pos{0.f, 0.f};
        return CreateHooked<SGG::GUIComponentTextBox>(constructorPos, &pos);
    }

    template <> static GamemodeScreen *Create<GamemodeScreen>(SGG::ScreenManager *screenMamaner) {
        auto *instance = Allocate<GamemodeScreen>();
        instance->IheritedConstrictor(screenMamaner);
        return instance;
    }

    template <> static HookedMenuScreen *Create<HookedMenuScreen>(SGG::ScreenManager *screenMamaner) {
        auto *instance = Allocate<HookedMenuScreen>();
        instance->IheritedConstrictor(screenMamaner);
        return instance;
    }

  private:
    template <typename T, typename... Args> static T *CreateHooked(uintptr_t constructorPos, Args... args) {
        return reinterpret_cast<T *(*)(void *, Args...)>(constructorPos)(Allocate<T>(), args...);
    };

    template <class T> static T* Allocate() {
        auto *_aligned_malloc =
            *reinterpret_cast<void *(__cdecl **)(size_t, size_t)>(HookTable::Instance()._aligned_malloc);

        return reinterpret_cast<T *>(_aligned_malloc(sizeof(T), std::alignment_of<T>::value));
    }
};
