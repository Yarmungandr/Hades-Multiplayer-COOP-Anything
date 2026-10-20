//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#pragma once

#include "HookedMenuScreen.h"

class GamemodeScreen : public HookedMenuScreen {
  public:
    void IheritedConstrictor(SGG::ScreenManager *screenManager);

  private:
    void CreateComponents();
};
