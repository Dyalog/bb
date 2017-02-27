 monty←{
 ⍝ Monty Hall Problem https://en.wikipedia.org/wiki/Monty_Hall_problem
 ⍝ ⍵ - # doors
 ⍝ ⍺ - # doors shown
     ⍺←1                              ⍝ default to 1 door shown
     select←{⍺←1 ⋄ ⍵[⍺?≢⍵]}           ⍝ random selection function
     doors←⍳⍵                         ⍝ the collection of doors
     (choice winner)←?2⍴⍵             ⍝ random choice and winner
     notchosen←doors~choice           ⍝ doors that weren't chosen
     shown←⍺ select notchosen~winner  ⍝ select non-winning doors to show
     winner=select notchosen~shown    ⍝ does play win if he changes his choice?
 }
