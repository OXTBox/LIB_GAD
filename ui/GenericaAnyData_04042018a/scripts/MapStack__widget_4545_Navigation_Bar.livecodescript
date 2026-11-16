-- Sent when a navigation item is clicked
--
-- Use the "hilitedItem" property to get the current item number and the
-- "hilitedItemName" property to get its item name
on hiliteChanged
   put "go to card" && the hilitedItem of me && " of stack (the mainStack of this stack)" into tCommand
   do tCommand
   
end hiliteChanged
