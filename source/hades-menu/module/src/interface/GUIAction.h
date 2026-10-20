//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#pragma once

#include "../EASTL-forge1.51/functional.h"
#include "../EASTL-forge1.51/vector.h"

namespace SGG {
class GUIAction {
  public:
    void AddCallBack(eastl::function<void __cdecl(void)> &&callBack) { mCallBacks.push_back(eastl::move(callBack)); }
    void RemoveAll() {
        mCallBacks.set_capacity(0);
        mCallBacks.reset_lose_memory();
    }

  private:
    eastl::vector<eastl::function<void __cdecl(void)>, eastl::allocator_forge> mCallBacks;
};
static_assert(sizeof(GUIAction) == 0x18, "Incorrect SGG::GUIAction size");
} // namespace SGG
