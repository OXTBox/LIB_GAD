local sTool = ""
local sSelObj = ""

on makeGrid
   lock screen
   put the gridSize into tGrid
   set the width of grc "hLine" of group "bnGrid" to tGrid + 1
   set the height of grc "vLine" of group "bnGrid" to tGrid + 1
   set the bottomright of grc "hLine" of group "bnGrid" to the bottomright of grc "vLIne" of group "bnGrid"
   -- colorize

   set the foreGroundColor of grc "hLine" to the linkVisitedColor of this stack
   set the foreGroundColor of grc "vLine" to the linkVisitedColor of this stack
   
   export snapshot from group "bnGrid" to tImg as png
   if not (there is an image "bgPattern" of group "bnGrid") then
      create invisible image "bgPattern" in group "bnGrid"
   end if
   set the text of image "bgPattern" of group "bnGrid" to tImg
   set the backgroundPattern of this card to the short id of image "bgPattern"  of group "bnGrid"
   unlock screen
end makeGrid


########################
-- Hermann
on mouseUp
   if not (the behavior of me is empty) then exit mouseUp -- to allow handling of widget in plug-in
   put "showGridWidget" into sgw
   if ("button " is in the target) or (not the hilite of btn "gridonoff" of grp sgw)
   then pass mouseUp
   ## SNAP EDGES:
   # option up => Top | option down => Bottom
   # shift up => Left | shift down => Right
   if the shiftkey is up then -- xL = TL or BL
      if the optionkey is up then
         set topLeft of grp sgw to snapToGrid (the topLeft of grp sgw, "TL")
      else set bottomLeft of grp sgw to snapToGrid (the bottomLeft of grp sgw, "BL")
   else -- xR = TR or BR
      if the optionkey is up then
         set topRight of grp sgw to snapToGrid (the topRight of grp sgw, "TR")
      else set bottomRight of grp sgw to snapToGrid (the bottomRight of grp sgw, "BR")
   end if
end mouseUp

private function snapToGrid pPoint, pChoice, pGrid
  put item 1 of pPoint into p; put item 2 of pPoint into q
  switch pChoice
    case "topleft";     case "TL"; put 0 into h; put 0 into v; break
    case "topright";    case "TR"; put 1 into h; put 0 into v; break
    case "bottomleft";  case "BL"; put 0 into h; put 1 into v; break
    case "bottomright"; case "BR"; put 1 into h; put 1 into v; break
    default; put -1 into h; put -1 into v; break
  end switch
  if pGrid is empty then put the gridSize into g
  return ( h*g + p - (p mod g), v*g + q - (q mod g) )
end snapToGrid

-- end Hermann
#################



-- on newGroup
--    -- sent when a group is first time placed on a card
--    set the uOrigBackgroundPattern of me to the backgroundPattern of this card
--    set the uOrigBackgroundColor of  me to the backgroundColor of this card
--    makeGrid
--    set the label of button "gridMaker" of me to "hide Grid"
--    lock messages
--    set the hilite of button "gridOnOff" to the grid
--    if there is a stack "revPreferences" then
--       put the cGridSize of stack "revPreferences" into tGridSize
--       if tGridSize <> "" then 
--          put tGridSize into field "gridSpacing" of me
--       end if
--    end if
--    unlock messages
--    -- uncouple the group from its behavior
--    set the behavior of me to ""
--    focus on nothing
--    send "set the selected of me to false" to me in 5 milliseconds
--    pass newGroup
-- end newGroup

on preOpenControl
   if there is a stack "revPreferences" then
      put the cGridSize of stack "revPreferences" into tGridSize
      if tGridSize <> "" then 
         put tGridSize into field "gridSpacing" of me
      end if
   end if
   set the hilite of button "gridOnOff" to the grid
   pass preOpenControl
end preOpenControl

on openControl
   focus on nothing
   pass openControl
end openControl

on deleteGroup
   put the uOrigBackgroundPattern of me into tBackPattern
   put the uOrigBackgroundColor of  me into tBackColor
   
   lock screen
   if the backPattern of this card <> "" then set the backPattern of this card to tBackPattern
   if tBackColor <> "" then set the backgroundColor of this card to tBackColor
   unlock screen
   if sTool <> "" then set the tool to sTool 
end deleteGroup

-- on mouseEnter
--    put the tool into sTool
--    put the selectedObjects into sSelObj
--    set the tool to browse
-- end mouseEnter

-- on mouseLeave
--    if sSelObj <> "" AND sTool contains "pointer" then
--       lock screen
--       repeat for each line anObject in sSelObj
--          set the selected of anObject to true
--       end repeat
--    end if
--    if sTool <> "" then set the tool to sTool 
-- end mouseLeave


on checkAndStoreBGColor
   put the uOrigBackgroundColor of  me into tBackColor
   if the backgroundColor of this card <> tBackColor then
      set the uOrigBackgroundColor of me to the backgroundColor of this card
   end if
end checkAndStoreBGColor

on checkAndRestoreBGColor
   set the backgroundColor of this card to the uOrigBackgroundColor of me
end checkAndRestoreBGColor

on mouseDown
   if not (the long name of me contains "gridDrawer") then
      grab me
   else
      pass mouseDown
   end if
end mouseDown

