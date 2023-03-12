 json←{jlev}XMLtoJSON xml;j;x;level;mask;chunk;data;name;type
 ⍝ convert XML to JSON
 ⍝ xml is a character vector of XML
 ⍝ json is a charcter vector of JSON representation of the data in XML
 ⍝ json← XMLtoJSON xml     ⍝ will convert elements that look like scalar number to numeric
 ⍝ json← ¯1 XMLtoJSON xml  ⍝ will suppress numeric conversion
 ⍝

 :If 0=⎕NC'jlev'                                ⍝ initial call?
 :OrIf jlev=¯1
     jlev←{6::⍵ ⋄ jlev}0                        ⍝ or suppress numbers
     x←⎕XML⍠'Markup' 'Strip'⊢xml                ⍝ parse XML into matrix format
     :If jlev≠¯1
         x[;3]←{t←⎕VFI ⍵ ⋄ (,1)≡1⊃t:⊃2⊃t ⋄ ⍵}¨x[;3] ⍝ convert numbers
     :EndIf
     json←1 4⍴0 '' '' 1                         ⍝ initialize result
     json⍪←0 XMLtoJSON x                        ⍝ and here we go...
     json←⎕JSON⍠'Format' 'M'⊢json               ⍝ make sure it's valid JSON
 :Else
     jlev+←1                                    ⍝ bump the JSON level
     level←⊃xml                                 ⍝ get the XML level
     mask←xml[;1]=level                         ⍝ mark all siblings to the first element
     xml←⊃⍪/(mask⊂[1]xml)[⍋mask/xml[;2]]        ⍝ group/sort by names
     json←0 4⍴0 '' '' 0                         ⍝ initialize this chunk's result
     mask←xml[;1]=level                         ⍝ set up to partition by name at this same level
     mask←mask\1,2≢/mask/xml[;2]                ⍝ group by name
     :For chunk :In mask⊂[1]xml                 ⍝ for each group
         name←(⊂1 2)⊃chunk                      ⍝ grab the name
         data←(⊂1 3)⊃chunk                      ⍝ and the data if any
         type←4-2|⎕DR data                      ⍝ note the datatype
         :If 0∊⍴name                            ⍝ if no name (we blanked it out to process arrays)
             :If 1=≢chunk                       ⍝ only a single element?
                 json⍪←jlev''data type          ⍝ append its entry
             :Else
                 json⍪←jlev'' '' 1              ⍝ otherwise append object entry
                 json⍪←jlev XMLtoJSON 1↓chunk   ⍝ and process the object's content
             :EndIf
         :Else
             :If 1=+/chunk[;1]=⊃chunk           ⍝ only one item at this level implied its an object
                 :If 1=≢chunk                   ⍝ leaf element?
                     json⍪←jlev name data type  ⍝ append its data
                 :Else
                     json⍪←jlev name'' 1        ⍝ note that it's an object
                     json⍪←jlev XMLtoJSON 1↓chunk ⍝ and process its content
                 :EndIf
             :Else                              ⍝ more than one item at this level means its an array
                 json⍪←jlev name'' 2            ⍝ append array entry
                 mask←chunk[;2]≡¨⊂name          ⍝ find all elements named the same
                 chunk[;2]←(~mask)/¨chunk[;2]   ⍝ blank out the names
                 json⍪←⊃⍪/jlev XMLtoJSON¨mask⊂[1]chunk  ⍝ process each element
             :EndIf
         :EndIf
     :EndFor
 :EndIf
