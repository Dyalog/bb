 cube;pg;wrapper;cube;faces
 pg←⎕NEW WC2.Page
 pg.Size←650 850
 pg.Use'JQuery'
 pg.Add _.title'Simple 3D Cube'
 pg.Add _.StyleSheet'cube.css'
 wrapper←'#wrapper'pg.Add _.div
 cube←'#cube'wrapper.Add _.div
 faces←('.face '∘,¨'.',¨'one' 'two' 'three' 'four' 'five' 'six')pg.New¨_.div
 cube.Add¨faces
 faces[1].Add _.Table(2 0∘⍕¨¯1+10 10⍴⍳100)
 faces[2].Add'Simple 3D Cube Demo'
 faces[3].Add _.img'src="APLTools.png"'
 faces[4].Add _.APL(↑{⍵(⍕⍎⍵)}'{{⍵,+/¯2↑⍵}/⌽⍳⍵} 9')
 faces[5].Add _.img'src="Duck.png"'
 faces[6].Add'This face intentionally left blank.'
 pg.Add _.Script'' 'cube.js'
 pg.Run
