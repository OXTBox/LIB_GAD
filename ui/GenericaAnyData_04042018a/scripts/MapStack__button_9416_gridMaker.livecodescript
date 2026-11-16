on mouseUp
   if the label of me = "show Grid" then
      lock screen
      checkAndStoreBGColor
      if field "gridSpacing" of me <> gridSize then 
         send "setGridSizeAndMakeGrid" to field "gridSpacing" of the owner of me
      else
         makeGrid
      end if
      unlock screen
      set the label of me to "hide Grid"
      exit mouseUp
   end if
   if the label of me = "hide Grid" then
      set the backgroundPattern of this card to ""
      checkAndRestoreBGColor
      set the label of me to "show Grid"
   end if
end mouseUp
