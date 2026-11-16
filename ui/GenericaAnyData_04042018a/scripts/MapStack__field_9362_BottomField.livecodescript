on mouseUp
   put word 2 the selectedLine of me into n
   put line n of me
   --put the hilitedItem of me && the hilitedItemName of me
   --put "go to card" && the hilitedItem of me && " of stack (the mainStack of this stack)" into tCommand
   --do tCommand
   --put tCommand -- the name of the current card
   pass mouseUp
end mouseUp
