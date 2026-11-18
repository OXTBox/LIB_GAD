script "gad_battles_rules"
######################################################################################
## gad_battles_rules  (18 11 2026, Opus)  GAD battles, step 2: the smallest loop.
## Game logic only: no window, no engine, no answer/ask (it runs headless).
## Spec: LIB_LLMOUT/LIB_GAD/BATTLES_PLAN_for_review.md (approved by the owner, 18 Nov).
##
## Records, GAD's own (GAD_ESSENCE_AND_VARIABLES.md 5.1), kept in one array sObj[id][field]:
##   b_001..  Base       ID, type, x, y, population, production, prudence, level, life, sendto,
##                       owner, anomaly, detect, spending  (+ assembly, kinds, buildIx)
##   m_001..  unit       ID, type, kind, level, owner, power, speed, damage, x, y, sendto, state,
##                       squad, turnsLeft
##   s_001..  squad      ID, type, owner, x, y, sendto, state, members (unit ids), turnsLeft
##   r_001..  rendezvous ID, type, owner, x, y: an X on the map
##   a_001..  anomaly    ID, type, signature, suppression, base, minionKind
##   factions            1 = Cyan (you), 2 = Green (the computer)
##
## Send-to: a Base id, a rendezvous id, a unit or squad id (ally or enemy), or a point "x,y".
## The turn (GADB.EndTurn): squads form (same team, same place, at the start of the turn),
## Bases build (one unit at a time, each goes to its Base's send-to), everything moves one turn
## closer (a fight resolves itself on arrival at an enemy: GADB.Fight), detection ticks, the
## computer moves. The events of the turn come back as lines: kind TAB x TAB y TAB word TAB detail.
######################################################################################

local sObj       -- sObj[id][field]: every record
local sNext      -- sNext[prefix]: the last number used for b, m, s, r, a
local sTurn      -- the turn being played (1 at the start)
local sSet       -- settings, GADB.Setting / GADB.SetSetting
local sKind      -- sKind[kind]["power"], ["speed"]
local sFaction   -- sFaction[n]["name"], ["colour"]
local sEvents    -- this turn's events

---------------------------------------------------------------- a new game

command GADB.New pSeed
   put empty into sObj
   put empty into sNext
   put empty into sEvents
   put empty into sSet
   put empty into sKind
   put empty into sFaction
   put 1 into sTurn
   if pSeed is an integer then set the randomSeed to pSeed
   put "slowest" into sSet["travel"]   -- a squad moves at its slowest member's speed (only mode in step 2)
   put 200 into sSet["seeRange"]       -- your Bases and units see this far (map units)
   put 4 into sSet["aiAttack"]         -- the computer sends a garrison this big; 0 = it never attacks
   put 1 into sSet["samePlace"]        -- closer than this = the same place
   -- kinds: power, speed (map units a turn). Names from the plan; LIB_LISTS by name later.
   GADB.SetKind "agent", 12, 90
   GADB.SetKind "militia", 8, 60
   GADB.SetKind "police", 10, 70
   GADB.SetKind "vigilante", 11, 80
   GADB.SetKind "superhero", 30, 120
   GADB.SetKind "thrall", 9, 60
   put "Cyan" into sFaction[1]["name"]
   put "0,200,220" into sFaction[1]["colour"]
   put "Green" into sFaction[2]["name"]
   put "60,190,80" into sFaction[2]["colour"]
end GADB.New

command GADB.SetKind pKind, pPower, pSpeed
   put pPower into sKind[pKind]["power"]
   put pSpeed into sKind[pKind]["speed"]
end GADB.SetKind

function GADB.Setting pName
   return sSet[pName]
end GADB.Setting

command GADB.SetSetting pName, pValue
   if pName is "travel" and pValue is not "slowest" then
      return "travel=slowest is the only mode in step 2"
   end if
   put pValue into sSet[pName]
   return empty
end GADB.SetSetting

function GADB.Turn
   return sTurn
end GADB.Turn

