script "gad_battles_ui"
######################################################################################
## gad_battles_ui  (18 11 2026, Opus)  the card of GAD_Battles.oxtstack: a plain 2D map.
## The stack's own script (gad_battles_stack.livecodescript) loads this as the card script and
## starts using the logic library gad_battles_rules.livecodescript (GADB.*). Form follows function:
## rects, dots, an X, lines, sparks and a word. No answer/ask (it is tested headless).
##
## Mouse: click your Base or unit (Cyan), then click where it goes: a Base, an X, a unit (yours or
##        theirs) or any spot on the map. Click the selected one again = stay / wait there.
##        Right-click (or Esc) cancels.
## Keys:  U then click the map = drop a rendezvous X.  ENTER (or Return) = end the turn.
##        N = a new game.  A = the About card.
######################################################################################

constant kMapRect = "10,10,810,570"
constant kStatusRect = "10,576,810,636"
constant kCyan = "0,200,220"
constant kCyanDim = "0,110,130"
constant kGreen = "60,190,80"
constant kGreenDim = "40,110,50"
constant kGrey = "128,128,128"
constant kText = "235,235,235"
constant kTextGrey = "140,140,140"
constant kMapBack = "24,26,32"
constant kSpark1 = "255,215,70"
constant kSpark2 = "255,120,40"

local sSel       -- the selected Base or mover (yours), waiting for its send-to click
local sDropX     -- true after U: the next click drops a rendezvous X
local sPos       -- sPos[mover id] = "x,y" where it is drawn (for clicks)
local sLastEvents
local sSeed
local sSaid

---------------------------------------------------------------- start

command GADUI.Start pSeed
   local tYou, tThem
   if pSeed is not an integer then put 7 into pSeed
   put pSeed into sSeed
   GADB.New pSeed
   put GADB.AddBase(1, 150, 450, 1, 50, "agent,militia") into tYou
   put GADB.AddBase(2, 650, 140, 1, 34, "thrall") into tThem
   get GADB.AddAnomaly(tThem, 3, 0, "thrall")
   put empty into sSel
   put false into sDropX
   put empty into sLastEvents
   GADUI.Draw
   GADUI.Say "Click your Base (Cyan), then click where its units go. U + click drops a rendezvous X. ENTER ends the turn."
end GADUI.Start

function GADUI.Seed
   return sSeed
end GADUI.Seed

function GADUI.Selected
   return sSel
end GADUI.Selected

function GADUI.PosOf pId
   return sPos[GADB.Mover(pId)]
end GADUI.PosOf

---------------------------------------------------------------- mouse and keys

on mouseUp pButton
   if pButton is 3 then
      GADUI.Cancel
   else
      GADUI.Click the clickH, the clickV
   end if
end mouseUp

on keyDown pKey
   switch pKey
      case "u"
      case "U"
         put true into sDropX
         put empty into sSel
         GADUI.Say "Rendezvous: click the map to drop an X there (Esc: cancel)."
         break
      case "n"
      case "N"
         GADUI.Start sSeed + 1
         break
      case "a"
      case "A"
         go card "About"
         break
      default
         pass keyDown
   end switch
end keyDown

on returnKey
   GADUI.EndTurn
end returnKey

on enterKey
   GADUI.EndTurn
end enterKey

on escapeKey
   GADUI.Cancel
end escapeKey

command GADUI.Cancel
   put empty into sSel
   put false into sDropX
   GADUI.Draw
   GADUI.Say "Cancelled."
end GADUI.Cancel

command GADUI.Click pX, pY
   local tHit, tTarget, tWhat
   if not (pX & "," & pY is within kMapRect) then exit GADUI.Click
   if sDropX then
      put false into sDropX
      put GADB.AddRendezvous(1, pX, pY) into tHit
      GADUI.Draw
      GADUI.Say "Rendezvous" && tHit && "dropped. Click a Base or unit, then the X, to gather there."
      exit GADUI.Click
   end if
   put GADUI.HitAt(pX, pY) into tHit
   if sSel is empty then
      if tHit is not empty and GADB.OwnerOf(tHit) is 1 and char 1 of tHit is among the items of "b,m,s" then
         put tHit into sSel
         put GADUI.Name(tHit) into tWhat
         GADUI.Draw
         GADUI.Say "Send" && tWhat && "to...: click a Base, an X, a unit or any spot (click it again: stay; Esc: cancel)."
      else if tHit is empty then
         GADUI.Say "Click one of your Bases or units (Cyan) first."
      else
         GADUI.Say GADUI.Describe(tHit)
      end if
      exit GADUI.Click
   end if
   -- the second click: send-to
   if tHit is sSel then
      put sSel into tTarget
   else if tHit is empty then
      put round(pX) & "," & round(pY) into tTarget
   else
      put tHit into tTarget
   end if
   GADB.SetSendTo sSel, tTarget
   if char 1 of sSel is "b" then
      if tTarget is sSel then
         put GADUI.Name(sSel) && "keeps its units home." into tWhat
      else
         put "Every unit" && GADUI.Name(sSel) && "builds goes to" && GADUI.Name(tTarget) & "." into tWhat
      end if
   else if tTarget is sSel then
      put GADUI.Name(sSel) && "waits where it is." into tWhat
   else
      put GADUI.Name(sSel) && "goes to" && GADUI.Name(tTarget) && "(" & GADB.Get(GADB.Mover(sSel), "turnsLeft") && "turns)." into tWhat
   end if
   put empty into sSel
   GADUI.Draw
   GADUI.Say tWhat
