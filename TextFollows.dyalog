 r←TextFollows eol;⎕ML;⎕IO;lines;from;fn;dtlb;concom;remcom;delimit
  ⍝ Treat contiguous following commented lines in the calling function as a text block
  ⍝ Lines beginning with ⍝⍝ are stripped out
  ⍝
  ⍝ eol - the line ending sequence to insert between lines; ⍬ or '' will cause TextFollows to return a vector of vectors

 ⎕ML←⎕IO←1

 dtlb←{1↓¯1↓{⍵/⍨~'  '⍷⍵}' ',⍵,' '} ⍝ delete trailing/leading blanks
 concom←{1↓¨⍵/⍨∧\'⍝'=⊃¨⍵} ⍝ contiguous comments
 remcom←{⍵/⍨'⍝'≠⊃¨⍵} ⍝ remove lines that began with ⍝⍝
 delimit←{(≢eol)↓∊eol∘,¨⍵}⍣(~0∊⍴eol) ⍝ insert delimiters if they're not empty

 :If 0∊⍴lines←(from←⊃⎕RSI).⎕NR fn←2⊃⎕SI
     lines←↓from.(180⌶)fn  ⍝ 180⌶ exposes methods in classes
 :EndIf
 r←delimit remcom concom dtlb¨(1+2⊃⎕LC)↓lines ⍝ drop off lines up to and including this call to TextFollows
