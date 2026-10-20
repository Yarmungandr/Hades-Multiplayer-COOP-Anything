//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#pragma once

#include "MainMenuHandler.h"
#include <memory>

class LibraryComponents {
  public:
    LibraryComponents();

    static void Initialize();
    static LibraryComponents *Instance() noexcept { return instance.get(); }

    MainMenuHandler *GetMenuHandler() const noexcept { return mainMenuHandler.get(); };

  private:
    static std::unique_ptr<LibraryComponents> instance;
    std::unique_ptr<MainMenuHandler> mainMenuHandler;
};
