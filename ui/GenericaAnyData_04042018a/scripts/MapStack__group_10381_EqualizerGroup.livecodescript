on mouseUp
   put  the selectedMapObjectName of this stack into tSelection
    setOprop tSelection,"cGoalCommunity", 17
    setOprop tSelection,"cGoalPersonnel",  17
    setOprop tSelection,"cGoalAdvantage",  17
   

   
   set the thumbPosition of scrollbar "TurfScrollbar1" of card 1 to 17
   set the thumbPosition of scrollbar "TurfScrollbar2"  of card 1 to 17
   set the thumbPosition of scrollbar "TurfScrollbar3"  of card 1 to 17
end mouseUp