function GADB.Events
   return sEvents
end GADB.Events

function GADB.Faction pN, pField
   return sFaction[pN][pField]
end GADB.Faction

---------------------------------------------------------------- records

function GADB.NewId pPrefix
   add 1 to sNext[pPrefix]
   return pPrefix & "_" & format("%03d", sNext[pPrefix])
end GADB.NewId

function GADB.AddBase pOwner, pX, pY, pLevel, pProduction, pKinds
   local tId
   put GADB.NewId("b") into tId
   put tId into sObj[tId]["ID"]
   put "base" into sObj[tId]["type"]
   put round(pX) into sObj[tId]["x"]
   put round(pY) into sObj[tId]["y"]
   put 10 into sObj[tId]["population"]
   if pProduction is not a number then put 25 into pProduction
   put pProduction into sObj[tId]["production"]   -- assembly gained a turn; 100 = one unit
   put 10 into sObj[tId]["prudence"]
   if pLevel is not a number then put 1 into pLevel
   put pLevel into sObj[tId]["level"]
   put 100 into sObj[tId]["life"]
   put tId into sObj[tId]["sendto"]               -- at first its units stay home and guard it
   put pOwner into sObj[tId]["owner"]
   put empty into sObj[tId]["anomaly"]
   if pOwner is 1 then
      put 4 into sObj[tId]["detect"]
   else
      put 0 into sObj[tId]["detect"]              -- grey until a Genetic Anomaly is Detected
   end if
   put 0 into sObj[tId]["spending"]
   put 0 into sObj[tId]["assembly"]
   if pKinds is empty then put "agent" into pKinds
   put pKinds into sObj[tId]["kinds"]
   put 0 into sObj[tId]["buildIx"]
   return tId
end GADB.AddBase

function GADB.AddAnomaly pBase, pSignature, pSuppression, pKind
   local tId
   put GADB.NewId("a") into tId
   put tId into sObj[tId]["ID"]
   put "anomaly" into sObj[tId]["type"]
   if pSignature is not a number then put 3 into pSignature
   if pSuppression is not a number then put 0 into pSuppression
   put pSignature into sObj[tId]["signature"]     -- 1..5: how loud it is to the detector
   put pSuppression into sObj[tId]["suppression"] -- how well it hides (slows detection)
   put pBase into sObj[tId]["base"]
   put pKind into sObj[tId]["minionKind"]
   if pBase is not empty then
      put tId into sObj[pBase]["anomaly"]
      if pKind is not empty then put pKind into sObj[pBase]["kinds"]
   end if
   return tId
end GADB.AddAnomaly

function GADB.AddUnit pOwner, pKind, pX, pY, pLevel
   local tId
   if sKind[pKind]["power"] is empty then put "agent" into pKind
   if pLevel is not a number then put 1 into pLevel
   put GADB.NewId("m") into tId
   put tId into sObj[tId]["ID"]
   put "unit" into sObj[tId]["type"]
   put pKind into sObj[tId]["kind"]
   put pLevel into sObj[tId]["level"]
   put pOwner into sObj[tId]["owner"]
   put round(sKind[pKind]["power"] * (1 + (pLevel - 1) * 0.25)) into sObj[tId]["power"]
   put sKind[pKind]["speed"] into sObj[tId]["speed"]
   put 0 into sObj[tId]["damage"]
   put round(pX) into sObj[tId]["x"]
   put round(pY) into sObj[tId]["y"]
   put empty into sObj[tId]["sendto"]
   put "wait" into sObj[tId]["state"]
   put empty into sObj[tId]["squad"]
   put 0 into sObj[tId]["turnsLeft"]
   return tId
end GADB.AddUnit

function GADB.AddRendezvous pOwner, pX, pY
   local tId
   put GADB.NewId("r") into tId
   put tId into sObj[tId]["ID"]
   put "rendezvous" into sObj[tId]["type"]
   put pOwner into sObj[tId]["owner"]
   put round(pX) into sObj[tId]["x"]
   put round(pY) into sObj[tId]["y"]
   return tId
