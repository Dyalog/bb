:Namespace BigInt
    (⎕IO ⎕ML ⎕WX ⎕PP ⎕CT ⎕DIV)←1 1 3 34 0 1

    ∇ r←{A}(aa bi)W;monadic;chunks;sigA;absA;chkA;sigW;absW;chkW;dlz;sign;split;carry;fmt;even;comp;prep1;prep2;op;t;s;zero
⍝ Big Integer operator
     
      monadic←0=⎕NC'A'
      chunks←7
      zero←⍕0
      dlz←{0∊⍴r←⍵↓⍨+/∧\'0'=⍵:zero ⋄ r}
      sign←{(⊃⍵)∊'-¯':¯1(dlz 1↓⍵)
          ⍵∧.='0':0 zero
          1(dlz ⍵)}∘⍕
      split←{
          ⌽⍎¨↓⍵{(⍵,chunks)⍴(⍵×-chunks)↑⍺}⌈chunks÷⍨≢⍵
      } ⍝ split character vector BitInt into vector of integers
      carry←{
          0=+/⊃a b←↓0 10000000⊤,⍵:b
          ∇(b,0)+0,a
      }
      fmt←{
          ⍺←1
          (⍺≠¯1)↓'¯',{0∊⍴⍵:zero ⋄ ⍵}{⍵↓⍨+/∧\'0'=⍵}'0'@(=∘' ')7 0⍕⌽⍵
      }
      even←{l←(≢⍺)⌈≢⍵ ⋄ (l↑⍺)⍺⍺ l↑⍵}
      comp←{
 ⍝ set ⍵ to 0 to just compare absolute values
          ⍵∧sigA≠sigW:¯1 1[1+sigA>sigW]
          ⍵∧sigA=0:0
          -⍣(⍵∧sigA=¯1){⊃⍵⌷⍨⊂⍸<\⍵≠0}⌽×chkA-even chkW
      }
      prep1←{((sigA absA)(sigW absW))∘←sign¨⍺ ⍵}
      prep2←{(chkA chkW)∘←split¨⍺ ⍵}
     
      :Select op←∊⊃⎕NR'aa'
     
      :Case ,'×'
          :If monadic ⋄ →0⊣r←sign W ⋄ :EndIf
          A prep1 W
          :If 0=sigA×sigW ⋄ →0⊣r←,'0' ⋄ :EndIf
          absA prep2 absW
          r←+⌿+⌿0 1(⌽⍤0 2)((⊢-⍳)≢chkA)(⌽⍤1 2)(-+/≢¨chkA chkW)↑[3]0 10000000⊤chkA∘.×chkW
          r←(sigA×sigW)fmt carry r
     
      :Case ,'+'
          :If monadic ⋄ →0⊣r←⊃{(⍺≠¯1)↓'¯',⍵}/sign W ⋄ :EndIf
     ADD: A prep1 W
          :Select 2⊥0=sigA,sigW
          :Case 0 ⋄ absA prep2 absW
              :Select t←2⊥¯1=sigA,sigW
              :Case 0 ⍝ A,W>0
                  s←1 ⋄ r←chkA+even chkW
              :CaseList 1 2 ⍝ W<0
                  :Select comp 0
                  :Case ¯1 ⋄ s←t⊃¯1 1 ⋄ r←chkW-even chkA ⍝ W<0, |A < |W
                  :Case 0 ⋄ →0⊣r←zero
                  :Case 1 ⋄ s←t⊃1 ¯1 ⋄ r←chkA-even chkW
                  :EndSelect
              :Case 3 ⍝ A,W<0
                  s←¯1 ⋄ r←chkA+even chkW
              :EndSelect
              r←s fmt carry r
          :Case 1 ⋄ r←sigA fmt split absA ⍝ W=0
          :Case 2 ⋄ r←sigW fmt split absW ⍝ A=0
          :Case 3 ⋄ r←zero                ⍝ A,W=0
          :EndSelect
     
      :Case ,'-'
          W←r←⊃{(⍺<0)↓'¯',⍵}/sign W
          →(~monadic)↓0,ADD
     
      :Case ,'÷'
          A prep1 W ⋄ absA prep2 absW
          :Select comp 0
          :Case ¯1 ⋄ r←zero
          :Case 0 ⋄ r←(sigA×sigW)fmt 1-⎕DIV∧0=sigW
          :Case 1
              :If 0=sigW ⋄ ⎕SIGNAL 11 ⋄ :EndIf ⍝ divide by 0
          :EndSelect
     
      :CaseList ,¨'<≤=≥>≠'
          :If monadic ⋄ ⎕SIGNAL 2 ⋄ :EndIf
          A prep1 W ⋄ absA prep2 absW
          r←(comp 1)∊('<≤=≥>≠'⍳⊃op)⊃¯1(¯1 0)0(0 1)1(¯1 1)
     
      :Else
          ('Invalid function: ',op)⎕SIGNAL 11
      :EndSelect
    ∇

:EndNamespace
