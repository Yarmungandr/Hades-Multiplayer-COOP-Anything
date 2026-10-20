//
// Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#pragma once

class lua_State;

// TODO free memory
class LuaCallback {
  public:

	LuaCallback(lua_State *lusState, int stackIndex);
   
    void PushFunction(lua_State *lusState) const;

private:
    size_t callbackIndex;
};
