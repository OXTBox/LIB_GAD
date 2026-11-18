# GAD battles: step 1, the one-page plan

18 Nov 2026, Opus. A plan only: nothing is built. Your words: "just like this, no more detail than
needed" (16 Nov) and "form follows function!" (18 Nov). Engines: none touched. Step 2 below needs no
engine call at all (both halves are plain stacks); DeadDays in 3D (Engine 1, XT) is later.

## The loop, one turn

| # | Where | What happens |
|---|---|---|
| 1 | Bases map | Bases are plain rects, grey until a Genetic Anomaly is Detected; Cyan and Green players lit, inactive text grey (your 16 Nov notes) |
| 2 | Bases map | You pick: each of your Bases' focus (recruit / research / train), and at most one *strike*: your Base -> a Base with a detected anomaly |
| 3 | ENTER | Night: Bases grow (the GA prototype's `GA.Night` rules), detection ticks up, Green moves |
| 4 | Fight | A strike starts one LIB_RTS street fight, sized from the two Bases (table below) |
| 5 | Fight | You command it (box, click, as `RTS_Demo` today), or press a key to let it play out unseen (3 min of fight takes ~1.5 s headless) |
| 6 | Back | `RTS.Counts()` (living, dead) comes back: survivors return to your Base; anomaly cleared = the Base turns Cyan; else it stays and grows |

## Base -> fight -> Base (LIB_RTS as it is: `RTS.NewGame seed, "buildings,humans,guns,cars,zombies"`)

| RTS count (1..20) | Comes from |
|---|---|
| buildings | the target Base's `population` / 10 |
| humans (team 0, the living) | the people you sent (capped at 20) |
| guns | your Base's `level` (the Bureau's rank): guns stand in for powers |
| cars | 1 (fake) |
| zombies (team 1, the dead) | the anomaly's `signature` strength: its thralls; the living who fall rise for it |

Win: `RTS.Status()` = "All Zombies Destroyed!!!". Lose: "All Living Devoured!!". Both still standing
after 3 minutes: the anomaly holds the Base.

## The data, as GAD's own variables (Generic Any Data, `GAD_ESSENCE_AND_VARIABLES.md` 5.1)

| Thing | Record | Fields (kept from GAD_WORKING; **new** in bold) |
|---|---|---|
| Base | `b_001`.. in BaseData | ID, type, x, y, population, production, prudence, level, life, sendto, **owner** (0 none, 1 Cyan, 2 Green), **anomaly** (id or empty), **detect** (0..4) |
| Anomaly | **`a_001`..** in a new AnomalyData set | **signature** (how loud), **suppression** (how hidden), **base** |
| Hero | `m_001` mobile, type offense | ID, x, y, sendto, level; a hero is just a strong mobile for now |
| Faction | PlayerData | Player1 = Cyan (you), Player2 = Green, 0 = nobody; the bases each owns |

Detection, Galactica's formula made small: each night a Base's `detect` rises by 1 when
your nearest Base's level beats the anomaly's suppression. At 1 the rect lights up; at 4 you know
its strength before you strike (Galactica's NONE < SPEED < TECH < CLASS < DETAILS).

## Fake for now

- Green is the computer and plays the GA prototype's simple moves (`GA.OtherMoves`).
- Powers = guns; heroes = armed humans; cars do nothing new. No tropes, names or banter (step 3;
  names then from LIB_LISTS by name only, e.g. `Lists/Road_Names`, `Lists/City_Names`, `Lists/Superpowers`).
- The fight is LIB_RTS's top-down polygon view, not the DeadDays 3D city. No saving between sessions.

## What step 2 needs that does not exist yet

1. **A Bases map stack.** The GA prototype is a Vibecode3D card script with points, not rects, and
   has "not done yet: a stack of its own". The 2018 GUI (`ui/GenericaAnyData_04042018a`) is a harvest, not a stack.
2. **A way into a fight and back.** The engine has no "run another scene, then give me its result"
   (`Game.Exit` only ends a game). Smallest fix: the map stack `start using`s `RTS_Library` and
   opens `RTS_Demo` with `Demo.NewLevel counts, seed`; LIB_RTS gains one call, `RTS.Over()`
   (empty, "living", "dead" or "time"), instead of the map reading the status words.
3. **A fight time limit.** LIB_RTS fights run until a side is gone; the 3-minute stop is new.
4. **Balance.** LIB_RTS's own note: on its test level the gunners win in three minutes. Untuned.

## Questions for you (my default in brackets)

1. Green: the computer, or a second person at the same keyboard? [the computer]
2. A fight: you command it, or it plays itself and you see the result? [you command; one key skips to the end]
3. The map: a new plain stack of rects now, the 2018 GUI's look later? [yes]
4. The dead in the street fight are the anomaly's thralls (people it turns)? [yes]