end GADB.AddRendezvous

-- every id with this prefix (b, m, s, r, a), sorted
function GADB.Ids pPrefix
   local tKeys
   put the keys of sObj into tKeys
   filter tKeys with (pPrefix & "_*")
   sort lines of tKeys
   return tKeys
end GADB.Ids

function GADB.Exists pId
   if pId is empty then return false
   return sObj[pId]["ID"] is pId
end GADB.Exists

function GADB.Get pId, pField
   return sObj[pId][pField]
end GADB.Get

command GADB.Put pId, pField, pValue
   put pValue into sObj[pId][pField]
end GADB.Put

-- a Base as GAD's comma item list, in the order of the plan (commas inside values become spaces)
function GADB.Record pId
   local tOut, tF, tV
   repeat for each item tF in "ID,type,x,y,population,production,prudence,level,life,sendto,owner,anomaly,detect,spending"
      put sObj[pId][tF] into tV
      replace "," with space in tV
      put tV & "," after tOut
   end repeat
   delete the last char of tOut
   return tOut
end GADB.Record

---------------------------------------------------------------- movers: free units and squads

-- what moves for this id: a unit in a squad moves with its squad
function GADB.Mover pId
   if char 1 to 2 of pId is "m_" and sObj[pId]["squad"] is not empty then return sObj[pId]["squad"]
   return pId
end GADB.Mover

function GADB.Movers
   local tOut, tK
   repeat for each line tK in GADB.Ids("m")
      if sObj[tK]["squad"] is empty then put tK & return after tOut
   end repeat
   put GADB.Ids("s") after tOut
   if the last char of tOut is return then delete the last char of tOut
   return tOut
end GADB.Movers

function GADB.Members pId
   if char 1 to 2 of pId is "s_" then return sObj[pId]["members"]
   if char 1 to 2 of pId is "m_" then return pId
   return empty
end GADB.Members

function GADB.Personnel pId
   return the number of items of GADB.Members(pId)
end GADB.Personnel

-- the travel speed: the slowest member (travel=slowest, the only mode in step 2)
function GADB.Speed pId
   local tMin, tM
   repeat for each item tM in GADB.Members(pId)
      if tMin is empty or sObj[tM]["speed"] < tMin then put sObj[tM]["speed"] into tMin
   end repeat
   if tMin is empty then return 0
   return tMin
end GADB.Speed

-- total power; damaged members count less
function GADB.Power pId
   local tSum, tM
   put 0 into tSum
   repeat for each item tM in GADB.Members(pId)
      add sObj[tM]["power"] * max(0, 100 - sObj[tM]["damage"]) / 100 to tSum
   end repeat
   return tSum
end GADB.Power

function GADB.XY pId
   if pId is a point then return pId
   put GADB.Mover(pId) into pId
   if not GADB.Exists(pId) then return empty
   return sObj[pId]["x"] & "," & sObj[pId]["y"]
end GADB.XY

function GADB.OwnerOf pId
   if pId is a point or not GADB.Exists(pId) then return empty
   return sObj[GADB.Mover(pId)]["owner"]
end GADB.OwnerOf

-- where a send-to target is now (empty when it is gone)
function GADB.TargetXY pTarget
   if pTarget is empty then return empty
   return GADB.XY(pTarget)
end GADB.TargetXY

function GADB.Dist pXY1, pXY2
   return sqrt((item 1 of pXY1 - item 1 of pXY2) ^ 2 + (item 2 of pXY1 - item 2 of pXY2) ^ 2)
end GADB.Dist

function GADB.Ceil pN
   if trunc(pN) < pN then return trunc(pN) + 1
   return trunc(pN)
end GADB.Ceil

function GADB.TurnsLeft pId
   local tXY, tSp
   put GADB.TargetXY(sObj[pId]["sendto"]) into tXY
   put GADB.Speed(pId) into tSp
   if tXY is empty or tSp <= 0 then return 0
   return GADB.Ceil(GADB.Dist(GADB.XY(pId), tXY) / tSp)
