:Namespace _15_Puzzle_Game

    makeBoard←{⎕RL←0 ⋄ (2⍴⍵)⍴¯1+?⍨⍵*2} ⍝ make an n×n random board, 0 is where the space is
    showBoard←'BI2'∘⎕FMT¨      ⍝ display the board

      move←{ ⍝ ⍺ is the board, ⍵ is the tile to move
          (board tile)←⍺ ⍵
          coord←board{1+(⍴⍺)⊤¯1+(,⍺)⍳⍵}tile,0 ⍝ find coordinates of tile and 0 in the board
          ~∨/rc←=/coord:board  ⍝ 0 not in same row or column as tile? → return board
          axis←⍸rc             ⍝ are we shifting a row or a column?
          index←coord[axis;1]  ⍝ row/column index in the board
          positions←,(~rc)⌿coord ⍝ positions of the tile and the 0 in the row/column
          (index⌷[axis]board)←positions doShift index⌷[axis]board
          board                            ⍝ return the updated board
      }

      doShift←{ ⍝ ⍺ is the positions of the tile and 0 in the row/column
                ⍝ ⍵ is the contents of row/column
          reverse←>/⍺      ⍝ is the 0 before tile?  if so we will reverse the row/column
          position←(1+≢⍵)∘-⍣reverse⊃⍺    ⍝ calculate the tile's position whether or not the row/column has been reversed
          rev←⌽⍣reverse                  ⍝ conditional reverse
          rev position shiftRight rev ⍵  ⍝ perform the shift, conditionally reversing before and after
      }

      shiftRight←{ ⍝ ⍺ is the position to shift from, ⍵ is a vector of the contents of the row/column
                   ⍝ the empty space (0) is always assumed to be to the right of the position to shift from
          (position vector)←⍺ ⍵
          (position-1){(⍺↑⍵),{(⍵⍳0){⍺>≢⍵:⍵ ⋄ (¯1⌽⍺↑⍵),(⍺↓⍵)}⍵}⍺↓⍵}vector}

      play←{⎕←showBoard ⍵            ⍝ display the current board
          ⍵≡(⍴⍵)⍴1⌽¯1+⍳≢,⍵:'Winner!' ⍝ check if it's a winner
          inp←{(⍴⍵)↓⍞⊣⍞←⍵}'Enter tile number to shift (or just Enter to quit): '  ⍝ grab user input
          0∊⍴inp:'You gave up'       ⍝ did the user give up?
          ∇ ⍵ move⊃(//)⎕VFI inp      ⍝ otherwise make the move and recurse
      }


      play2←{⎕←showBoard ⍵
          ⍵≡(⍴⍵)⍴1⌽¯1+⍳≢,⍵:'Winner!' ⍝ check if it's a winner
          inp←{(⍴⍵)↓⍞⊣⍞←⍵}'Enter one of u,d,l,r or just Enter to quit: '  ⍝ grab user input
          0∊⍴inp:'You gave up'      ⍝ did the user give up?
          ∇ ⍵ move2'udlr'⍳⊃inp      ⍝ otherwise make the move and recurse
      }

      move2←{ ⍝ ⍺ is the board, ⍵ is the direction 1-up, 2-down, 3-left, 4-right
          (board dir)←⍵ ⍺
          3::board                      ⍝ trap INDEX ERROR (error number 3)
                                        ⍝ this will catch invalid input
                                        ⍝ or a move that can't be made based on position of 0
          zero←1+(⍴board)⊤¯1+(,board)⍳0 ⍝ find position of 0 in the board
          tileToMove←zero+dir⊃(1 0)(¯1 0)(0 1)(0 ¯1)    ⍝ find position of the tile to move
          board[zero tileToMove]←board[tileToMove zero] ⍝ swap them
          board                                         ⍝ and return the updated board
      }

      solvable←{ ⍝ ⍵ is an n×n board
          inversions←+/{⍵+.<⊃⍵}¨{(↓∘⍵)¨¯1+⍳≢⍵}0~⍨,⍵
          2|2⊃⍴⍵:~2|inversions
          =/2|inversions,⊃⊃⍸0=⍵
      }


:EndNamespace
