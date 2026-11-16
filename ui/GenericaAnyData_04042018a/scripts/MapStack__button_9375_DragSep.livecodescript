on mouseDown
    mouseDrag 
end mouseDown


on mouseDrag
   if  the mouse is down then
      set itemDel to comma
      put item 1 of the loc of me into x
      put item 2 of the mouseloc into y
      if y <800 and y > 100 then
         lock screen
         set the loc of me to x,y
         
         put the top of me into nBottom
         put the bottom of me+2 into nTop
         put left of me into L
         put the right of me into R
         put the bottom of field "ListsLabel" into tTop
         put the bottom of group "mapgroup" into tBottom
         set the rect of field "Topfield" to L,tTop,R,nBottom
         set the rect of field "BottomField" to L,nTop,R,tBottom
         put L& ","& y & cr & R& ","  & y into tPoints
         set the points of graphic "DragLine" to tPoints
      
         unlock screen
      end if
      if the mouse is down then send mouseDrag to me in 1 milliseconds
   end if 
end mouseDrag
