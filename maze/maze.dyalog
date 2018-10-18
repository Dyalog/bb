:Namespace maze
    (⎕IO ⎕ML ⎕WX)←1 1 3

⍝ Dec2016 update
⍝ - added solvers section with one maze solver
⍝ - added show solution toggle button on HTML output
⍝ - dealt with 1×1 maze
⍝ Oct2018
⍝ - more compact way to filter valid neighbors 

    ∇ cells←{animate}maze size;neighbors;reagan;visited;pic;current;n;choices;next;left
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
     
      neighbors←{(⊂,⍵)∩¨↓⍵∘.+,1 ¯1∘.×1 0⌽¨⊂1 0}left←⍳size ⍝ calculate valid neighbors for each cell
     
      reagan←{{⍵[2]=0:{(1=⍵)⌽4 1}⍵[1] ⋄ {(1=⍵)⌽2 8}⍵[2]}⍺-⍵}  ⍝ Mr. Gorbachev tear down this wall
     
      cells←size⍴15 ⍝ all cells start with 4 walls
     
      visited←,⊂?size ⍝ random starting cell (remove it from list of cells not traversed)
     
      :If animate             ⍝ if we are animating...
          pic←1 draw cells    ⍝ draw the current maze
          ⎕ED&'pic'           ⍝ and display it in the editor in a separate thread
      :EndIf
     
      :If 1∨.≠size
          :While 15∊cells         ⍝ while we still have cells to examine
              current←1↑visited   ⍝ pop the most recent cell
              :If 0=n←⍴choices←cells{⍵/⍨15=⍺[⍵]}current⊃neighbors ⍝ does it have any neighbors that we haven't visited?
                  visited↓⍨←1     ⍝ if none, backtrack
              :Else
                  visited,⍨←next←choices[?n] ⍝ otherwise, add the new cell to the front of the list
                  cells[next current]-←⊃next⊃.reagan current ⍝ update cell values for which wall was removed
                  :If animate
                      ⎕DL 0.5                  ⍝ brief pause
                      pic←1 draw cells         ⍝ update the editor
                  :EndIf
              :EndIf
          :EndWhile
      :EndIf
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
      r[{(1+⍵)((¯1-⍵)+size×2*⍵)}0,ld]←'SE'
    ∇

      ldc←{⎕IO←0                                  ⍝ conv to line draw chars. (from John Scholes' dfns workspace)
          1<|≡⍵:∇¨⍵                               ⍝ nested: conv simple arrays.
          M←(1+⍴⍵)↑⍵                              ⍝ extra row col for rotate.
          R←(1 ¯1⌽¨⊂M),1 ¯1⊖¨⊂M                   ⍝ rotations of char mat.
          N←(M='+')×⊃1 2 4 8+.×R≠' '              ⍝ each neighbour of each +.
          ldcs←N⊃¨⊂'.───│┌┐┬│└┘┴│├┤┼'             ⍝ box drawing chars.
          S←(×N)select M ldcs                     ⍝ subs corner chars.
          ¯1 ¯1↓(⊃1 2+.×S∘=¨'-|')select S'─' '│'  ⍝ subs horiz and vert.
      }

    select←{⎕IO←0 ⋄ ⍺⊃¨↑,¨/⍵}                     ⍝ ⍺-select items of vector ⍵.


    ∇ r←{cellsize}html maze;⎕IO;enc;css;table;button;script
   ⍝ construct HTML to render a maze
   ⍝ maze - integer matrix describing the walls around each cell of the maze
   ⍝!!! cellsize - size (in px) of each cell - if not specified, we try to pick something that will fit
   ⍝ r - the HTML character vector to render the maze
     
      ⎕IO←0
      cellsize←{6::⍵ ⋄ cellsize}2⌈25⌊⌊⌊/1024 1280÷⍴maze  ⍝ pick a modest screen size to fit within
      enc←{(,⍺){'<',⍺,'>',(∊⍵),'</',(⍺⍴⍨⍺⍳' '),'>'}⍵}           ⍝ enclose an HTML element
     
   ⍝↓↓↓ define the CSS for the table and cells
      css←⊂'table {border-collapse: collapse;}'
      css,←⊂{'td {border-style: solid; border-color:black; height: ',(⍕⍵),'px; width: ',(⍕⍵),'px;}'}cellsize
     
   ⍝↓↓↓ define cell borders for each class of cell
      css,←{('td.c',⍕⍵),' {border-width:',(2⌽∊'px '∘,∘⍕¨⌽(4/2)⊤⍵),';}'}¨⍳16
      css,←⊂'td._1 {background:white;} td._2 {background:blue;background:radial-gradient(circle,blue,white,white,white);}'
      css←'style'enc css,¨⎕UCS 10
     
   ⍝↓↓↓ build a "solve" button
      button←'p'enc'button onclick="toggleSolution()"'enc'Show Solution'
     
   ⍝↓↓↓ build the script to toggle the solution
      script←'script'enc'function toggleSolution(){var i,nodes=document.getElementsByClassName("_1");for(i=0;i!=nodes.length;i++){(nodes[i].classList).toggle("_2");}};'
     
   ⍝↓↓↓ build the table, assigning each cell a class based on the borders it shares
      table←'table'enc'tr'∘enc¨{''enc⍨'td class="c',⍵,'"'}¨¨↓(⍕¨maze),¨' _'∘,∘⍕¨(1+⍳⍴maze)∊{⍵⊃⍨{⍵⍳⌈/⍵}⍴¨⍵}allPaths maze
     
   ⍝↓↓↓ construct the HTML document
      r←('markup' 'preserve'∘⎕XML⍣2)'<!DOCTYPE html>','html'enc'body'enc css,button,table,script
    ∇

    :section Maze Solver(s)

    ∇ r←allPaths args;eis;maze;start;end;openings;queue;current;path;next;⎕IO
    ⍝ return all paths between start and end positions in maze
    ⍝ arg ←→ [1] maze {[2] start position (default top left) {[3] end position (default bottom right)}}
      ⎕IO←1  ⍝ need this because it's called by ∇html which is ⎕IO←0
      eis←{(,∘⊂⍣(2>≡⍵))⍵}  ⍝ enclose if simple
      args←eis args
      maze←⊃args
      (start end)←(1↓args){eis¨⍺,(⍴⍺)↓⍵}(1 1)(⍴⊃args)
      openings←~2 2 2 2⊤maze
      r←⍬
      queue←,⊂start
      :Repeat
          current←¯1↑path←⊃queue
          queue↓⍨←1
          :If end≡current
              r,←⊂path
          :Else
              next←path~⍨current∘+((⊃current)(⌷⍤2)openings)/(0 ¯1)(1 0)(0 1)(¯1 0)
              :If ~0∊⍴next
                  queue,⍨←path∘,¨⊂¨next
              :EndIf
          :EndIf
      :Until 0∊⍴queue
    ∇
    :endsection

:EndNamespace
