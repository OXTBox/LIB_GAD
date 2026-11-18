# GAD battles: step 1, the one-page plan (version 2)

18 Nov 2026, Opus. A plan only: nothing is built. Version 2 is rewritten from your answers to
version 1's four questions (18 Nov, quoted below). Your words before: "just like this, no more
detail than needed" (16 Nov), "form follows function!" (18 Nov). Engines: none touched by step 2.

## The shape: a turn-based 4X, Galactica's way

"You tell 'Ship A' to go to 'Planet B' and the fight just happens when they finally arrive 10 turns
later. Just some explosions and sparks and a win or defeat or imminent danger music."

| # | Where | What happens |
|---|---|---|
| 1 | Bases map | Bases are plain rects, made by the game, grey until a Genetic Anomaly is Detected; you Cyan, the computer Green (more colours as enemies grow), inactive text grey |
| 2 | Your Bases | You set each Base's **production desire and the spending toward it** (Galactica's production and research money, in GA's words) |
| 3 | Your units | You send mobile units to a place or against an entity. They travel at their **speed**: the trip takes turns |
| 4 | ENTER | The turn: Bases build, units move one turn closer, detection ticks, the computer moves |
| 5 | Arrival | A unit that reaches its target **fights by itself**, from the figures (power, speed, personnel), no micro-management |
| 6 | Result | Explosions and sparks on the map, then win, defeat, or imminent danger (music cue); the Base changes owner or holds |
| 7 | Zoom (optional) | You may zoom into a fight and watch the entities battle in 3D, each acting on its own attributes |

## The anomalies: every place is its own

"Every location is a different anomaly ... just like a 4X game's bases produce ships, they will
produce various greater powered minions as their own level increases." The shape you named: a
master and the gang he raises (Magneto and the Brotherhood, Shredder and the Foot Clan, Jim Henson
and the Muppets): tone only, no borrowed names in the game.

So an anomaly's Base is a Base like yours: it has a level, builds minions (its thralls), and sends
them out. Higher level, stronger minions.

## The figures, from Galactica (`GAD_ESSENCE_AND_VARIABLES.md`)

| Galactica | Ours | Used for |
|---|---|---|
| star production, paidTowardResearch | a Base's **production** and **spending** | what it builds and how fast |
| ship power, speed, damage | a unit's **power**, **speed**, **damage** | the fight; turns to arrive |
| the number of ships in a fleet | **personnel**: how many are in the squad (agents, superheroes, vigilantes, militia, police...) | the fight; holding a Base after |
| fleet totalPower, remainingDistance | a squad's total power (the sum of its members), **turns left** | the fight; when it arrives |
| visibility tiers NONE < SPEED < TECH < CLASS < DETAILS | **detection** 0..4 | what you know before you send |

The fight, first version: each side's power x personnel, nudged by speed (first strike) and a seeded
die; the loser's damage grows until it breaks. One formula, in one handler, easy to tune. The same
numbers drive the optional 3D view, so watching never changes the result.

## The data, as GAD's own records (essence doc 5.1)

| Thing | Record | Fields (kept from GAD_WORKING; **new** in bold) |
|---|---|---|
| Base | `b_001`.. BaseData | ID, type, x, y, population, production, prudence, level, life, sendto, **owner**, **anomaly**, **detect**, **spending** |
| Unit | `m_001`.. mobiles | one member: ID, **kind** (agent, superhero, vigilante, militia, police...), level, **owner**, **power**, **speed**, **damage** |
| Squad | **`s_001`..** (Galactica's fleet; the essence doc's Squad) | ID, x, y, sendto, **owner**, **members** (unit ids: their count is the personnel), **turnsLeft**; moves at its slowest member's speed (my default) |
| Anomaly | **`a_001`..** AnomalyData | **signature**, **suppression**, **base**, **minion kind** |
| Faction | PlayerData | 1 = Cyan (you), 2.. = computer colours; online opponents later |

## Step 2: the smallest loop (after your yes)

Two Bases (yours and one anomaly's), one small squad each way, the trip takes a few turns, the fight resolves
on arrival, sparks and a result word on the map. A plain stack of rects. Played headless in a test and
openable by you in OXT-Beyond. **Not in step 2:** the 3D zoom view (step 3: LIB_RTS or DeadDays
entities acting on the figures), music, more colours, names (LIB_LISTS by name, later).

## What changed from version 1

The street fight you commanded is gone: fights resolve themselves on arrival. LIB_RTS becomes a
candidate for the optional zoom view, not the fight itself. Green is "the computer, or potentially
online opponent(s) (later)".