end GADB.TurnsLeft

-- send to... for a Base (every unit it builds goes there) or a unit/squad (a unit in a squad
-- gives the order to its squad). Sending something to itself = stay / wait where it is.
command GADB.SetSendTo pId, pTarget
   local tWho
   if pTarget is a point then
      put round(item 1 of pTarget) & "," & round(item 2 of pTarget) into pTarget
   else if not GADB.Exists(pTarget) then
      return "no such target: " & pTarget
   end if
   if char 1 to 2 of pId is "b_" then
      put pTarget into sObj[pId]["sendto"]
      return empty
   end if
   put GADB.Mover(pId) into tWho
   if not GADB.Exists(tWho) then return "no such unit: " & pId
   if GADB.Mover(pTarget) is tWho then put GADB.XY(tWho) into pTarget
   put pTarget into sObj[tWho]["sendto"]
   put "move" into sObj[tWho]["state"]
   put GADB.TurnsLeft(tWho) into sObj[tWho]["turnsLeft"]
   return empty
end GADB.SetSendTo

command GADB.Place pId, pX, pY
   local tM
   put pX into sObj[pId]["x"]
   put pY into sObj[pId]["y"]
   repeat for each item tM in GADB.Members(pId)
      put pX into sObj[tM]["x"]
      put pY into sObj[tM]["y"]
   end repeat
end GADB.Place

command GADB.RemoveUnit pM
   local tS, tList
   put sObj[pM]["squad"] into tS
   delete variable sObj[pM]
   if tS is not empty then
      put "," & sObj[tS]["members"] & "," into tList
      replace ("," & pM & ",") with "," in tList
      put char 2 to -2 of tList into tList
      if tList is empty then
         delete variable sObj[tS]
      else
         put tList into sObj[tS]["members"]
      end if
   end if
end GADB.RemoveUnit

command GADB.Event pKind, pX, pY, pWord, pDetail
   put pKind & tab & pX & tab & pY & tab & pWord & tab & pDetail & return after sEvents
end GADB.Event

---------------------------------------------------------------- the turn

function GADB.EndTurn
   put empty into sEvents
   GADB.FormSquads
   GADB.Build
   GADB.MoveAll
   GADB.DetectTick
   GADB.ComputerMoves
   add 1 to sTurn
   if the last char of sEvents is return then delete the last char of sEvents
   return sEvents
end GADB.EndTurn

-- entities of the same team in the same place become a squad (at the start of a turn).
-- Joined: those waiting there, or those on the way to the same send-to.
command GADB.FormSquads
   local tMovers, tN, tI, tJ, tA, tB
   put GADB.Movers() into tMovers
   put the number of lines of tMovers into tN
   repeat with tI = 1 to tN
      put line tI of tMovers into tA
      if not GADB.Exists(tA) or GADB.Mover(tA) is not tA then next repeat
      repeat with tJ = tI + 1 to tN
         put line tJ of tMovers into tB
         if not GADB.Exists(tB) or GADB.Mover(tB) is not tB then next repeat
         if GADB.CanJoin(tA, tB) then put GADB.Join(tA, tB) into tA
      end repeat
   end repeat
end GADB.FormSquads

function GADB.CanJoin pA, pB
   if sObj[pA]["owner"] is not sObj[pB]["owner"] then return false
   if GADB.Dist(GADB.XY(pA), GADB.XY(pB)) > sSet["samePlace"] then return false
   if sObj[pA]["state"] is "wait" and sObj[pB]["state"] is "wait" then return true
   return sObj[pA]["sendto"] is sObj[pB]["sendto"]
end GADB.CanJoin

