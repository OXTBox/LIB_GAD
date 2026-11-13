# LIB_GAD — Essence & Variable Inventory

Captured 2026-11-12 from `galactica-4-main/` (Ed Zavada's Galactica-4, JS on the PDG engine,
MIT-licensed code) and the sample save `Galactica Game.gad4.json`.
Purpose: list everything Vibecode3D / xt3d must mirror, then map it onto
**GAD = Generic Any Data** and our game, **Genetic Anomaly Detector**.

---

## 1. Essence (what Galactica actually *is*, under the space paint)

Galactica: Anno Dominari is a **4X game played as one simple loop**:

1. A board of **nodes** (stars). Each has a position, an owner, a population and a tech level.
2. Each owned node splits 100% of its output across **three allocation sliders**:
   growth, research and building. Each slider moves toward its *desired* value at a set *rate*.
3. Building produces **agents** (ships). Agents have power, speed, stealth and scanner range,
   and follow **courses** (waypoints, loop, patrol, hunt).
4. **Detection is a formula, not a yes/no:**
   `visibility = (target.apparentSize × observer.scannerRange) / (distance × target.stealth)`
   and the result falls into tiers: NONE < SPEED(25) < TECH(35) < CLASS(75) < DETAILS(200).
   You can see that *something* is there long before you know what it is.
5. Agents meeting at a node trigger **combat**, which is resolved in rounds with damage rollover and reserves.
   Taking a node changes its owner.
6. **End Turn** runs a fixed pipeline: production, then movement, then combat and capture,
   then fog-of-war refresh, then reports, then a victory check.
7. **AI** scores each possible move with a 34-factor × 5-choice weight matrix for each ship type
   (to our star / enemy star / other star / ship / form fleet).

**The GAD reading:** any system whose state changes each turn fits this shape. You need
nodes holding stocks, sliders that steer production, agents that move and observe,
partial observability with confidence tiers, a pass that resolves conflicts, and
an event log. Galactica is one *skin* on that loop, and Genetic Anomaly Detector is another.

---

## 2. Variable inventory (what we parrot)

Field names are kept exactly as they appear, so save files stay readable on both sides.

### 2.1 Game (root of the save graph)
| Field | Sample | Notes |
|---|---|---|
| config, rules | ref | see below |
| players[] | 1-based, [0]=null | |
| stars[] | 425 in sample | the nodes |
| allShips[], allFleets[], allRendezvous[] | | agents, groups, staging points |
| turn | 1 | |
| gameWidth, gameHeight | 800, 600 | view size |
| isGameOver, postGame, winningPlayerNum, victoryTurn | | outcome |
| eventLog[], nextEventId, eventSelection, eventPage, eventDetailPage | | event list |
| heldReports[], holdGameReports, overlay, overlayQueue[] | | report presentation |
| turnAttentionPending, turnPreviousSelection, attention{} | | "needs your attention" queue |
| selectedObject, uiWindow | | UI state |
| showGrid, showNebula, showShips, showAllCourses, showCourierCourses, showScannerRanges, showMapNames, showEnemyEvents | bools | map layers |
| mapDisplayMode | "ownership" | map display mode |
| chart{names,pool,numerals} | | star-name generator |
| aiSkills{}, tutorialRandom | | |
| camera{zoom, panX, panY} | 1, 1434624, 345088 | world coordinates are ×1024 |

### 2.2 Config
`gameTitle, humanPlayerNames{}, numHumans, numComputers, totalPlayers, density, sectorSize,
compSkill (1–5), compAdvantage (−3..+3), aiSkillByPlayer{}, fastGame, omniscient (fog off),
endEarly, maxTimePerTurn, hosting, skipMapGeneration,
autoplay{enabled, seed, turnDelayMs, maxTurns, eventPresentationMs, showEventWindows}`

### 2.3 Rules (the tunable constants)
| Name | Value / formula |
|---|---|
| isFast | doubles speed, scan range and build rate |
| shipClasses | frigate, destroyer, cruiser, battleship, colossus (one per 5 tech levels) |
| maxPopP / growthLimit | 16 / 4 (pop growth curve) |
| scanRange(tech) | (tech + 7) × 1500, ×2 if fast |
| starAttack | floor((log10(pop×1000)² × 5 − 50) × tech) |
| starRepair | 35 × tech |
| shipBuildingAmount | shipBuilding.benefits / 1665 (×2 fast) |
| research | round(value×10) × perUnitBenefit / (9 × tech) |
| buildCost | defense 0.4+t/6 · scout 0.1+t/8 · colony 4+t/2 · battleship 1+t/2 |
| speed | (floor(t/5)+1)×10 + t%5, colony ×0.75, scout ×1.5, defense 0; then ×1000 |
| stealth | scout 4, everything else 1 |
| ship scanner | scout 0.8 × scanRange; others 0 |
| power | = techLevel (scout 0) |
| scrap value | buildCost / 4 |
| patrol bonus | +25% attack when docked and on patrol |

