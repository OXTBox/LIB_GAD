on mouseUp
   put the loc of graphic "sendto1" & cr into xy
   put the loc of graphic "sendto2" & cr after xy
   put the loc of graphic "sendto3" & cr after xy
   put the loc of graphic "sendto4"  after  xy
   set the points of me to xy
   
end mouseUp
