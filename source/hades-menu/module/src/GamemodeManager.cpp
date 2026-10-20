//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#include "pch.h"

#include "GamemodeManager.h"
#include <memory>

static std::unique_ptr<GamemodeManager> instance;

GamemodeManager &GamemodeManager::Instance() {
    if (!instance) {
        instance = std::make_unique<GamemodeManager>();
    }
    return *instance;
}