### 2.4 Player
`playerNum, name, isHuman, isComputer, isAlive, isLoggedIn, password,
homeStarId, techStarId, hasTechStar, hiStarTech, hiShipTech,
builtColony, builtScout, builtSatellite, builtFighterClasses{set},
numPiecesRemaining, lastTurnPosted, compSkill, compAdvantage,
defaultBuildType, defaultGrowth/defaultTech/defaultShips (334/333/333 = thirds of 1000)`

### 2.5 Star (= **Node**)
`id, x, y, name, namedStar, owner, population, techLevel,
growth / research / shipBuilding : Allocation,
currentShip{type, techLevel, progress, cost}, paidTowardShipBuilding, buildCredits{}, unassignedShipCredit,
paidTowardResearch, ships[], defenseSatellites[], damage, defaultDestination,
scannerRange, stealth, apparentSize, visibilityTo{}, lastSeen{}, lastSeenBy{}`

### 2.6 Allocation (= **Slider**, the core state transformer)
`value, desired (0–100, 0.1 steps), rate (how fast value moves toward desired each turn), benefit (per unit), locked`

### 2.7 Ship (= **Agent**)
`id, name, type (scout|colony|battleship|defense|satellite), classIndex, owner, techLevel,
power, speed, damage, x, y, star (docked at), fleet, destination, course, onPatrol,
progress, toBeScrapped, userCallIn, lastCallInTurn,
scannerRange, stealth, apparentSize, visibilityTo{}, lastSeen{}, lastSeenBy{}`

### 2.8 Fleet (= **Squad**) adds
`ships[], totalPower, totalSpeed, totalDamage, moveDelta, remainingDistance`

### 2.9 Rendezvous (= **Staging point**)
`id, name, owner, x, y, anchor, fleet, scannerRange, stealth, apparentSize, visibility fields`

### 2.10 Course
`owner, waypoints[], current, previous, hasOrigin, loop, hunt, memory, revision`

### 2.11 Event
`id, title, message, subject, position, recipient{}, handled, createdAt` + type codes in `common.js`

### 2.12 Visibility
`VisibilityLevel: NONE 0, SPEED 1, TECH 2, CLASS 3, DETAILS 4`
`Thresholds: SPEED 25, TECH 35, CLASS 75, DETAILS 200`, default stealth 1, default size 100.
Each entity keeps its tier for each player (`visibilityTo`) plus the last seen turn and who saw it (`lastSeen`, `lastSeenBy`).

### 2.13 Turn pipeline (`game.js` endTurn)
production / research / growth → moveAllShips → combat and capture → rendezvous refresh →
observer reports → piece counts → victory check → event windows

### 2.14 AI
`ai-decision-matrices.js`: for each ship type, 34 situation flags × 5 targets of integer weights
(e.g. scout: "no nearby unowned star" −90 to OtherStar). This lifts straight into xTalk as data tables.

---

## 3. Mapping to Genetic Anomaly Detector

| Galactica | Genetic Anomaly Detector | Notes |
|---|---|---|
| Star | **Site** (city / region / population center) | population = people; techLevel = local "gene-expression index" |
| Star owner | Faction controlling the site | your institute, rival orgs, rogue anomalies |
| Allocation growth / research / building | **Recruit / Research / Train** | research raises detector tech |
| Ship scannerRange | **Detector range** | the big psychic-scanner rig is a stationary, huge-range scanner at HQ |
| stealth | **Anomaly suppression** | strong anomalies hide (stealth 4+) |
| apparentSize | **Anomaly signature strength** | powers in active use spike it |
| Visibility tiers | **Detection confidence** | SPEED → *pinpoint blip*, TECH → *faction known*, CLASS → *power class*, DETAILS → *identified* |
| Scout | Sensitive / field telepath | cheap, stealthy, extends detection |
| Colony ship | Outreach team | turns a neutral site into a safe house |
| Battleship classes | Strike-team tiers | 5 tiers by tech |
| Defense satellite | Safe-house defenses | |
| Fleet / Rendezvous | Squad / Mission staging point | |
| Course hunt / patrol | Pursue / Patrol orders | |
| Combat at a node | **Drop into the tactical layer** | the strategic map hands off to turn-based 3D vector combat; the result returns as damage and a capture |
| Event log | Case files | |
| AI decision matrix | Anomaly behavior tables | anomalies flee, hide, recruit or attack |

**The hook:** the strategic map shows only pinpoints until confidence rises. GAD as a framework is
§2 with the nouns swapped; GAD the game adds the second, tactical layer that Galactica never had.

