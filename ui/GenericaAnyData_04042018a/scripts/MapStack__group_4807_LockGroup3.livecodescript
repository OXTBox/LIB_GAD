on mouseUp
   put "group" && (word 2 the name of me)  into thisGroup
   put char -2 of thisGroup into myNumber
   put "set the enabled of scrollbar" && quote & "TurfScrollbar" & myNumber & quote & "to"  into myScroll
   
   set the cActive of me to not the cActive of me
   if the cActive of me is true then
      set the startAngle  of graphic "Oval" of thisGroup to 0
      set the arcAngle of graphic "Oval" of thisGroup to 360
      put myScroll && "false" into myCommand
   else
      set the startAngle  of graphic "Oval" of thisGroup to 270
      set the arcAngle of graphic "Oval" of thisGroup to 180
      put myScroll && "true"  into myCommand
   end if
   do myCommand
end mouseUp
