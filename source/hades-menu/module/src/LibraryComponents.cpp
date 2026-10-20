//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#include "pch.h"
#include "LibraryComponents.h"

std::unique_ptr<LibraryComponents> LibraryComponents::instance{};

LibraryComponents::LibraryComponents() { mainMenuHandler = std::make_unique<MainMenuHandler>(); }

void LibraryComponents::Initialize() { instance = std::make_unique<LibraryComponents>(); }