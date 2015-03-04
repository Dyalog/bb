:Namespace maze
    (⎕IO ⎕ML ⎕WX)←1 1 3

    ∇ cells←{animate}maze size;valid;neighbors;dewall;visited;pic;current;n;choices;next;delay
     ⍝ Maze drawer - modeled after http://weblog.jamisbuck.org/2011/1/27/maze-generation-growing-tree-algorithm
     ⍝ BPB - Dec2014
     ⍝ size    - size of the maze in rows/cols
     ⍝ animate - Boolean indicating whether to animate maze creation
     ⍝ cells   - (2⍴size) integer matrix describing the walls around each cell using powers of 2
     ⍝       1
     ⍝     ┌───┐         ┌───┐
     ⍝   8 │   │ 2       │   │ = 11 = 1 + 2 + 8
     ⍝     └───┘
     ⍝       4
      size←2⍴size  ⍝ set size to square if singleton supplied as argument
     
      animate←{6::⍵ ⋄ animate}0 ⍝ default = no animation
     
      valid←{{⍵/⍨⍵≢¨⊂⍬}size∘{(0∊⍵)⍱⍵∨.>⍺:⍵ ⋄ ⍬}¨⍵} ⍝ determine if a maze coordinate is valid
      neighbors←valid¨↓(⍳size)∘.+,1 ¯1∘.×1 0⌽¨⊂1 0 ⍝ calculate neighbors for each cell
     
      dewall←{{⍵[2]=0:{(1=⍵)⌽4 1}⍵[1] ⋄ {(1=⍵)⌽2 8}⍵[2]}⍺-⍵}  ⍝ remove common wall between cells
     
      cells←size⍴15 ⍝ all cells start with 4 walls
     
      visited←,⊂?size ⍝ random starting cell (remove it from list of cells not traversed)
     
      :If animate           ⍝ if we are animating...
          pic←1 draw cells    ⍝ draw the current maze
          ⎕ED&'pic'           ⍝ and display it in the editor in a separate thread
          delay←4×÷×/size
      :EndIf
     
      :While 15∊cells       ⍝ while we still have cells to examine
          current←1↑visited   ⍝ pop the most recent cell
          :If 0=n←⍴choices←cells{⍵/⍨15=⍺[⍵]}current⊃neighbors ⍝ does it have any neighbors that we haven't visited?
              visited↓⍨←1       ⍝ if none, backtrack
          :Else
              visited,⍨←next←choices[?n] ⍝ otherwise, add the new cell to the front of the list
              cells[next current]-←⊃next⊃.dewall current ⍝ update cell values for which wall was removed
              :If animate
                  ⎕DL delay                  ⍝ brief pause
                  pic←1 draw cells         ⍝ update the editor
              :EndIf
          :EndIf
      :EndWhile
      :If animate ⋄ ⍞←'Press Enter...' ⋄ {}⍞ ⋄ :EndIf
    ∇

    ∇ r←{ld}draw maze;figures;⎕IO;size;f
    ⍝ maze - integer matrix describing the walls around each cell of the maze
    ⍝ ld   - optional Boolean flag indicating whether to use line drawing characters
    ⍝        ASCII characters are used by default
     
      ⎕IO←0
      :If 0∊⍴maze ⋄ r←(⍴maze)⍴' ' ⋄ →0 ⋄ :EndIf
      f←{⊂2 2⍴4↑⍵}
      figures←16⍴⊂''
      figures[0 2 4 6]←f'+'
      figures[1 3 5 7]←f'+-'
      figures[8 10 12 14]←f'+ |'
      figures[9 11 13 15]←f'+-|'
      r←(size←2×⍴maze)⍴∊,/figures[maze]
      r⍪←size[1]⍴'+-'
      r,←(1+size[0])⍴'+|'
      :If ld←{6::⍵ ⋄ ld}0
          r←ldc((1+size[1])⍴1 3)/r
      :EndIf
    ∇

      ldc←{⎕IO←0                                ⍝ conv to line draw chars. (from John Scholes' dfns workspace)
          1<|≡⍵:∇¨⍵                               ⍝ nested: conv simple arrays.
          M←(1+⍴⍵)↑⍵                              ⍝ extra row col for rotate.
          R←(1 ¯1⌽¨⊂M),1 ¯1⊖¨⊂M                   ⍝ rotations of char mat.
          N←(M='+')×⊃1 2 4 8+.×R≠' '              ⍝ each neighbour of each +.
          ldcs←N⊃¨⊂'.───│┌┐┬│└┘┴│├┤┼'             ⍝ box drawing chars.
          S←(×N)select M ldcs                     ⍝ subs corner chars.
          ¯1 ¯1↓(⊃1 2+.×S∘=¨'-|')select S'─' '│'  ⍝ subs horiz and vert.
      }

    select←{⎕IO←0 ⋄ ⍺⊃¨↑,¨/⍵}                   ⍝ ⍺-select items of vector ⍵.


    ∇ r←{cellsize}html maze;⎕IO;enc;css;table
   ⍝ construct HTML to render a maze
   ⍝ maze - integer matrix describing the walls around each cell of the maze
   ⍝ cellsize - size (in px) of each cell - if not specified, we try to pick something that will fit
   ⍝ r - the HTML character vector to render the maze
     
      ⎕IO←0
      cellsize←{6::⍵ ⋄ cellsize}2⌈25⌊⌊⌊/1024 1280÷⍴maze  ⍝ pick a modest screen size to fit within
      enc←{'<',⍺,'>',(∊⍵),'</',(⍺⍴⍨⍺⍳' '),'>'}           ⍝ enclose an HTML element
     
   ⍝↓↓↓ define the CSS for the table and cells
      css←⊂'table {border-collapse: collapse;}'
      css,←⊂{'td {border-style: solid; border-color:black; height: ',(⍕⍵),'px; width: ',(⍕⍵),'px;}'}cellsize
     
   ⍝↓↓↓ define cell borders for each class of cell
      css,←{('td.c',⍕⍵),' {border-width:',(2⌽∊'px '∘,∘⍕¨⌽(4/2)⊤⍵),';}'}¨⍳16
      css←'style'enc css,¨⎕UCS 10
     
   ⍝↓↓↓ build the table, assigning each cell a class based on the borders it shares
      table←'table'enc'tr'∘enc¨{''enc⍨'td class="c',(⍕⍵),'"'}¨¨↓maze
     
   ⍝↓↓↓ construct the HTML document
      r←('markup' 'preserve'∘⎕XML⍣2)'<!DOCTYPE html>','html'enc'body'enc css,table
    ∇

:EndNamespace