-- B joins A; returns the squad (a new one when A is a lone unit)
function GADB.Join pA, pB
   local tS, tM, tF
   if char 1 to 2 of pA is "m_" and char 1 to 2 of pB is "s_" then
      -- a lone unit joins the squad, not the other way round
      put pA into tS
      put pB into pA
      put tS into pB
   end if
   if char 1 to 2 of pA is "m_" then
      put GADB.NewId("s") into tS
      put tS into sObj[tS]["ID"]
      put "squad" into sObj[tS]["type"]
      repeat for each item tF in "owner,x,y,sendto,state,turnsLeft"
         put sObj[pA][tF] into sObj[tS][tF]
      end repeat
      put pA into sObj[tS]["members"]
      put tS into sObj[pA]["squad"]
   else
      put pA into tS
   end if
   repeat for each item tM in GADB.Members(pB)
      put tS into sObj[tM]["squad"]
      put "," & tM after sObj[tS]["members"]
   end repeat
   if char 1 to 2 of pB is "s_" then
      delete variable sObj[pB]
      GADB.Retarget pB, tS
   end if
   GADB.Event "squad", sObj[tS]["x"], sObj[tS]["y"], GADB.Personnel(tS), tS & " (" & sObj[tS]["owner"] & "): " & sObj[tS]["members"]
   return tS
end GADB.Join

-- anything sent to pOld now goes to pNew
command GADB.Retarget pOld, pNew
   local tK
   repeat for each key tK in sObj
      if sObj[tK]["sendto"] is pOld then put pNew into sObj[tK]["sendto"]
   end repeat
end GADB.Retarget

-- each Base adds its production to its assembly; at 100 it builds ONE unit, which leaves for the
-- Base's send-to point on its own
command GADB.Build
   local tB, tKinds, tKind, tM
   repeat for each line tB in GADB.Ids("b")
      add sObj[tB]["production"] to sObj[tB]["assembly"]
      if sObj[tB]["assembly"] < 100 then next repeat
      subtract 100 from sObj[tB]["assembly"]
      put sObj[tB]["kinds"] into tKinds
      add 1 to sObj[tB]["buildIx"]
      put item ((sObj[tB]["buildIx"] - 1) mod the number of items of tKinds) + 1 of tKinds into tKind
      put GADB.AddUnit(sObj[tB]["owner"], tKind, sObj[tB]["x"], sObj[tB]["y"], sObj[tB]["level"]) into tM
      GADB.SetSendTo tM, sObj[tB]["sendto"]
      if the result is not empty then GADB.SetSendTo tM, tB   -- its send-to is gone: stay home
      GADB.Event "built", sObj[tB]["x"], sObj[tB]["y"], tKind, tM & " (" & sObj[tB]["owner"] & ") at " & tB & " for " & sObj[tM]["sendto"]
   end repeat
end GADB.Build

command GADB.MoveAll
   local tM
   repeat for each line tM in GADB.Movers()
      if not GADB.Exists(tM) or GADB.Mover(tM) is not tM then next repeat
      GADB.MoveOne tM
   end repeat
end GADB.MoveAll

-- one turn closer to the send-to; arriving at an enemy, the fight resolves itself
command GADB.MoveOne pM
   local tT, tXY, tFrom, tD, tSp
   put sObj[pM]["sendto"] into tT
   if tT is empty then exit GADB.MoveOne
   put GADB.TargetXY(tT) into tXY
   if tXY is empty then
      -- the target is gone: wait where you are
      put empty into sObj[pM]["sendto"]
      put "wait" into sObj[pM]["state"]
      put 0 into sObj[pM]["turnsLeft"]
      exit GADB.MoveOne
   end if
   put GADB.XY(pM) into tFrom
   put GADB.Dist(tFrom, tXY) into tD
   if sObj[pM]["state"] is "wait" and tD <= sSet["samePlace"] and \
         (GADB.OwnerOf(tT) is empty or GADB.OwnerOf(tT) is sObj[pM]["owner"]) then exit GADB.MoveOne
   put GADB.Speed(pM) into tSp
   if tD <= tSp then
      GADB.Place pM, item 1 of tXY, item 2 of tXY
      GADB.Arrive pM, tT
   else
      GADB.Place pM, round(item 1 of tFrom + (item 1 of tXY - item 1 of tFrom) * tSp / tD), \
            round(item 2 of tFrom + (item 2 of tXY - item 2 of tFrom) * tSp / tD)
      put "move" into sObj[pM]["state"]
      put GADB.Ceil((tD - tSp) / tSp) into sObj[pM]["turnsLeft"]
   end if
