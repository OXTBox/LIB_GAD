on mouseUp
   set the hilite of me to not the hilite of me
   switch the hilite of me
      case true
         set the mapTool of group "Mapgroup" to "SendTo"
         break
      case false
         set the mapTool of group "Mapgroup" to "Select"
         break
   end switch
   
end mouseUp
