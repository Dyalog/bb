 findfiles←{
     0∊⍴⍵:''
     ⍺←'*.*'
     folder←{⍵,'/'/⍨'/'≠¯1↑⍵}∊1 ⎕NPARTS ⍵
     folders←⊃{(⍵=1)/⍺}/0 1(⎕NINFO⍠1)folder,'*'
     files←((⊃⎕NINFO⍠1)folder,⍺)~folders
     0∊⍴folders:files
     (0∊⍴files)↓files,⊃,/⍺∘∇¨folders
 }
