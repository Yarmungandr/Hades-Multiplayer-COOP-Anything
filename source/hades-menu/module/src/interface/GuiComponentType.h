//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#pragma once

namespace SGG {
enum class EGuiComponentType : uint32_t {
    TYPE_GUI_NONE = 0x0,
    TYPE_GUI_BOX = 0x1,
    TYPE_GUI_TEXT = 0x2,
    TYPE_GUI_LINE = 0x4,
    TYPE_GUI_IMAGE = 0x8,
    TYPE_GUI_ANIMATION = 0x10,
    TYPE_GUI_BUTTON = 0x20,
    TYPE_GUI_SLIDER = 0x40,
    TYPE_GUI_TEXT_BOX = 0x81,
    TYPE_GUI_REMAPPABLE_BUTTON = 0x120,
};
} // namespace SGG