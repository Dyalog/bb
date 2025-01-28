 dlls←{ver}CongaDlls paths;⎕ML;⎕IO;path;candidates;matches
⍝ attempt to retrieve Conga shared library names
⍝ paths can be 0 or more paths to search for the shared libraries
⍝   if paths is empty, then we look in the current directory first and then directory where the Dyalog executable is found
⍝ ver is the 2-digit Conga version to look for ('35' = Conga version 3.5)
⍝   if ver is not specified, then we take the highest version found, if any
⍝ dlls are the Conga shared libraries found, the ssl shared library is slaways second
⍝   if both shared libraries are not found, dlls is '' ''

 (⎕ML ⎕IO)←1
 dlls←'' ''
 ver←⍕{6::⍵ ⋄ ver}''
 :If 0∊⍴paths
     paths←⊃¨1 ⎕NPARTS¨''(⊃2 ⎕NQ #'GetCommandLineArgs')
 :EndIf
 :For path :In ,⊆paths
     :If ~0∊⍴candidates←⊃⎕NINFO⍠1⊢path(⊣,('/'=(⊢/⊣))↓⊢)'/conga',ver,'*.*'
     :AndIf 2≤≢matches←∊'\/conga\d{2,}'⎕S{⍵}¨⊢candidates
         matches←2↑matches[⍒matches.Block]
         :If ≡/matches.Match  ⍝ make sure they're the same version
             dlls←matches.Block[⍋(1∊'ssl'∘⍷)¨matches.Block]
             :Leave
         :EndIf
     :EndIf
 :EndFor