end GADUI.Click

-- movers first (they are small), then the X marks, then the Bases
function GADUI.HitAt pX, pY
   local tK
   repeat for each key tK in sPos
      if abs(item 1 of sPos[tK] - pX) <= 8 and abs(item 2 of sPos[tK] - pY) <= 8 then return tK
   end repeat
   repeat for each line tK in GADB.Ids("r")
      if abs(GADB.Get(tK, "x") - pX) <= 8 and abs(GADB.Get(tK, "y") - pY) <= 8 then return tK
   end repeat
   repeat for each line tK in GADB.Ids("b")
      if abs(GADB.Get(tK, "x") - pX) <= 24 and abs(GADB.Get(tK, "y") - pY) <= 16 then return tK
   end repeat
   return empty
end GADUI.HitAt

function GADUI.Name pId
   if pId is a point then return "the spot" && pId
   switch char 1 of pId
      case "b"
         return "Base" && pId
      case "r"
         return "X" && pId
      case "s"
         return "squad" && pId && "(" & GADB.Personnel(pId) & ")"
      case "m"
         if GADB.Mover(pId) is not pId then return GADUI.Name(GADB.Mover(pId))
         return GADB.Get(pId, "kind") && pId
   end switch
   return pId
end GADUI.Name

function GADUI.Describe pId
   local tD
   if char 1 of pId is "b" then
      put GADB.Get(pId, "detect") into tD
      if tD < 1 then return "An unknown place: nothing detected yet."
      return GADUI.Name(pId) && "of" && GADB.Faction(GADB.Get(pId, "owner"), "name") & GADUI.BaseInfo(pId)
   end if
   return GADUI.Name(pId) && "of" && GADB.Faction(GADB.OwnerOf(pId), "name")
end GADUI.Describe

-- what you know of a Base: detection 1 owner, 2 speed, 3 level, 4 details
function GADUI.BaseInfo pB
   local tD, tOut, tG, tN
   put GADB.Get(pB, "detect") into tD
   if tD >= 2 then put ", minions" && item 1 of GADB.Get(pB, "kinds") after tOut
   if tD >= 3 then put ", level" && GADB.Get(pB, "level") after tOut
   if tD >= 4 then
      put 0 into tN
      repeat for each line tG in GADB.Garrison(pB)
         add GADB.Personnel(tG) to tN
      end repeat
      put "," && tN && "inside" after tOut
   end if
   return tOut
end GADUI.BaseInfo

---------------------------------------------------------------- the turn

command GADUI.EndTurn
   local tTurn
   put GADB.Turn() into tTurn
   put GADB.EndTurn() into sLastEvents
   put empty into sSel
   put false into sDropX
   GADUI.Draw
   GADUI.Say "Turn" && tTurn && "played." && GADUI.Summary(sLastEvents)
end GADUI.EndTurn

function GADUI.Summary pEvents
   local tE, tOut, tBuilt
   put 0 into tBuilt
   set the itemDelimiter to tab
   repeat for each line tE in pEvents
      switch item 1 of tE
         case "built"
            if word 2 of item 5 of tE is "(1)" then add 1 to tBuilt
            break
         case "squad"
            if item 5 of tE contains "(1)" then put "A squad of" && item 4 of tE && "formed." & space after tOut
            break
         case "detect"
            put item 5 of tE & "." & space after tOut
            break
         case "computer"
            put "The computer sends" && item 4 of tE && "toward you!" & space after tOut
            break
         case "fight"
            put item 4 of tE & ":" && item 5 of tE & "." & space after tOut
            break
      end switch
   end repeat
   if tBuilt > 0 then put "Built" && tBuilt & "." & space before tOut
   return tOut
end GADUI.Summary

---------------------------------------------------------------- drawing

command GADUI.Say pText
   put pText into sSaid
   if there is a field "Status" then
      put "Turn" && GADB.Turn() & "   " & GADUI.SelText() & return & pText into field "Status"
   end if
end GADUI.Say

function GADUI.SelText
   if sDropX then return "Dropping an X"
   if sSel is empty then return "Nothing selected"
   return "Selected:" && GADUI.Name(sSel)
