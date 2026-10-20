# Hades Multiplayer — COOP Anything inspired

An unofficial, experimental Hades co-op extension for up to four local players, built on [TheNormalnij's HadesCoopMod](https://github.com/TheNormalnij/HadesCoopMod). Remote friends can share the host's session through Parsec.

**This was made as a playful experiment — basically a joke project to have fun with my friends.** It is not a polished product or a promise of ongoing support. If you want something more complete, you are absolutely welcome to fork it, change it however you like, and take it further, under the included licenses. Keep the original authors' notices and give credit where it is due.

## Play in three steps

1. Own Hades for Windows and install the original [HadesCoopMod v0.4.3](https://github.com/TheNormalnij/HadesCoopMod/releases/tag/v0.4.3), following its installation instructions. This repository is an **overlay**, not a standalone installer: it requires the original mod loader and dependencies.
2. Close Hades, back up your saves and existing mod folders, then copy the contents of [`package/`](package/) into your Hades game directory, merging `Content/Mods` and replacing matching mod files. To undo, restore those backed-up mod folders.
3. Start the game using your existing co-op launcher, choose **Select gamemode → Coop**, select 1–4 players, and assign a different controller to each player. Only P1 may use keyboard and mouse. Start with a separate co-op save. For remote play, allow your friends' gamepad input through Parsec on the host PC.

## What this experiment adds

- Selection and control assignment for up to four players.
- Player labels and colored outlines.
- Next-chamber revival when a teammate survives.
- A **Revive P1** pause-menu recovery button when P1 is dead and an ally is alive; revival is deferred until the pause menu closes.
- Shared gold scaled by **2 × selected player count**: with four players, a base gain of 100 adds 800 to the shared balance. This is one shared wallet, not separate wallets.
- Changes to shared healing, shop behavior, survivor rewards and startup ordering.

## Status and limitations

Experimental personal build, based on the October 20, 2026 v3 work. Lua regression tests check isolated behavior with simulated game functions. They do **not** establish that a full run, every encounter, every controller configuration or every storefront works.

The latest startup/gold and recovery changes have not been confirmed in a real multiplayer session. The native recovery hook targets the Steam engine layout and may not activate on other builds. Recovery cannot recreate rewards already lost; use it before the remaining players finish combat. Crashes, progression problems and balancing issues may still occur.

This is local shared-screen co-op streamed through Parsec when needed. It does not implement independent network clients, Steam invites or a relay. No Hades game files, saves, personal paths or Parsec binaries are distributed here.

## Source, tests and customization

See [DEVELOPING.md](DEVELOPING.md). The `source/` folders contain the mod component sources used by this overlay. `upstream.json` records the original revision for each component, and `package-sha256.json` lists the packaged file hashes.

## Credits

- **Uladzislau “TheNormalnij” Nikalayevich** and upstream contributors: the original [HadesCoopMod](https://github.com/TheNormalnij/HadesCoopMod), [HadesMainMenuApi](https://github.com/TheNormalnij/HadesMainMenuApi), and mod ecosystem that make this possible. This project extends their work; it does not claim to have created the original multiplayer mod.
- **cranebeaker and the COOP Anything contributors**: the [COOP Anything playbook](https://github.com/cranebeaker/coop-anything), inspiration and repository presentation references: [Deus Ex](https://github.com/cranebeaker/deus-ex-coop), [Fallout: New Vegas](https://github.com/cranebeaker/fnv-coop), [Ocarina of Time](https://github.com/cranebeaker/ocarina-coop), [Dungeon Keeper](https://github.com/cranebeaker/dungeon-keeper-coop), and [S.T.A.L.K.E.R.](https://github.com/cranebeaker/stalker-soc-coop-fixes). This is an independent personal project, with no claim of official membership or endorsement.
- **Supergiant Games**: Hades and its game assets. Players must supply their own copy.
- **Lua authors, Electronic Arts/EASTL, The Forge contributors and other upstream dependency authors**: see the preserved notices in [`licenses/`](licenses/).
- **Yarmungandr**: I mean, I did something, rigth lol
- **Parsec**: optional remote input and streaming software, obtained separately.

## License

MIT for this mod code and personal additions; see [LICENSE](LICENSE). Original copyright notices are retained. Dependencies retain their own licenses in `licenses/`. The license does not grant rights to Hades or third-party services.
