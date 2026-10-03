# WoWDoom

Doom running inside a World of Warcraft addon.

The engine is a hand port of id Software's linuxdoom-1.10 to plain Lua 5.1. It uses floats instead of fixed point, and a renderer that draws with ordinary WoW textures:

- **Walls and sky** are one texture strip per screen column.
- **Floors and ceilings** are one strip per horizontal span, with texture coordinates interpolated along the span.
- **Sprites and masked mid-textures** are quads clipped into column runs, each on its own frame level so they sort back to front.

It ships with [Freedoom](https://freedoom.github.io/) Phase 1 (all 36 maps).

## Installing

1. Download `WoWDoom-v0.1.1.zip` from the [latest release](https://github.com/petllama/WoWDoom/releases/latest).
2. Unzip it and copy the five folders (`WoWDoom`, `WoWDoom_E1` .. `WoWDoom_E4`) into `World of Warcraft/<flavor>/Interface/AddOns/`.
3. Enable WoWDoom in the AddOns list, log in, and type `/doom`.

Everything the game needs is in the zip. The release also has `freedoom1.wad`, the original Freedoom data it was built from, if you want to rebuild the assets yourself.

## Building

Requirements: Python 3, `ffmpeg` (for sound conversion), and a copy of the linuxdoom source (for the state/thing tables).

```sh
# 1. get Freedoom and id's source
curl -LO https://github.com/freedoom/freedoom/releases/download/v0.13.0/freedoom-0.13.0.zip
unzip freedoom-0.13.0.zip -d wad
git clone https://github.com/id-Software/DOOM.git ref/DOOM

# 2. convert the WAD into textures (TGA), sounds (OGG), maps and info tables
python tools/build_assets.py wad/freedoom-0.13.0/freedoom1.wad build/WoWDoom ref/DOOM/linuxdoom-1.10

# 3. copy the Lua sources in
sh tools/deploy.sh
```

Then copy `build/WoWDoom` and `build/WoWDoom_E1` .. `WoWDoom_E4` into `World of Warcraft/<flavor>/Interface/AddOns/`.

The `WoWDoom_E*` addons hold the map data and load on demand when you enter an episode.

## Playing

Type `/doom` in game.

| Action | Keys |
|---|---|
| Move | W / S |
| Strafe | A / D |
| Turn | arrows or Q / E, or hold right mouse and drag |
| Fire | Ctrl or left click |
| Use | Space or F |
| Weapons | 1 – 7 |
| Walk (always-run is on) | Shift |
| Pause | P |
| Automap | Tab or M (zoom with + / - or mouse wheel) |
| Menu | Esc |

Slash commands:

- `/doom size <400-1600>` sets the window width.
- `/doom detail high|low` switches between 320 and 160 render columns.
- `/doom sens <n>` sets mouse turn speed.
- `/doom run` toggles always-run.
- `/doom sound` toggles sound effects.
- `/doom fps` shows an FPS counter.
- `/doom warp e1m5 [skill]` jumps to a map.

## Testing offline

`tools/mock_wow.lua` is a small mock of the WoW UI API plus a software rasterizer for the textures it creates. It lets the real addon code run and take screenshots under LuaJIT:

```sh
export WOWDOOM_ADDONS="$(pwd)/build"
luajit tools/test_specials.lua   # every map, doors, lifts, exits, death/respawn
luajit tools/test_game.lua       # scripted play with screenshots in shots/
luajit tools/bench.lua 1 high    # per-frame cost
```

## Not implemented

- Music
- Save/load
- Distance-based sound volume. Distant sounds are culled instead, because WoW can't set per-sound volume.

## License

The game code is derived from id Software's Doom source and is licensed under the GNU GPL v2 (see `LICENSE`). Freedoom assets are BSD-licensed. The Freedoom WAD and the generated assets are not stored in this repo.
