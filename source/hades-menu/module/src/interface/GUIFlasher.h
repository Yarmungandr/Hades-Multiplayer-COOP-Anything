//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#pragma once

namespace SGG {
class GUIFlasher {
  public:

  private:
    char pad[0x38];
};
static_assert(sizeof(GUIFlasher) == 0x38, "Incorrect SGG::GUIFlasher size");
} // namespace SGG