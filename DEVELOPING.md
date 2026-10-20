# Development

The repository contains source overlays rather than vendored dependency trees. To rebuild, clone the original projects, check out the exact revisions listed in `upstream.json`, then copy the matching `source/hades-coop/game` or `source/hades-menu/module` folder over the checkout. Keep the upstream CMake files, libraries and other support files.

```powershell
git clone https://github.com/TheNormalnij/HadesCoopMod.git hades-coop
git clone https://github.com/TheNormalnij/HadesMainMenuApi.git hades-menu
# In each checkout: git checkout <matching revision from upstream.json>
# Overlay the corresponding source folder, then run in each checkout:
cmake -S . -B build -A x64
cmake --build build --config Release
```

Use Visual Studio C++ build tools and CMake. Copy the resulting `HadesCoopGame.dll` and `HadesMainMenuApiLib.dll` to their respective package mod directories after rebuilding. Copy scripts from `game/scripts` and `module/scripts` as well. Regenerate the SHA-256 manifest when package files change.

## Regression tests

From this repository root, set `HADES_LUA_DLL` to a trusted Lua 5.2 DLL from your original mod/game installation, then run with 64-bit Python:

```powershell
$env:HADES_LUA_DLL = 'C:\path\to\lua52.dll'
Get-ChildItem tests/test_*.lua | ForEach-Object {
    python tools/run_lua_test.py $_.FullName
    if ($LASTEXITCODE -ne 0) { throw "Test failed: $($_.Name)" }
}
```

The tests cover syntax, startup ordering, shared gold scaling, revival, shop/healing, player markers and survivor rewards using mocks. Run actual multiplayer gameplay tests before treating a change as stable. Please include reproduction steps and the relevant log excerpt in bug reports, removing personal information first.

## Changing the rules

Start with `source/hades-coop/game/scripts/config.lua` for revival, reward duplication and visual options. Gold behavior lives in `hooks/MoneyHooks.lua`; manual recovery lives in `EmergencyRespawn.lua` and `source/hades-menu/module/src/PauseRecoveryMenu.cpp`. Edit source first and then update the package scripts or rebuild the DLL as appropriate.
