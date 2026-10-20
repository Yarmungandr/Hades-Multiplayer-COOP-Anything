"""Run Lua regression tests using the installed game's unmodified Lua 5.2 runtime."""
import ctypes
import sys
import os
from pathlib import Path

root = Path(__file__).resolve().parent
lua = ctypes.CDLL(os.environ['HADES_LUA_DLL'])
lua.luaL_newstate.restype = ctypes.c_void_p
lua.luaL_openlibs.argtypes = [ctypes.c_void_p]
lua.luaL_loadfilex.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_char_p]
lua.luaL_loadfilex.restype = ctypes.c_int
lua.lua_pcallk.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_void_p]
lua.lua_pcallk.restype = ctypes.c_int
lua.lua_tolstring.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.POINTER(ctypes.c_size_t)]
lua.lua_tolstring.restype = ctypes.c_char_p
lua.lua_close.argtypes = [ctypes.c_void_p]
state = lua.luaL_newstate()
if not state:
    raise RuntimeError('Lua allocation failed')
try:
    lua.luaL_openlibs(state)
    status = lua.luaL_loadfilex(state, os.path.relpath(sys.argv[1] if len(sys.argv) > 1 else 'tests/test_chamber_respawn.lua').encode('utf-8'), None)
    if status == 0:
        status = lua.lua_pcallk(state, 0, -1, 0, 0, None)
    if status:
        raise RuntimeError(lua.lua_tolstring(state, -1, None).decode('utf-8', errors='replace'))
finally:
    lua.lua_close(state)

