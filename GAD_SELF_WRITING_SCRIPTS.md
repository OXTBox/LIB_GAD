# GAD: code as data, and a stack that rewrites its own script

Friday, November 13, 2026. Claude (Opus 5.5), from the XTJSON harvests of `GAD_WORKING_03_16_2026`
(its stack is still named `GAD_WORKING_02_04_2026`) and `GenericaProperties_03182026a`, with the
owner's notes while reading: "it can modify the working stack with file uploads", "stack script
specifically", "the blocks give the developer quick access to categories of code in the UI".

## The idea

In GAD, code is **material**: handlers and functions are kept as text in custom properties and in
the scripts of other objects, cut into categories, shown to the developer as buttons, stamped onto
game objects, and written back into the **stack script** itself. The stack edits its own source
while it runs.

```
            files on disk ───ImportGamePropertyArrays───▶ custom property sets (game_*)      [Generica]
                                                                    │
clipboard word ──insertGlobal──▶ STACK SCRIPT ◀──BuildGlobalInit────┘ (globals + initNewGlobals)
                                    │   ▲
       CollectScriptToBlocks        │   │  appendInitNewGlobals / ops.addErrorCodesToStackScript
   (split by handler-name prefix)   ▼   │  (rewrite and SET the script of this stack)
     group "scriptBlocks": one button per category (Clear, Global, Init, Set, Get, UI, Base, Mobile,
     GameObject, Math, Turn, ...) = the developer's palette of code categories
                                    │
     CollectAllscriptBlockContentToCustomProperties
                                    ▼
     custom property sets: scriptBlocks (sb_<category>, with BEGIN/FINISH markers and dates),
     BlockHandlers / BlockFunctions (one entry per handler)  ◀─compare─▶  StackHandlers /
     StackFunctions (StackScriptToCustomProperties)          compareScriptBlocksToCurrentStackScript
                                    │
     gBaseScriptText / RENDEZVOUS_OBJECT_SCRIPT ──set the script of the templateGraphic──▶
     every base graphic gets the same script (53 identical object scripts in the harvest)
```

## The parts

| Part | Where | What it does |
|---|---|---|
| **Script blocks (the palette)** | group `scriptBlocks`; `CollectScriptToBlocks`, `ExtractStackScriptToButtons`, `OrganizeScriptBlocks`, `UI.ToggleScriptBlocks` | Splits the stack script by handler-name prefix (first `Clear, Global, Init, Define, Set, Get, Create, Adjust, Update, Refresh`, then `UI, Base, Mobile, GameObject, Math, String, List, Menu, Mouse, Player, RawKey, Select, Toggle, Tool, Turn, Utility, View, Script`) into one button per category, laid out in rows: quick access to a category of code from the window |
| **Blocks to properties** | `CollectAllscriptBlockContentToCustomProperties` | Stores each block in set `scriptBlocks` as `sb_<category>` with `##--!!!!BEGIN_ScriptBlockButtonScript @ name` / `FINISH` markers and dates; indexes every handler and function into `BlockHandlers` / `BlockFunctions` |
| **Stack script to properties** | `StackScriptToCustomProperties`, `compareScriptBlocksToCurrentStackScript`, `ops.checkScriptForDuplicateFunctions` | The same index for the live stack script (`StackHandlers` / `StackFunctions`), compared with the blocks to find what drifted |
| **Globals into the stack script** | card `insertGlobal` / `appendInitNewGlobals` (stack copies `SCRIPT_CARD_*`, marked "maybe deprecated 1-28-2024") | A one-word clipboard becomes `global <name> -- <date time>` at the top of the stack script; its init value (asked) is inserted into the script's own `initNewGlobals`; then `SET the script of this stack` |
| **Global init builder** | Generica `BuildGlobalInit`, `filterStackScriptForGlobals` | Scans the `global` lines and writes `initNewGlobals` with defaults by prefix: `b` → false, `i` → 1, `f` → 0, `s` → its own name, else empty; an ignore list sits in a card property |
| **Instrumenter** | `ops.addErrorCodesToStackScript` | Rewrites every handler with a numbered trace line `ops.setDebug ("00025 Name" && args)` and `put "" into gErrorIndent`: the source of the codes seen throughout |
| **Object scripts from text** | `gBaseScriptText`, `GameObject.initBaseScriptText`, `GameObject.refreshAllBaseScripts`, `init.RendezvousScript` | Script text kept in globals/properties is stamped onto bases, rendezvous points and ships through the template graphic |
| **Code run from text** | `clearGameObjectSelection` and others: `do tScript` | Builds `put "" into g<Type><Prop>` lines for every game-object property and runs them |
| **Data in property sets** | `BaseData`, `PlayerData`, `PathData`, `Proximity`, `ProwlerData`, `GameScript` | The game state itself; read and written with `do "put the" && <name> && "of this stack ..."` |
| **Files in** | Generica `ImportGamePropertyArrays` | A folder tree of label files becomes `game_<folder>` property sets on the card |
| **Files out** | card `extractUI` | Every control's script and properties to `Documents/UIEX/<stack>/` (JSON for arrays) |

## Things found while reading (bugs and traps)

| Where | What | Effect |
|---|---|---|
| `insertGlobal` (both copies) | checks `tWord is among the items of the globalNames`; `tWord` is never set | the duplicate check never fires: the same global can be inserted twice |
| `CollectAllscriptBlockContentToCustomProperties`, `StackScriptToCustomProperties` | `if CurrentFunction is empty` (not `tCurrentFunction`) | always false: empty chunks are stored |
| same | `lineOffset("end" && name, script)` | matches the first line *containing* `end Game`, so `end GameObject.x` can end `Game` early: handlers with a shared prefix get cut wrong |
| same | `set the customPropertySet ... to StackFunctions` / `BlockkHandlers` without quotes | works only because an unset variable reads as its own name; breaks under `explicitVariables`; `BlockkHandlers` is a typo used consistently |
| the 178 "described" globals | many descriptions are timestamps (`1/27/24 8:21:10 PM`) written by `insertGlobal` | when the global was added, not what it is for |

## What to carry forward

1. **The palette is a keeper.** Categories of code by handler prefix, one click away, is how the
   owner wants to work. LIB_XTJSON's harvest already splits scripts per object and lists handlers;
   a **script-block browser** stack over a harvest (or a live stack, through LIB_MCP) would give the
   palette to every project without the stack rewriting itself.
2. **Keep the rewriting outside the running game.** A stack that edits its own script is powerful
   but fragile (the bugs above). Move the tools (globals insertion, instrumenter, block compare) into
   a developer library that edits *other* stacks or script files, with a backup before each write.
3. **LIB_GLOBALS** (TODO A-35): start from Generica's prefix convention (`b`/`i`/`f`/`s`), the
   `global_prefix_ignore_list`, and GAD_WORKING's globals, with real descriptions instead of dates.
4. **Script text as data** (`gBaseScriptText`, the stamped base scripts) is the same move as the
   Sequencer's clip kinds as behaviours: one script file, many objects. Behaviours avoid 53 copies.
5. **The error codes** (`ops.setDebug "00025 ..."`) are a tracing system worth keeping as a library
   switch, not as text stamped into every handler.
