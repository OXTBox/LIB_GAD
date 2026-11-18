# GAD battles: where step 2 stands

Wednesday, November 18, 2026, Opus (helper session). Branch `gad-battles` in LIB_GAD.
Spec: `LIB_LLMOUT/LIB_GAD/BATTLES_PLAN_for_review.md`, "Step 2: the smallest loop" (approved 18 Nov).
No engine touched: game rules plus a plain 2D map.

## Done

| File | What |
|---|---|
| `gad_battles_rules.livecodescript` | the rules, a library (`GADB.*`), no window, no answer/ask: records b_ m_ s_ r_ a_, factions 1 Cyan / 2 Green, the turn, the fight |
| `gad_battles_ui.livecodescript` | the map card (`GADUI.*`): rects, squares, X marks, lines, sparks, a result word, a status bar |
| `gad_battles_stack.livecodescript` | the stack script: it only loads the two files above (from the stack's own folder) and starts a game; closeStackRequest frees the stack (LIB_ALPHA 12b) |
| `GAD_Battles.oxtstack` | the stack to open: cards Map and About; title `Opus \| GAD_Battles` |
| `tools/build_stack.txt` | rebuilds the stack headless (only needed if the loader or the About text changes) |
| `tests/t_gad_battles.txt` | the headless test: 74 checks, seeded; writes only in `tests/_work` (git-ignored) |

The rules, as built:
- A Base adds its **production** to its **assembly** each turn; at 100 it builds **one unit**, which leaves
  on its own for the Base's **send-to** (at first the Base itself: its units stay home and guard it).
- **Send-to** = a Base, a rendezvous X, a unit or squad (yours or theirs), or any point you click.
  Sending something to itself = stay / wait there. A unit inside a squad gives its order to the squad.
- **Squads form by themselves** at the start of a turn: same team, same place, and either both waiting
  or both on the way to the same send-to. A lone unit joins an existing squad.
- **Travel** `travel=slowest` (the only mode): a squad moves at its slowest member's speed;
  `turnsLeft` = distance / speed, rounded up.
- **The turn (ENTER)**: squads form, Bases build, everything moves one turn closer, detection ticks,
  the computer moves.
- **The fight** (`GADB.Fight`, one handler, four knobs at its top): each side's total power x personnel
  (damaged members count less; a Base adds a guard of 10 x level as one more member), the faster side
  x1.15 (first strike), a seeded die x(1 +- 0.10). The loser's damage grows round by round until it breaks;
  the winner takes a share but is never broken by it. Result: **TAKEN / HELD** at a Base (owner changes or
  holds), **WON / LOST** against a unit or squad. Arriving at an enemy X is no fight (only a place).
- **Detection** 0..4 of each Base not yours: +1 a turn while one of your Bases or units is within 200;
  otherwise every (6 - signature + suppression) turns. Grey until 1; the label shows more at 2 (minions),
  3 (level), 4 (how many inside).
- **The computer**: a Green Base whose garrison has grown to 4 sends it to your nearest Base.

## How to open and play it

Open `LIB_GAD/battles/GAD_Battles.oxtstack` in OXT-Beyond (the three `.livecodescript` files must stay
next to it). Then:
- Click your **Cyan Base**, then click where its units go (a Base, an X, a unit, any spot).
- **U**, then click the map: drops a rendezvous **X**. Send your Base to the X: units gather there.
- Click a **squad** (the bigger square, with its count), then click the grey/Green Base far up right.
- **ENTER** ends the turn. Sparks and a word mark a fight. Right-click or Esc cancels; **N** new game;
  **A** the About card.

## What to try (and tell me)

1. Gather 3 at an X and attack early, then try waiting for 5: does the fight feel right? (The anomaly's
   Base grows its garrison; in the test, 3 attacking a garrison of 5 is always HELD.)
2. Watch the computer: once it has 4 at home it comes for your Base. Leave your Base empty (all units
   sent to the X) and see what happens.
3. Is the map readable: colours, labels, the turns-left numbers on your moving units?

## Test results (headless, OXT-Beyond engine)

`flock /tmp/oxt_headless.lock python3 -I ~/projects/OXT-BEYOND/tests/oxt_headless.py ~/projects/LIB_GAD/battles/tests/t_gad_battles.txt`
74 PASS, 0 FAIL (plus 3 PASS in `tools/build_stack.txt`). INFO lines worth knowing:
- The main loop (seed 42, computer passive): 3 at the X reach the anomaly's Base and are
  broken: HELD, 101 against 320 (5 inside + the Base). Seeds 1..20: all HELD.
- The same loop with the computer active (aiAttack 4): all 20 seeds TAKEN (its garrison was out attacking you).
- An even fight, 3 agents against 3: the attacker won 10 of 20 seeds (the die decides). Same squads, the
  attacker faster: 20 of 20 (first strike x1.15 outweighs a 10% die).
- The card, played by its clicks and keys: TAKEN at turn 16.

Not tested: anything with a real window or a real mouse (the test calls `GADUI.Click` and sends keys).
The first look in OXT-Beyond is the owner's.

## Things to know

- Power x personnel is the square law: numbers count twice, so a garrison that keeps growing is hard to
  take, and first strike decides close fights more than the die. The four knobs at the top of
  `GADB.Fight` are where to tune.
- The library's stack name is `gad_battles_rules`; it must not be `gad_battles` (stack names ignore case,
  so it would collide with the stack `GAD_Battles`: a real bug found and fixed in testing).
- xTalk trap found: local names `tHere` and `tAN` are `there` and `tan` (case-insensitive) and do not compile.
- Headless, closing a stack deletes the library only at idle: the test closes last.

## Suggested step 3

1. A Base panel: production desire and spending (Galactica's production / research money), level growth.
2. More Bases on the map (several anomalies, each its own level and minion kind), neutral grey ones to take.
3. "Imminent danger": warn when an enemy squad is a few turns from your Base (the music cue later).
4. The travel-speed tests the owner asked for (`travel=fastest`, teleporter, jet), as settings.
5. Names from LIB_LISTS by name.
