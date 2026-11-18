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

**Note: travel speed is one to test** (owner, 18 Nov): "we might have teleporters or super jets ...
we'll default to the slow mode and then test the speed advantage, it'll be terrifying when the enemy
teleports right into your base." So: a squad moves at its slowest member's speed by default; one
setting (`travel=slowest`) lets later tests try others (the fastest member carries the squad, a
teleporter = 0 turns, a jet = a speed bonus). Not in step 2.

## The data, as GAD's own records (essence doc 5.1)

| Thing | Record | Fields (kept from GAD_WORKING; **new** in bold) |
|---|---|---|
| Base | `b_001`.. BaseData | ID, type, x, y, population, production, prudence, level, life, sendto, **owner**, **anomaly**, **detect**, **spending** |
| Unit | `m_001`.. mobiles | one member: ID, **kind** (agent, superhero, vigilante, militia, police...), level, **owner**, **power**, **speed**, **damage** |
| Squad | **`s_001`..** (Galactica's fleet; the essence doc's Squad) | ID, x, y, sendto, **owner**, **members** (unit ids: their count is the personnel), **turnsLeft**; moves at its slowest member's speed (default, see the note on travel speed) |
| Rendezvous | **`r_001`..** (Galactica's rendezvous; the essence doc's staging point) | ID, owner, x, y: an **X on the map** |
| Anomaly | **`a_001`..** AnomalyData | **signature**, **suppression**, **base**, **minion kind** |
| Faction | PlayerData | 1 = Cyan (you), 2.. = computer colours; online opponents later |

## Step 2: the smallest loop (your rules, 18 Nov)

"One unit by default, squads are formed at rendezvous point."

| Rule | How |
|---|---|
| A Base builds **one unit** at a time | each unit leaves on its own |
| **Rendezvous** | press **U**, click the map: an **X** is left there. It can be clicked as a target |
| **Send to...** | a unit's order, or a Base's "send to..." point: a Base, a rendezvous X, an enemy entity, an ally entity, **or any point on the map** (empty space: the unit goes there and waits). **Every unit a Base produces goes to its send-to point** |
| **Squads form by themselves** | entities of the same team in the same place **at the start of a turn** become a squad by default; a rendezvous is where you gather them on purpose |
| Travel | the slow mode: a squad moves at its slowest member's speed |
| Arrival at an enemy | the fight resolves itself from the figures; sparks and a result word on the map |

The loop to build: two Bases (yours and one anomaly's), each producing units toward a send-to point;
yours gathers at a rendezvous X into a squad, which you then send to the anomaly's Base. Played headless
in a test and openable by you in OXT-Beyond. **Not in step 2:** the 3D zoom view, music, more colours,
names (LIB_LISTS by name, later), travel-speed tests.

## What changed from version 1

The street fight you commanded is gone: fights resolve themselves on arrival. LIB_RTS becomes a
candidate for the optional zoom view, not the fight itself. Green is "the computer, or potentially
online opponent(s) (later)".
