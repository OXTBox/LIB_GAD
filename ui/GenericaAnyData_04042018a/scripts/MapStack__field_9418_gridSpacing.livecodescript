on keyDown pKey
   if pKey is among the items of "1,2,3,4,5,6,7,8,9,0" then pass keyDown
end keyDown

on enterInField
   setGridSizeAndMakeGrid
end enterInField

on returnInField
   setGridSizeAndMakeGrid
end returnInField

on closeField
   setGridSizeAndMakeGrid
end closeField

on tabKey
   setGridSizeAndMakeGrid
end tabKey

on setGridSizeAndMakeGrid
   set the gridSize to the text of me
   if there is a stack "revPreferences" then
      set the cGridSize of stack "revPreferences" to the text of me
   end if
   makeGrid
   set the label of button "gridMaker" of the owner of me to "hide Grid"
   focus on nothing
end setGridSizeAndMakeGrid
