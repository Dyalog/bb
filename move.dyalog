:Namespace move
⍝ This is a solver for Move, a game for iOS and Android by Nitako
⍝ http://www.nitako.com/wp/blog/projects/move/

    ∇ moves←board solve start;history;solution;queue;next;keep;mask 
    ⍝ board is an integer representation of the board where 0 = blank (non-colored) cell, ¯1 = blocked cell, n = cell of color n
    ⍝ start is the board representation of the ball starting positions where n corresponds to the color in board
    ⍝ queue is the list of board positions to examine
    ⍝ history is the list of board positions we've looked at
      (board start)←{2=≢⍴⍵:⍵ ⋄ ⍵{⍺{⍵⍴(×/⍵)↑⍺}2⍴⌈⍵*0.5}≢,⍵}¨{⍵↑¨⍨⌈/≢¨⍵}board start
      queue←history←,⊂start
      solution←⊂0⌈board
      moves←0
      :Repeat
          next←queue∘.(board move)⍳4
          keep←~,next∊history
          queue←keep/,next
          keep←(⍴next)⍴keep\mask←(⍳≢queue)=queue⍳queue
          history,←queue←mask/queue
          moves←⊃,/moves{,(⊂⍺)∘.,⍵}¨(↓keep)/¨⊂⍳4
      :Until (solution∊queue)∨0∊⍴queue
      moves←'←→↑↓?'[1↓(queue⍳solution)⊃moves,⊂0 5]
    ∇  

    ∇ positions←positions(board move)dir;f
      :Select ⊃dir
      :Case 1 ⋄ f←⊢  ⍝ left
      :Case 2 ⋄ f←⌽  ⍝ right
      :Case 3 ⋄ f←⍉  ⍝ down
      :Case 4 ⋄ f←⌽⍉ ⍝ up
      :EndSelect
      positions←(f⍣¯1)(f board)shift f positions
    ∇

    ∇ positions←board shift positions;ind;newind
    ⍝ perform a left-shift
      :For ind :In (,0≠positions)/,⍳⍴positions
          :If 0∧.<newind←0 ¯1+ind ⍝ is the new position on the board?
          :AndIf 0∧.=newind∘⌷¨(board⌊0)positions ⍝ and is it available and unoccupied?
              positions[ind newind]←positions[newind ind] ⍝ then move it
          :EndIf
      :EndFor
    ∇
:EndNamespace