end GADB.MoveOne

command GADB.Arrive pM, pT
   local tOwner
   put 0 into sObj[pM]["turnsLeft"]
   put "wait" into sObj[pM]["state"]
   put GADB.OwnerOf(pT) into tOwner
   if tOwner is empty or tOwner is sObj[pM]["owner"] then exit GADB.Arrive
   if char 1 to 2 of pT is "r_" then exit GADB.Arrive   -- an enemy X is only a place
   get GADB.Fight(pM, pT)
end GADB.Arrive

-- a Base's garrison: its owner's movers waiting on it
function GADB.Garrison pBase
   local tOut, tM, tXY
   put sObj[pBase]["x"] & "," & sObj[pBase]["y"] into tXY
   repeat for each line tM in GADB.Movers()
      if sObj[tM]["owner"] is not sObj[pBase]["owner"] then next repeat
      if sObj[tM]["state"] is not "wait" then next repeat
      if GADB.Dist(GADB.XY(tM), tXY) > sSet["samePlace"] then next repeat
      put tM & return after tOut
   end repeat
   if the last char of tOut is return then delete the last char of tOut
   return tOut
end GADB.Garrison

function GADB.BaseAt pX, pY, pRadius
   local tB
   if pRadius is not a number then put sSet["samePlace"] into pRadius
   repeat for each line tB in GADB.Ids("b")
      if GADB.Dist(pX & "," & pY, sObj[tB]["x"] & "," & sObj[tB]["y"]) <= pRadius then return tB
   end repeat
   return empty
end GADB.BaseAt

