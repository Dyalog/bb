:Namespace xhtml

    ⎕IO←⎕ML←1

    ∇ r←HTMLtoXHTML html;lco;lc;beginsWith;last;fixAmpersand;fixAttribute;inScript;fixScript;quoteAttr;closes;inds;noclose;msg;pos;scriptInsert;next;fixComment;char;fixAttributeCharacter;makeEntity;fixBadTag;fixMismatch;expect;lastpos;parsePos;endsWith;fixOrphan;fixImbalance
    ⍝ attempts to covert a character vector containing HTML to matrix form of XHTML
      lco←{(lc ⍺)⍺⍺(lc ⍵)}
      lc←0∘(819⌶)
      beginsWith←{⍵≡(≢⍵)↑⍺}
      endsWith←{⍵≡(-≢⍵)↑⍺}
      last←{⍸⌽<\⌽⍵⍷⍺↑⍺⍺}
      next←{⍸<\⍵⍷⍺↓⍺⍺}
      parsePos←{∨/'at end of text;'⍷⍺:⍵ ⋄ ⊃⊃(//)⎕VFI ⍺∩⎕D,' '}
      fixAmpersand←{
          ∊((⊂'&amp;')@(⍺(⍵ last)'&'))⍵
      }
      fixAttribute←{
          inds←¯2↑⍸' />'∊⍨⍺↑⍵
          ∊((⊂2⌽'"',⍵[inds[2]],'="',⍵[inds[1]+⍳¯1+-/⌽inds])@(2⊃inds))⍵
      }
      inScript←{ ⍝ did the exception occur inside a script?
          b←⍸'<script'⍷⍵
          e←⍸'</script>'⍷⍵
          _←0∧.<e-b ⍝ paranoia
          0=ind←b⍸⍺:⍬
          i1←b[ind]+'>'⍳⍨b[ind]↓⍵ ⍝ insert point 1
          i2←e[ind] ⍝ insert point 2
          ((i1<⍺)∧⍺<i2)/i1,i2 ⍝ returns script bounds or empty if not in script
      }
      fixScript←{
          (i1 i2)←⍺
          ∊((⊂,∘'//<![CDATA[')@i1)((⊂'//]]>'∘,)@i2)⍵
      }
      quoteAttr←{
          _←÷'='=⍵[⍺-1] ⍝ paranoia
          e←⍺+⌊/(⍺↓⍵)⍳' >'
          ∊((⊂'"'∘,)¨@(⍺,e))⍵
      }
      fixComment←{   ⍝ '--' inside of comments are a no-no,so replace them with '=='
          t←+/∧\'-'=⍺↓⍵   ⍝ trailing -
          l←+/∧\'-'=⌽⍺↑⍵  ⍝ leading -
          '!'=⍵[⍺-l]:('='@((⍺-l-2)+⍳t+l-2))⍵ ⍝ preserve beginning of comment
          '>'=⍵[1+⍺+t]:('='@((⍺-l)+⍳t+l-2))⍵ ⍝ preserve end of comment
          ('='@((⍺-l)+⍳t+l))⍵ ⍝ otherwise replace them all
      }
      fixAttributeCharacter←{
          err←⊂↓'EM' 'EN' 'Message',⍪⎕DMX.(EM EN Message)
          pos char←⍺
          char≠⍵[pos]:⎕SIGNAL err
          ∊((⊂makeEntity char)@pos)⍵
      }
      makeEntity←{
          ¯4↓3↓⎕XML 1 3⍴0 'z'⍵
      }
      fixBadTag←{
          '<'≠⍵[⍺-1]:∘∘∘ ⍝ expected '<' at this location
          ∊((⊂'&lt;')@(⍺-1))⍵
      }
      fixMismatch←{
          err←⊂↓'EM' 'EN' 'Message',⍪⎕DMX.(EM EN Message)
          (pos expect)←⍺
          '>'≠pos⊃⍵:⎕SIGNAL err
          tag←{⍵↓⍨0⌈¯1+¯1↑⍸'<'=⍵}pos↑⍵
          0=len←⊃'<\/\w*>|<\w*\/>'⎕S 1⊢tag:⎕SIGNAL err
          ((pos-len)↑⍵),expect,(pos-len)↓⍵
      }
      fixImbalance←{
          err←⊂↓'EM' 'EN' 'Message',⍪⎕DMX.(EM EN Message)
          (pos expect)←⍺
          pos≠≢⍵:⎕SIGNAL err
          ⍵,expect
      }
      fixOrphan←{
          err←⊂↓'EM' 'EN' 'Message',⍪⎕DMX.(EM EN Message)
          tag←{⍵↓⍨0⌈¯1+¯1↑⍸'<'=⍵}pos↑⍵
          0=len←⊃'<\/\w*>|<\w*\/>'⎕S 1⊢tag:⎕SIGNAL err
          ((⍺-len)↑⍵),⍺↓⍵
      }
     
      html~←⎕UCS 11 ⍝ remove vertical tab characters
     
      closes←⍸'>'=html
      noclose←'<',¨'area ' 'base ' 'basefont ' 'br ' 'br>' 'col ' 'frame ' 'hr ' 'hr>' 'img ' 'input ' 'isindex ' 'link ' 'meta ' 'param ' ⍝ elements with no closing tag
      inds←closes[⍸∨⌿<\(⍸⊃∨/(noclose(⍷lco)¨⊂html))∘.<closes]
      html[inds[⍸'/'≠html[inds-1]]]←⊂'/>'
      html←∊html
      pos←0
     Try:
      lastpos←pos
      :Trap 11
          r←(⎕XML⍠('Markup' 'Preserve')('UnknownEntity' 'Preserve'))html
      :Else
          msg←⎕DMX.Message
          pos←msg parsePos≢html
          :If pos=lastpos ⍝ error in same position?
              ∘∘∘
          :ElseIf ~0∊⍴scriptInsert←pos inScript html
              html←scriptInsert fixScript html
              →Try
          :ElseIf msg beginsWith'Invalid entity reference'
              html←pos fixAmpersand html
              →Try
          :ElseIf msg beginsWith'''='' expected'
              html←pos fixAttribute html
              →Try
          :ElseIf msg beginsWith'Quote expected at start'
              html←pos quoteAttr html
              →Try
          :ElseIf msg beginsWith'Invalid ''--'' in comment'
              html←pos fixComment html
              →Try
          :ElseIf (4↓msg)beginsWith'not allowed in attribute'
              char←2⊃msg ⍝ the offending character
              html←(pos char)fixAttributeCharacter html
              →Try
          :ElseIf msg beginsWith'Invalid tag name'
              html←pos fixBadTag html
              →Try
          :ElseIf msg endsWith'none expected'
              html←pos fixOrphan html
              →Try
          :ElseIf msg beginsWith'Tag mismatch'
              expect←⊃⊢/' '(≠⊆⊢)msg ⍝ expected tag
              html←(pos expect)fixMismatch html
              →Try
          :ElseIf msg beginsWith'Tag imbalance'
              expect←⊃⊢/' '(≠⊆⊢)msg ⍝ expected tag
              html←(pos expect)fixImbalance html
              →Try
          :Else
              ∘∘∘ ⍝ unhandled exception
          :EndIf
      :EndTrap
    ∇

    ∇ r←xhtml Xfind specs;level;element;content;attr;value;to;max;parseLevel;lc;lco;contains;attrHits;attrMask;valueHits
     ⍝ specs is delimited (first char denotes delimiter) list of '/level/element/content/attribute/value'
     ⍝ level[+|-[n]] : 3 matches level 3, 3+ matches 3 and higher, 3- matches 3 and lower, 3-5 matches 3 thru 5
     ⍝ element: space delimited list of element names
     ⍝ content: uses case insensitive
     ⍝ attribute: attribute name (if value is not present, use only the existence of attribute)
     ⍝ value: attribute value: uses case insensitive (if attribute is not present, search all attribute values)
      r←(≢xhtml)⍴1
      →exit⍴⍨0∊⍴specs←1↓¨specs⊂⍨specs=⊃specs
      (level element content attr value)←5↑specs,5⍴⊂''
      lc←0∘(819⌶) ⋄ lco←{(lc ⍺)⍺⍺ lc ⍵}
      contains←{∨/⍺⍷lco ⍵}
      :If ~0∊⍴level
          max←⌈/xhtml[;1]
          'Bad level specification'⎕SIGNAL 11/⍨~∧/level∊⎕D,' ,-+'
          parseLevel←{
              to←{⍺←⍵ ⋄ ⍺,⍺+(¯1*⍺>⍵)×⍳|⍺-⍵}
              p←{0∊⍴⍵:⍺ m max ⋄ ⍺ to ⍵}
              m←{0∊⍴⍵:⍺ to 0 ⋄ ⍺ to ⍵}
              v←∊((⊂' p ')@('+'∘=))⍵
              v←∊((⊂' m ')@('-'∘=))v
              v←(' '@(','∘=))v
              v,←('mp'∊⍨⊢/v~' ')/'⍬'
              ⍎v
          }
          r∧←r\(r/xhtml[;1])∊max parseLevel level
          →exit⍴⍨~∨/r
      :EndIf
      :If ~0∊⍴element
          r∧←r\(r/xhtml[;2])∊lco element⊆⍨element≠' '
          →exit⍴⍨~∨/r
      :EndIf
      :If ~0∊⍴content
          r∧←r\content∘contains¨r/xhtml[;3]
          →exit⍴⍨~∨/r
      :EndIf
      attrHits←⍬
      :If ~0∊⍴attr
          attrHits←(attr⊆⍨attr≠' ')∘{⍵[;1]∊⍺}¨r/xhtml[;4]
          r∧←r\attrMask←∨/¨attrHits
          →exit⍴⍨~∨/r
      :EndIf
      :If ~0∊⍴value
          valueHits←∨/¨value∘{∨/¨(⊂⍺)⍷lco¨⍵[;2]}¨r/xhtml[;4]
          :If ~0∊⍴attrHits
              valueHits∧←attrMask/attrHits
          :EndIf
          r∧←r\∨/¨valueHits
      :EndIf
     
     exit:
    ∇

      family←{ ⍝ ⎕XML-mat ((up dn)Family) mask
          steps←-|⍺⍺                         ⍝ steps up and down to look
          tree←↑1↑¨⍨-1+⊣/⍺                   ⍝ Boolean drawing of structure
          ids←↓(+⍀tree)×⌽∨\⌽tree             ⍝ unique level-length ids
          pad←0↑⍨⌊/steps                     ⍝ padding to keep top levels unique
          ⍸¨↓⊃∘.≡/⍵ 1/¨steps↓¨¨⊂ids(pad,~)¨0 ⍝ pad, trim, mask, compare, where
      }

      Xsel←{
      ⍝ ⍺ - xml matrix
      ⍝ ⍵ - Boolean of selected nodes (result from Xfind)
      ⍝ ← - nodes+descendents
          {⍵⌿⍨∧\1,1↓⍵[;1]>⊃⍵[;1]}¨((1@(⍸⍵))(≢⍺)⍴0)⊂[1]⍺
      }

    ∇ xml←repl(xml Xrepl)elements;mask;n;i;inds;rep;ind;elms
    ⍝ xml      - xml matrix or string
    ⍝ repl     - new xml (or string(s)) for elements
    ⍝ elements - boolean marking the elements in xml (or string for Xfind)
    ⍝ ←  - updated xml matrix
      xml←⎕XML⍣(''=⍥⎕DR xml)⊢xml
      elms←xml Xsel elements←xml Xfind⍣(~2|⎕DR elements)⊢elements
      repl←⎕XML⍣(''=⍥⎕DR repl)⊢repl
      repl←⊂⍣(2=≢⍴repl)⊢repl
      ⎕SIGNAL 5/⍨(≢repl)(~∊)1,n←≢inds←⍸elements
      repl←n/⍣(1=≢repl)⊢repl
      mask←(≢xml)⍴1
      mask[∊inds+∘⍳¨¯1+≢¨elms]←0
      repl←repl{⍉(⍵-⍥⊃⍺)∘+@1⊢⍉⍺}¨xml[inds;1] 
      xml←↑⊃,/↓¨mask/repl@inds⊢↓xml
    ∇

:EndNamespace
