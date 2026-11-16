on mouseUp
   put the long id of the owner of me into tName
   if not (the long name of me contains "gridDrawer") then
      send "delete tName" to the long id of  the owner of me in 5 milliseconds
   end if
end mouseUp