end GADUI.SelText

command GADUI.Draw
   local tB, tR, tM, tXY, tCol, tN, tPlace, tAt, tX, tY, tLabel, tE, tI, tT
   set the defaultStack to the short name of the owner of me
   lock screen
   lock messages
   GADUI.Clear
   GADUI.Furniture
   -- rendezvous X marks
   repeat for each line tR in GADB.Ids("r")
      put GADB.Get(tR, "x") into tX
      put GADB.Get(tR, "y") into tY
      GADUI.Poly "D:R:" & tR, (tX - 6) & "," & (tY - 6) & return & (tX + 6) & "," & (tY + 6) & return & return & \
            (tX - 6) & "," & (tY + 6) & return & (tX + 6) & "," & (tY - 6), kCyan, 2
   end repeat
   -- your Bases' send-to lines
   repeat for each line tB in GADB.Ids("b")
      if GADB.Get(tB, "owner") is not 1 or GADB.Get(tB, "sendto") is tB then next repeat
      put GADB.TargetXY(GADB.Get(tB, "sendto")) into tXY
      if tXY is not empty then GADUI.Poly "D:L:" & tB, GADB.XY(tB) & return & tXY, kCyanDim, 1
   end repeat
   -- Bases: grey until detected; Cyan yours; Green the computer's
   repeat for each line tB in GADB.Ids("b")
      put GADB.Get(tB, "x") into tX
      put GADB.Get(tB, "y") into tY
      put GADUI.BaseColour(tB) into tCol
      GADUI.Box "D:B:" & tB, (tX - 24) & "," & (tY - 16) & "," & (tX + 24) & "," & (tY + 16), tCol
      if GADB.Get(tB, "owner") is 1 then
         put tB & return & "L" & GADB.Get(tB, "level") && GADB.Get(tB, "assembly") & "%" into tLabel
         GADUI.Label "D:T:" & tB, tLabel, (tX - 40) & "," & (tY - 48) & "," & (tX + 40) & "," & (tY - 16), kText
      else
         if GADB.Get(tB, "detect") < 1 then
            put "?" into tLabel
         else
            put tB && GADB.Get(tB, "detect") & "/4" & return & char 3 to -1 of GADUI.BaseInfo(tB) into tLabel
         end if
         GADUI.Label "D:T:" & tB, tLabel, (tX - 60) & "," & (tY - 48) & "," & (tX + 60) & "," & (tY - 16), kTextGrey
      end if
   end repeat
   -- movers: a small square each; several at one place side by side; at a Base, under it
   put empty into sPos
   put empty into tAt
   repeat for each line tM in GADB.Movers()
      if not GADB.Seen(tM) then next repeat
      put GADB.XY(tM) into tXY
      add 1 to tAt[tXY]
      put tAt[tXY] - 1 into tN
      put GADB.BaseAt(item 1 of tXY, item 2 of tXY, 2) into tPlace
      if tPlace is empty then
         put item 1 of tXY + tN * 16 into tX
         put item 2 of tXY into tY
      else
         put item 1 of tXY - 16 + tN * 16 into tX
         put item 2 of tXY + 26 into tY
      end if
      put tX & "," & tY into sPos[tM]
      if GADB.OwnerOf(tM) is 1 then
         put kCyan into tCol
         if GADB.Get(tM, "state") is "move" then
            put GADB.TargetXY(GADB.Get(tM, "sendto")) into tT
            if tT is not empty then GADUI.Poly "D:L:" & tM, tX & "," & tY & return & tT, kCyanDim, 1
         end if
      else
         put kGreen into tCol
      end if
      if char 1 of tM is "s" then
         GADUI.Box "D:M:" & tM, (tX - 7) & "," & (tY - 7) & "," & (tX + 7) & "," & (tY + 7), tCol
      else
         GADUI.Box "D:M:" & tM, (tX - 5) & "," & (tY - 5) & "," & (tX + 5) & "," & (tY + 5), tCol
      end if
      put empty into tLabel
      if GADB.Personnel(tM) > 1 then put GADB.Personnel(tM) into tLabel
      if GADB.Get(tM, "state") is "move" and GADB.OwnerOf(tM) is 1 then put space & GADB.Get(tM, "turnsLeft") & "t" after tLabel
      if tLabel is not empty then
         GADUI.Label "D:N:" & tM, tLabel, (tX + 7) & "," & (tY - 8) & "," & (tX + 47) & "," & (tY + 8), kText
      end if
   end repeat
   -- the selection
   if sSel is not empty then
      if char 1 of sSel is "b" then
         put GADB.Get(sSel, "x") into tX
         put GADB.Get(sSel, "y") into tY
         GADUI.Frame "D:sel", (tX - 28) & "," & (tY - 20) & "," & (tX + 28) & "," & (tY + 20)
      else if sPos[GADB.Mover(sSel)] is not empty then
         put sPos[GADB.Mover(sSel)] into tXY
         GADUI.Frame "D:sel", (item 1 of tXY - 10) & "," & (item 2 of tXY - 10) & "," & (item 1 of tXY + 10) & "," & (item 2 of tXY + 10)
      end if
   end if
   -- sparks and the result word where a fight was
   put 0 into tI
   set the itemDelimiter to tab
   repeat for each line tE in sLastEvents
      if item 1 of tE is not "fight" then next repeat
      add 1 to tI
      GADUI.Sparks tI, item 2 of tE, item 3 of tE, item 4 of tE
   end repeat
   set the itemDelimiter to comma
   unlock messages
   unlock screen
   GADUI.Say sSaid
