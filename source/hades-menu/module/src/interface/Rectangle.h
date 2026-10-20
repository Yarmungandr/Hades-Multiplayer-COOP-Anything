//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#pragma once

namespace SGG {
class Rectangle {
  private:
    int x;
    int y;
    int w;
    int h;
};

static_assert(sizeof(Rectangle) == 0x10, "Incorrect SGG::Rectangle size");
} // namespace SGG
