//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#pragma once

#include "ComponentDataDef.h"

namespace SGG {
class ComponentData {
  public:
    ComponentDataDef &GetDef() { return mDef; };
    void SetCreated(bool flag) { mCreated = flag; };

  private:
    bool mCreated;
    eastl::basic_string<char, eastl::allocator_forge> mName;

    ComponentDataDef mDef;
};
static_assert(sizeof(ComponentData) == 0x780, "Incorrect SGG::ComponentData size");
} // namespace SGG