---

## 4. Notes for the pitch / port

- **Rights:** the code is MIT (© 2025-2026 Ed Zavada). The art belongs to **Claudio Berni** and is
  *not* cleared (see `ASSET_RIGHTS.md`), and the sounds come from the v3 bundle. We parrot rules and variables,
  not the assets, and vector graphics avoid the art problem entirely.
- **IP:** "Professor X / Cerebro / X-Men" is Marvel's. Use our own names in anything we pitch.
- The v3 C++ source sits in a sibling repo (`galactica-anno-dominari-3`) that is **not** in LIB_GAD.
  Worth fetching, because it is the ground truth the JS port cites.
- The save format (`format:"Galactica-4", graph.nodes[] {type, properties[[k,v]]}, {ref:n}`)
  is easy to parse from Python or xTalk, so an xTalk reader can load Ed's saves directly.
- Large files: `game.js` (4.3k lines) and `display.js` (4.3k lines). Port the rules from
  `rules.js`, `combat.js`, `visibility-calculator.js`, `star.js`, `ship.js`, `fleet.js`, `course.js`,
  `ai-*.js` and `map-generator.js`. Skip the network, hosting, tutorial and i18n code at first.

---

## 5. Our xTalk version (`GAD_WORKING_03_16_2026.livecode`)

Harvested 2026-11-12 with LIB_XTJSON through the LIB_MCP standalone, to
`~/projects/XTJSON/GAD_WORKING_03_16_2026/`. The stack is named `GAD_WORKING_02_04_2026` inside the file.
It has 1 card and 92 controls (57 graphics, of which 52 are the bases `b_001..b_052`, plus 14 buttons, 9 fields, 8 images and 4 groups).
The engine is the 6,051-line stack script, with globals dated Jan–Feb 2024.

### 5.1 The game-object record (one comma-separated item list per object)
`ID, type, x, y, parent, build, assembly, population, production, prudence,
civilization, motivation, education, level, life, sendto`. The item positions are stored in the `<name>Item` globals.
Objects are labelled `b_001` (base), `m_001` (mobile), `p_001` (its path), plus `d_` / `s_` / `e_` / `o_` for mobile classes.
Object types: `base, defense, service, expand, offense, rendezvous, SendTo, map, centerXY, slider, UI`.

### 5.2 Stored data (stack custom property sets)
| Set | Contents |
|---|---|
| BaseData | 52 bases, keyed `b_NNN`, each a 16-item record (neutral bases have life = population) |
| PlayerData | for each player, the bases they own (Player1 owns `b_047`) |
| Proximity | for each base, its neighbours sorted by distance |
| PathData / MapData / EventData | mobile paths, arrivals at each map cell, event messages |
| GameScript | generated script snippets |

### 5.3 Turn rules (`Turn.Finish` → `Turn.Base` → `Turn.PlayerBaseUpdates` → `Turn.Mobile`)
- **Sliders → states:** the population, production and prudence sliders are goals (1–33, rebalanced by `UI.AdjustSliders`).
  Each turn civilization, motivation and education move **3 steps** toward their goals (`Base.IncrementGoals`).
- **Level:** `level += max(0.025, education × 0.0055)`
- **Assembly:** `assembly += 1 + production × 0.15 + life × 1.23e-11`. When assembly + motivation × 0.15 passes 100,
  it resets to 1, a mobile of type `build` is created, and the AI goals adjust.
- **Life:** `life = floor(life + population)`
- **Mobiles:** each step one point along a path, travelling toward `sendto`. Arrivals are logged to MapData and EventData.
- Player base defaults: build 2, assembly 95, sliders 15/15/15, states 16/16/16, level 1, life 99,999,999,999.

### 5.4 Ours ↔ Galactica
| Ours | Galactica | Notes |
|---|---|---|
| base | Star | |
| population / production / prudence sliders | growth / shipBuilding / research `Allocation.desired` | same three-way split |
| civilization / motivation / education | `Allocation.value` moving to `desired` at `rate` | **identical mechanism**, our rate is 3 |
| level | techLevel | |
| life | population (also used as combat strength) | |
| assembly + build | paidTowardShipBuilding + currentShip.type | |
| defense / service / expand / offense | satellite / scout / colony / battleship | |
| sendto | defaultDestination | |
| prowlers | onPatrol ships | |
| rendezvous | Rendezvous | |
| Proximity set | spatial partition | |
| *(missing)* | stealth, scannerRange, apparentSize, visibility tiers | **this is the Anomaly Detector layer we add** |
| *(missing)* | combat, capture, AI matrices | ours has a stub `Base.adjustAIGoalsAfterAssembly` |
