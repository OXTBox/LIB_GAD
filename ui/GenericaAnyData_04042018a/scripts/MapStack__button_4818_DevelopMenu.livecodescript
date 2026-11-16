on menuPick pItemName
   put  line 1 of field "MapSelectionNameLabel" into tName
   if tName is not empty then
      put "graphic" && quote & tName & quote into tObj
      put "set the cCurrentDevelopType of" && tObj && "to" && pItemName into tCommand
      do tCommand
      
   end if
   --    switch pItemName
   --    end switch
end menuPick