######################################################################################
## THE FIGHT: one handler, easy to tune. pAtt (a unit or squad) has arrived at pDef (an enemy
## Base, unit or squad). Each side: power x personnel (damaged members count less), nudged by
## speed (the faster side strikes first) and a seeded die. The loser's damage grows round by
## round until it breaks; the winner takes a share (never broken by it). A Base is held or
## changes owner. Returns the result word: TAKEN / HELD (a Base), WON / LOST (an entity).
######################################################################################
function GADB.Fight pAtt, pDef
   local kFirst, kDie, kGuard, kStep
   put 0.15 into kFirst   -- the faster side strikes first: its strength x (1 + kFirst)
   put 0.10 into kDie     -- the seeded die: each side x (1 +- up to kDie)
   put 10 into kGuard     -- a Base guards itself: power kGuard x level, counted as one more member
   put 20 into kStep      -- the loser's damage a round = kStep x (winner / loser) until it breaks
   local tAM, tAP, tACount, tASp, tDM, tDP, tDCount, tDSp, tA, tD, tG, tGuard, tBase, tXY
   local tAttWins, tRatio, tLoseM, tWinM, tRounds, tGuardDmg, tHit, tScratch, tM, tWord, tDetail
   put GADB.Mover(pAtt) into pAtt
   put GADB.Members(pAtt) into tAM
   put GADB.Power(pAtt) into tAP
   put the number of items of tAM into tACount
   put GADB.Speed(pAtt) into tASp
   put 0 into tDP
   if char 1 to 2 of pDef is "b_" then
      put pDef into tBase
      put sObj[pDef]["level"] * kGuard into tGuard
      put 0 into tDSp
      repeat for each line tG in GADB.Garrison(pDef)
         put GADB.Members(tG) & "," after tDM
         add GADB.Power(tG) to tDP
         if tDSp is 0 or GADB.Speed(tG) < tDSp then put GADB.Speed(tG) into tDSp
      end repeat
      if the last char of tDM is "," then delete the last char of tDM
      add tGuard to tDP
      put the number of items of tDM + 1 into tDCount
   else
      put GADB.Mover(pDef) into pDef
      put GADB.Members(pDef) into tDM
      put GADB.Power(pDef) into tDP
      put the number of items of tDM into tDCount
      put GADB.Speed(pDef) into tDSp
   end if
   put sObj[pDef]["x"] & "," & sObj[pDef]["y"] into tXY
   -- power x personnel
   put tAP * tACount into tA
   put tDP * tDCount into tD
   -- first strike
   if tASp > tDSp then
      multiply tA by 1 + kFirst
   else if tDSp > tASp then
      multiply tD by 1 + kFirst
   end if
   -- the seeded die
   multiply tA by 1 + kDie * (random(21) - 11) / 10
   multiply tD by 1 + kDie * (random(21) - 11) / 10
   -- the loser's damage grows until it breaks (a tie: the defender holds)
   put tA > tD into tAttWins
   if tAttWins then
      put tA / max(tD, 1) into tRatio
      put tDM into tLoseM
      put tAM into tWinM
   else
      put tD / max(tA, 1) into tRatio
      put tAM into tLoseM
      put tDM into tWinM
   end if
   put 0 into tRounds
   put 0 into tGuardDmg
   repeat
      add 1 to tRounds
      put max(1, round(kStep * tRatio)) into tHit
      repeat for each item tM in tLoseM
         add tHit to sObj[tM]["damage"]
      end repeat
      if tAttWins and tBase is not empty then add tHit to tGuardDmg
      put round(kStep / tRatio / 2) into tScratch
      repeat for each item tM in tWinM
         put min(99, sObj[tM]["damage"] + tScratch) into sObj[tM]["damage"]
      end repeat
      if GADB.AllBroken(tLoseM) and (not tAttWins or tBase is empty or tGuardDmg >= 100) then exit repeat
      if tRounds >= 50 then exit repeat
   end repeat
   repeat for each item tM in tLoseM
      GADB.RemoveUnit tM
   end repeat
   -- the result
   if tBase is not empty then
      if tAttWins then
         put "TAKEN" into tWord
         put sObj[pAtt]["owner"] into sObj[tBase]["owner"]
         put tBase into sObj[tBase]["sendto"]
         put 0 into sObj[tBase]["assembly"]
         if sObj[tBase]["owner"] is 1 then put 4 into sObj[tBase]["detect"]
         put tBase into sObj[pAtt]["sendto"]   -- the winners stay and guard it
         put "wait" into sObj[pAtt]["state"]
      else
         put "HELD" into tWord
      end if
   else if tAttWins then
      put "WON" into tWord
   else
      put "LOST" into tWord
   end if
   put pAtt & " (" & tACount & ") " & round(tA) & " vs " & pDef & " (" & tDCount & ") " & round(tD) & ", " & tRounds & " rounds" into tDetail
   GADB.Event "fight", item 1 of tXY, item 2 of tXY, tWord, tDetail
   return tWord
end GADB.Fight

function GADB.AllBroken pList
   local tM
   repeat for each item tM in pList
      if sObj[tM]["damage"] < 100 then return false
   end repeat
   return true
end GADB.AllBroken

---------------------------------------------------------------- detection

-- true when one of player 1's Bases or movers is within seeRange of the point
function GADB.NearPlayer pXY
   local tK
   repeat for each line tK in GADB.Ids("b")
      if sObj[tK]["owner"] is 1 and GADB.Dist(pXY, sObj[tK]["x"] & "," & sObj[tK]["y"]) <= sSet["seeRange"] then return true
   end repeat
   repeat for each line tK in GADB.Movers()
      if sObj[tK]["owner"] is 1 and GADB.Dist(pXY, GADB.XY(tK)) <= sSet["seeRange"] then return true
   end repeat
   return false
end GADB.NearPlayer

