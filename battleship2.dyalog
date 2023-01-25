 battleship2←{
     badShips←⍬
     allIndices←,⍳size←2⍴⍺
     board←size⍴0
     placeShip←{
         length←⊃⍵                                         ⍝ length of the current ship
         available←,⊃+/board∘(length{(⍴⍺)↑⍵×⍺⍺∧/[⍵]~×⍺})¨1 2   ⍝ available starting positions
         index←{⍵[?≢⍵]}{⍵/⍳≢⍵}×available                   ⍝ pick a random available start
         start←index⊃allIndices                            ⍝ get its board position
         direction←available[index]⊃1 2(?2)                ⍝ determine the direction
         board[⊃,¨/start+¨direction⌽(¯1+⍳length)∘×¨0 1]←2⊃,⍵   ⍝ update the board with the index of this ship
         board
     }
     ⌽badShips('∘123456789',⎕A)[1+⊃⊢/placeShip¨↓⍵{(⍺[⍵]),⍪⍵}⍒⍵] ⍝ initialization (work from largest ship to smallest)
 }
