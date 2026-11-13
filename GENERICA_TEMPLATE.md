# Generica: the reusable game template

Friday, November 13, 2026. Claude (Opus 5.5), from the XTJSON harvests of the 2026-11-13 batch
(`~/projects/XTJSON/batch/GenericaProperties_02042024A/…`, `XTJSON/newest/`). LIB_SYSTEM TODO A-12.

## What it is

The owner's words: GenericaProperties is based on the **Galactica Anno Dominari** source: an
application template with every option and field a game developer fills in, meant to be
reusable. Its saved text files are the variable labels. The harvest confirms it: the stack holds
no game, only a **schema of a game's words**, and the tools to edit, save and load it.

| | |
|---|---|
| Newest build | `GenericaProperties_03182026a.livecode` (named 2026-03-18, last saved 2026-05-11) |
| Lineage | GenericaAnyData_04042018a (2018) → GenericaProperties_02042024A → Day_2 … Day_2_Part6 (Feb 2024) → Day_3_Part1 → 03162026a → 03172026a/b → 03182026a |
| Not this line | `GAD_WORKING_03_16_2026` is the GAD game itself (6,051-line stack script, 312 handlers, 178 described globals): see `GAD_ESSENCE_AND_VARIABLES.md` §5 |
| Size of the template | 37 categories (custom property sets on card 1), 637 labels |
| Data changes since Feb 2024 | none to speak of: Day_2_Part6 and the 2026 builds hold the same 37 categories and 640 labels (the newest drops 3) |
| Code changes in 2026 | the hard-coded `defineGamePropertyArrays` became **`ImportGamePropertyArrays`** (labels load from the text files) and `make_example_sets`; drag/reposition helpers went |

## How it is built

- Each **category** is a custom property set on the card, holding one array per label list:
  keys `001`, `002`, … and a `description` saying what the list is for. Each value is
  `N.[label text]`.
- Labels are **fill-in templates**, Galactica-style: `You took the star system % from #!`,
  `Receiving Data for Turn ^0`, `^1, Prepare for Turn ^0.` (`%`, `#`, `*`, `^0`, `^1` are slots).
- `writeOutlineToFiles` / `writeUIPropertiesArraysToFiles` save every list as text: those are the
  393 small `.txt` files in the batch folders (`property_descriptions`, `game_unit_types`, …).
  `ImportGamePropertyArrays` reads them back.
- `BuildGlobalInit`, `insertGlobal`, `initNewGlobals`, `filterStackScriptForGlobals`,
  `getAllCurrentGlobalValues`: the stack also **writes LiveCode globals** for the template and
  inits them in its own stack script. This is the seed of LIB_GLOBALS (TODO A-35).

## The 37 categories, grouped

| Group | Categories (labels) |
|---|---|
| **Game state** (the part GAD plays) | unit_types (starship, fleet, colony, rendezvous point), unit_properties (Course, Position, Tech, Ship Completion, Growth, Ships, Population, Damage, Speed, Power, Build, Send to…), unit_ownership (Computer, unowned, you, the *…), factions (10), locations (104), difficulty (Expert … Novice), update_sequence (Computer Players → Human Players → Objects in Galaxy) |
| **Messages** | events (46 templated), messages: victory, defeat, level_up, new_unit, network_turn (9) |
| **Interface** | main_ui, ui_labels (34), button_labels (70), info_panels, map_view_toggle (Galaxy Map / System / Ship / Fleet), toolbar, menus (file, edit, undo/redo standard and drag, build, lobby), symbols (roman numerals), themes |
| **Players and network** | chat, login_errors (13), lobby menu, store (payment window 23, purchase URL) |
| **Packaging** | description (49), credits, copyright, files, languages, music, sounds, plugins (docs, fonts), preferences, scripts, tutorial, update_messages, art |

## How it maps onto Galactica-4 (`GAD_ESSENCE_AND_VARIABLES.md` §2)

| Generica | Galactica-4 variable (GAD name) |
|---|---|
| unit_types: starship / fleet / colony / rendezvous point | 2.7 Ship (Agent) / 2.8 Fleet (Squad) / 2.5 Star (Node) / 2.9 Rendezvous (Staging point) |
| unit_properties: Course, Position, Send to | 2.10 Course |
| unit_properties: Tech, Growth, Population, Build, Ship Completion | 2.6 Allocation (Slider): the state transformer |
| unit_properties: Damage, Speed, Power | 2.7 Ship stats |
| unit_ownership, factions | 2.4 Player |
| difficulty | 2.3 Rules / 2.14 AI |
| update_sequence | 2.13 Turn pipeline |
| events, messages | 2.11 Event |
| map_view_toggle (Galaxy / System / Ship / Fleet) | 2.12 Visibility and the views |

So Generica is the **words layer** of the same model GAD_WORKING plays: the variable names a game
shows, organised so a developer can rename the whole game (space war → genetic anomalies → any
"*X" game) by editing labels, not code.

## What to do with it (proposals, for the owner)

1. **Make it a LIB:** the 37 categories as plain text files (they already are) with a small loader
   every engine uses: Vibecode3D, xt3d and the Sequencer's `{var}` filling. A game = its label files.
2. **Thrmnlra and PROMPT_GLAZE** would take their UI words and event strings from it; the
   templated events (`% from #`) match what the Sequencer's `{name:filter}` already does.
3. **Genetic Anomaly Detector:** a second label set over the same categories (units → squads,
   stars → nodes, Tech/Growth/Population → the sliders of a genetic system).
4. **LIB_GLOBALS:** start from GAD_WORKING's 178 described globals and Generica's global builder.
5. The `.txt` label files in the inbox are this template's data: keep one copy (the newest build's
   folder), move the duplicates to `LIB_LLMOUT/Read`.
