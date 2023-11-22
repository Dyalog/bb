 json←{jlev}XMLtoJSON xml;x;level;mask;chunk;name;data;type;isArray;lastName;inds;t;single;nextlev;hasData;hasKids;isElement;siblings
 ⍝ convert XML to JSON
 ⍝ xml is a character vector of XML
 ⍝ json is a charcter vector of JSON representation of the data in XML
 ⍝ json← XMLtoJSON xml     ⍝ will convert elements that look like scalar number to numeric
 ⍝ json← ¯1 XMLtoJSON xml  ⍝ will suppress numeric conversion

 (hasData hasKids isElement)←6 7 8 ⍝ column references in XML

 :If 0=⎕NC'jlev'                                ⍝ initial call?
 :OrIf jlev=¯1
     jlev←{6::⍵ ⋄ jlev}0                        ⍝ or suppress numbers
     x←⎕XML⍠'Markup' 'Strip'⊢xml                ⍝ parse XML into matrix format
     x,←⍉2 2 2⊤x[;5]                            ⍝ add Element, Child and Data columns
     x[;5]←0                                    ⍝ reuse column to mark same-named siblings
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
     xml←⊃⍪/(mask⊂[1]xml)[⍋mask/xml[;2]]        ⍝ group like-named kids together
     mask←xml[;1]=level
     json←0 4⍴0 '' '' 0                         ⍝ initialize this chunk's result
     siblings←mask/xml[;2]                      ⍝ sibling names
     inds←siblings{⊆⍵}⌸⍸mask
     inds/⍨←1<≢¨inds                            ⍝ note same-named siblings (these will be arrays)
     xml[⊃¨inds;5]←1                            ⍝ mark first name of array
     xml[∊1↓¨inds;5]←2                          ⍝ mark subsequent elements of array
     :For chunk :In mask⊂[1]xml                 ⍝ for each group
         (name data)←chunk[1;2 3]
         single←0=+/nextlev←chunk[;1]=1+level
         :Select t←(⊂1 6)⊃chunk
         :Case 0
             type←⊃single↓(2-2|(⊂1 5)⊃chunk),type
             json⍪←jlev name data type
         :Case 1
             json⍪←jlev name'' 2
             :If ~single
                 json⍪←(jlev+1)'' '' 1
             :Else
                 json⍪←(jlev+1)''data type
             :EndIf
         :Case 2
             :If single
                 json⍪←(jlev+1)''data type
             :Else
                 json⍪←(jlev+1)'' '' 1
             :EndIf
         :EndSelect
         json⍪←(jlev+t>0)XMLtoJSON 1↓chunk   ⍝ and process the object's content
     :EndFor
 :EndIf