end GADUI.Draw

function GADUI.BaseColour pB
   if GADB.Get(pB, "owner") is 1 then return kCyan
   if GADB.Get(pB, "detect") < 1 then return kGrey
   return kGreen
end GADUI.BaseColour

-- a ring of short lines and the word, until the next turn
command GADUI.Sparks pN, pX, pY, pWord
   local tA, tR1, tR2, tCol
   set the itemDelimiter to comma
   repeat with tA = 0 to 7
      put 8 + (tA mod 2) * 6 into tR1
      put tR1 + 10 + (tA mod 3) * 4 into tR2
      if tA mod 2 is 0 then
         put kSpark1 into tCol
      else
         put kSpark2 into tCol
      end if
      GADUI.Poly "D:S:" & pN & ":" & tA, round(pX + tR1 * cos(tA * pi / 4)) & "," & round(pY + tR1 * sin(tA * pi / 4)) & return & \
            round(pX + tR2 * cos(tA * pi / 4)) & "," & round(pY + tR2 * sin(tA * pi / 4)), tCol, 2
   end repeat
   GADUI.Label "D:W:" & pN, pWord, (pX - 50) & "," & (pY + 22) & "," & (pX + 50) & "," & (pY + 44), kSpark1
   set the textSize of field ("D:W:" & pN) to 16
   set the textStyle of field ("D:W:" & pN) to "bold"
end GADUI.Sparks

command GADUI.Clear
   local tI
   repeat with tI = the number of controls of this card down to 1
      if the short name of control tI of this card begins with "D:" then delete control tI of this card
   end repeat
end GADUI.Clear

-- the map and the status bar (made once, kept)
command GADUI.Furniture
   set the backgroundColor of this card to "40,42,48"
   if there is not a graphic "Map" then
      create graphic "Map"
      set the style of graphic "Map" to "rectangle"
      set the opaque of graphic "Map" to true
      set the filled of graphic "Map" to true
      set the backgroundColor of graphic "Map" to kMapBack
      set the foregroundColor of graphic "Map" to kGrey
      set the rect of graphic "Map" to kMapRect
   end if
   if there is not a field "Status" then
      create field "Status"
      set the lockText of field "Status" to true
      set the traversalOn of field "Status" to false
      set the opaque of field "Status" to false
      set the showBorder of field "Status" to false
      set the textSize of field "Status" to 12
      set the textColor of field "Status" to kText
      set the rect of field "Status" to kStatusRect
   end if
end GADUI.Furniture

command GADUI.Box pName, pRect, pColour
   create graphic pName
   set the style of graphic pName to "rectangle"
   set the filled of graphic pName to true
   set the opaque of graphic pName to true
   set the backgroundColor of graphic pName to pColour
   set the foregroundColor of graphic pName to pColour
   set the rect of graphic pName to pRect
end GADUI.Box

command GADUI.Frame pName, pRect
   create graphic pName
   set the style of graphic pName to "rectangle"
   set the filled of graphic pName to false
   set the opaque of graphic pName to false
   set the foregroundColor of graphic pName to "255,255,255"
   set the lineSize of graphic pName to 2
   set the rect of graphic pName to pRect
end GADUI.Frame

command GADUI.Poly pName, pPoints, pColour, pLineSize
   create graphic pName
   set the style of graphic pName to "polygon"
   set the filled of graphic pName to false
   set the opaque of graphic pName to false
   set the foregroundColor of graphic pName to pColour
   set the lineSize of graphic pName to pLineSize
   set the points of graphic pName to pPoints
end GADUI.Poly

command GADUI.Label pName, pText, pRect, pColour
   create field pName
   set the lockText of field pName to true
   set the traversalOn of field pName to false
   set the opaque of field pName to false
   set the showBorder of field pName to false
   set the textSize of field pName to 11
   set the textAlign of field pName to "center"
   set the textColor of field pName to pColour
   set the rect of field pName to pRect
   put pText into field pName
end GADUI.Label
