 GSearch←{
     ⎕IO←1
     term←∊('+'@(' '∘=))⍵  ⍝ convert spaces (other conversions may be needed)
     z←HttpCommand.Get'https://www.google.com/search?q="',term,'"'
     0≠z.rc:z
     0=i←⊃⍸'id="resultStats"'⍷z.Data:'No results element found'z
     {⊃(//)⎕VFI ⎕D∩⍨(⍵⍳'>')↓(¯1+⍵⍳'<')↑⍵}i↓z.Data
 }
