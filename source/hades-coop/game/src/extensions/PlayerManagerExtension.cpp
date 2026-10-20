//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#include "PlayerManagerExtension.h"
#include "../interface/PlayerManager.h"

bool PlayerManagerExtension::AssignGamepad(size_t playerIndex, uint8_t gamepadIndex) {
    auto *player = GetPlayer(playerIndex);

    if (!player)
        return false;

    auto *input = GetInput(player->GetControllerIndex());

    if (!input)
        return false;

    input->SetGamepadId(gamepadIndex);

    return true;
}

uint8_t PlayerManagerExtension::GetGamepad(size_t playerIndex) {
    auto *player = GetPlayer(playerIndex);

    if (!player)
        return -1;

    auto *input = GetInput(player->GetControllerIndex());

    if (!input)
        return -1;

    return input->GetGamepadId();
}

bool PlayerManagerExtension::AssignController(SGG::Player *player, uint8_t ccontroler) {
    if (!player || ccontroler >= MAX_PLAYERS)
        return false;
    SGG::PlayerManager::Instance()->AssignController(player, ccontroler);
    return player->GetControllerIndex() == ccontroler;
}

bool PlayerManagerExtension::HasPlayer(size_t index) {
    auto *instance = SGG::PlayerManager::Instance();
    if (instance->m_palyers.size() <= index)
        return false;

    return instance->m_palyers[index];
}

void PlayerManagerExtension::RemovePlayer(size_t index) {
    auto *instance = SGG::PlayerManager::Instance();
    if (instance->m_palyers.size() <= index)
        return;

    auto *player = instance->m_palyers[index];

    if (player) {
        // Use the engine's destructor and allocator, including its UI cleanup.
        ((void(__fastcall *)(void *, uint64_t))HookTable::Instance().PlayerManager_RemovePlayer)(instance, index);
    }
}

SGG::Player *PlayerManagerExtension::CreatePlayer(size_t index) {
    auto *instance = SGG::PlayerManager::Instance();

    if (index >= MAX_PLAYERS)
        return nullptr;

    // Stock Hades starts with two player slots and five input slots. Resize
    // through the engine so allocation/deallocation stays in the same CRT.
    if (instance->m_palyers.size() < MAX_PLAYERS) {
        if (!HookTable::Instance().PlayerVector_Resize)
            return nullptr;
        ((void(__fastcall *)(void *, uint64_t))HookTable::Instance().PlayerVector_Resize)(
            &instance->m_palyers, MAX_PLAYERS);
    }

    if (instance->m_palyers[index] != nullptr)
        return nullptr;

    uint8_t controller = static_cast<uint8_t>(index);

    auto player = instance->AddPlayer(index);
    if (!player || !AssignController(player, controller)) {
        if (player) RemovePlayer(index);
        return nullptr;
    }

    return player;
}

SGG::Player *PlayerManagerExtension::GetPlayer(size_t index) {
    auto *instance = SGG::PlayerManager::Instance();
    return index < instance->m_palyers.size() ? instance->m_palyers[index] : nullptr;
}
SGG::InputHandler *PlayerManagerExtension::GetInput(size_t index) {
    auto *instance = SGG::PlayerManager::Instance();
    return index < instance->m_inputMethods.size() ? instance->m_inputMethods[index] : nullptr;
};

size_t PlayerManagerExtension::GetPlayersCount() const noexcept {
    size_t size = 0;
    for (auto *player : SGG::PlayerManager::Instance()->m_palyers)
        if (player)
            size++;

    return size;
}
