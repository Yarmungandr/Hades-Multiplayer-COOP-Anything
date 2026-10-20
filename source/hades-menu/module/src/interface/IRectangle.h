//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#pragma once

namespace SGG {
class IRectangle {
  private:
    int x;
    int y;
    int w;
    int h;
};

static_assert(sizeof(IRectangle) == 0x10, "Incorrect SGG::IRectangle size");
} // namespace SGG
