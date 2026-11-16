# Genetic Anomaly Detector (GAD)

Monday, November 16, 2026. Moved here from LIB_GAMES (branch `ga-turns`, the version you played)
on the owner's word: LIB_GAD is the Genetic Anomaly Detector's home, a long-term project.

- `Vibecode3D_Play_GeneticAnomaly.livecodescript`: the current prototype (turn based, ENTER ends
  the turn; each town's focus recruit / research / train; 64 towns on a big map to scroll and
  zoom). Its words come from LIB_GENERICA (`GA.GenRoot`, the Game.FindFile order).
- `../ui/GenericaAnyData_04042018a/`: the owner's GUI work of April 2018 based on Galactica 3
  (the XTJSON harvest of that stack: MapStack, 21 scripts, 3 images). GAD's own UI continues
  from it rather than starting over.

## The owner's direction (16 Nov 2026)

- GAD needs a custom UI of its own, not the game launcher (the launcher is for games only).
- Build it on the Galactica 3-based GUI above, so each new "vehicle" doesn't reinvent the wheel.
- Background: `../GAD_ESSENCE_AND_VARIABLES.md`, `../GAD_SELF_WRITING_SCRIPTS.md`,
  `../GENERICA_TEMPLATE.md`.

Not done yet: a stack of its own to open it (it still plays as a Vibecode3D card script).
