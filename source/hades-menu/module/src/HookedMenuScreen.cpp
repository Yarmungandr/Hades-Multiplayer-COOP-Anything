//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#include "pch.h"

#include "HookedMenuScreen.h"

HookedMenuScreen::HookedMenuScreenVtbl HookedMenuScreen::VTBL{
    //
    .Desctuctor =
        [](HookedMenuScreen *self) {
            if (self->mCancelButton) {
                self->mCancelButton->GetActivateAction().RemoveAll();
            }

            for (auto *element : self->mComponents) {
                element->GetActivateAction().RemoveAll();
            }

            GET_HOOK(MenuScreen_destructor, void (*)(void *))(self);
        }
    //
};

void HookedMenuScreen::HookedMenuScreenVtbl::Initialize() {
    Initialize(reinterpret_cast<const HookedMenuScreenVtbl *>(HookTable::Instance().MenuScreen_vft));
}

void HookedMenuScreen::HookedMenuScreenVtbl::Initialize(const HookedMenuScreenVtbl *parent) {
    const uintptr_t *parentAsUintptr = reinterpret_cast<const uintptr_t *>(parent);
    uintptr_t *thisAsVtbl = reinterpret_cast<uintptr_t *>(&HookedMenuScreen::VTBL);
    for (size_t i = 0; i < sizeof(HookedMenuScreenVtbl) / sizeof(uintptr_t); i++) {
        if (!thisAsVtbl[i])
            thisAsVtbl[i] = parentAsUintptr[i];
    }
}
