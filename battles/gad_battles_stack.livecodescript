script "gad_battles_stack"
######################################################################################
## gad_battles_stack  (18 11 2026, Opus)  the stack script of GAD_Battles.oxtstack.
## It only loads: the logic library (gad_battles_rules.livecodescript, started as a library) and the
## card script (gad_battles_ui.livecodescript), both from the stack's own folder, then starts a game.
## Built into the stack by tools/build_stack.txt; edit the .livecodescript files, not the stack.
######################################################################################

on preOpenStack
   GADStack.Load
end preOpenStack

command GADStack.Load
   local tFolder, tUI, tMe
   put the long id of me into tMe   -- this stack, whatever the defaultStack is
   set the itemDelimiter to "/"
   put item 1 to -2 of the effective filename of tMe into tFolder
   set the itemDelimiter to comma
   start using stack (tFolder & "/gad_battles_rules.livecodescript")
   put textDecode(url ("binfile:" & tFolder & "/gad_battles_ui.livecodescript"), "UTF-8") into tUI
   if line 1 of tUI begins with "script " then delete line 1 of tUI
   set the script of card "Map" of tMe to tUI
   if the result is not empty then return "card script: " & the result
   set the title of tMe to "Opus | GAD_Battles"
   go card "Map" of stack (the short name of tMe)
   dispatch "GADUI.Start" to card "Map" of tMe with 7
   return empty
end GADStack.Load

-- the About card: any click or key goes back to the map
on mouseUp
   if the short name of this card is "About" then go card "Map"
end mouseUp

on keyDown pKey
   if the short name of this card is "About" then
      go card "Map"
   else
      pass keyDown
   end if
end keyDown

-- LIB_ALPHA 12b: let go of memory when it closes
on closeStackRequest
   local tMe
   put the long id of me into tMe
   set the destroyStack of tMe to true
   close stack (the mainStack of tMe)
end closeStackRequest

on closeStack
   if there is a stack "gad_battles_rules" then
      stop using stack "gad_battles_rules"
      delete stack "gad_battles_rules"
   end if
   pass closeStack
end closeStack