-- can player 1 see this mover?
function GADB.Seen pId
   put GADB.Mover(pId) into pId
   if sObj[pId]["owner"] is 1 then return true
   return GADB.NearPlayer(GADB.XY(pId))
end GADB.Seen

-- detection 0..4 (NONE < SPEED < TECH < CLASS < DETAILS) of each Base not yours: +1 a turn while
-- you are near; otherwise the anomaly's signature reaches the detector every (6 - signature +
-- suppression) turns
command GADB.DetectTick
   local tB, tA, tEvery, tWas
   repeat for each line tB in GADB.Ids("b")
      if sObj[tB]["owner"] is 1 then
         put 4 into sObj[tB]["detect"]
         next repeat
      end if
      put sObj[tB]["detect"] into tWas
      if tWas >= 4 then next repeat
      if GADB.NearPlayer(sObj[tB]["x"] & "," & sObj[tB]["y"]) then
         add 1 to sObj[tB]["detect"]
      else
         put sObj[tB]["anomaly"] into tA
         if tA is empty then
            put 5 into tEvery
         else
            put max(1, 6 - sObj[tA]["signature"] + sObj[tA]["suppression"]) into tEvery
         end if
         if sTurn mod tEvery is 0 then add 1 to sObj[tB]["detect"]
      end if
      if sObj[tB]["detect"] is not tWas then
         GADB.Event "detect", sObj[tB]["x"], sObj[tB]["y"], sObj[tB]["detect"], tB & " detected " & sObj[tB]["detect"] & "/4"
      end if
   end repeat
end GADB.DetectTick

---------------------------------------------------------------- the computer

-- each computer Base whose garrison has grown to aiAttack sends it to the nearest Base not its own
command GADB.ComputerMoves
   local tB, tG, tT
   if sSet["aiAttack"] <= 0 then exit GADB.ComputerMoves
   repeat for each line tB in GADB.Ids("b")
      if sObj[tB]["owner"] is 1 then next repeat
      repeat for each line tG in GADB.Garrison(tB)
         if GADB.Personnel(tG) < sSet["aiAttack"] then next repeat
         put GADB.NearestEnemyBase(tB) into tT
         if tT is empty then next repeat
         GADB.SetSendTo tG, tT
         GADB.Event "computer", sObj[tB]["x"], sObj[tB]["y"], GADB.Personnel(tG), tG & " (" & sObj[tB]["owner"] & ") sent to " & tT
      end repeat
   end repeat
end GADB.ComputerMoves

function GADB.NearestEnemyBase pBase
   local tB, tBest, tD, tBestD, tXY
   put sObj[pBase]["x"] & "," & sObj[pBase]["y"] into tXY
   repeat for each line tB in GADB.Ids("b")
      if sObj[tB]["owner"] is sObj[pBase]["owner"] then next repeat
      put GADB.Dist(tXY, sObj[tB]["x"] & "," & sObj[tB]["y"]) into tD
      if tBest is empty or tD < tBestD then
         put tB into tBest
         put tD into tBestD
      end if
   end repeat
   return tBest
end GADB.NearestEnemyBase

---------------------------------------------------------------- for tests

-- one line a record: id, owner, x,y, sendto, state, personnel/detect
function GADB.State
   local tOut, tK
   put "turn " & sTurn & return into tOut
   repeat for each line tK in GADB.Ids("b")
      put tK && "owner" && sObj[tK]["owner"] && "detect" && sObj[tK]["detect"] && "sendto" && sObj[tK]["sendto"] && "assembly" && sObj[tK]["assembly"] & return after tOut
   end repeat
   repeat for each line tK in GADB.Movers()
      put tK && "owner" && sObj[tK]["owner"] && "at" && GADB.XY(tK) && sObj[tK]["state"] && "to" && sObj[tK]["sendto"] && "n" && GADB.Personnel(tK) && "speed" && GADB.Speed(tK) && "turns" && sObj[tK]["turnsLeft"] & return after tOut
   end repeat
   if the last char of tOut is return then delete the last char of tOut
   return tOut
end GADB.State
