 battleship←{
     badShips←⍬                                            ⍝ initialize the list of ships that don't fit
     allIndices←,⍳size←2⍴⍺                                 ⍝ precompute all board indices
     placeShip←{
         0∊⍴⍵:('∘123456789',⎕A)[1+⍺]                       ⍝ no ships left?  return the board
         a←⍺                                               ⍝ make a copy so we can assign into it
         length←⊃⍵                                         ⍝ length of the current ship
         available←,⊃+/⍺∘(length{(⍴⍺)↑⍵×⍺⍺∧/[⍵]~×⍺})¨1 2   ⍝ available starting positions
         ~∨/×available:a⊣badShips,←⊂1↑⍵                    ⍝ if none available, append current ship to badShips and return the board
         index←{⍵[?≢⍵]}{⍵/⍳≢⍵}×available                   ⍝ pick a random available start
         start←index⊃allIndices                            ⍝ get its board position
         direction←available[index]⊃1 2(?2)                ⍝ determine the direction
         a[⊃,¨/start+¨direction⌽(¯1+⍳length)∘×¨0 1]←2⊃,⍵   ⍝ update the board with the index of this ship
         a placeShip 1↓⍵                                   ⍝ and move onto the next ship
     }
     ⌽badShips((size⍴0)placeShip ⍵{(⍺[⍵]),⍪⍵}⍒⍵)           ⍝ initialization (work from largest ship to smallest)
                                                           ⍝ badShips is to the left so that it has the updated value from call(s) to placeShip
 }
