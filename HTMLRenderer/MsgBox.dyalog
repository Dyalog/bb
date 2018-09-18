:Class MsgBox
⍝ Description::
⍝ MsgBox provides cross-platform functionality similar to the Windows MsgBox control
⍝
⍝ Overview::
⍝ To use MsgBox:
⍝   1) Create an instance of MsgBox using ⎕NEW
⍝   2) Set any parameters that you didn't supply when creating the instance (Optional)
⍝   3) Use the Run method to execute the MsgBox
⍝
⍝        mb←⎕NEW MsgBox                               ⍝ create an instance
⍝        mb.Caption←'Are you sure?'                   ⍝ set some properties
⍝        mb.Style←'query'
⍝        mb.Text←'Engage ludricrous speed Captain?'
⍝        btnClicked←mb.Run                            ⍝ run the MsgBox
⍝
⍝ Constructor::
⍝        mb←⎕NEW MsgBox [properties]
⍝
⍝ Constructor Arguments::
⍝ All of the constructor arguments are also exposed as Public Fields
⍝ Similar to ⎕WC-based controls, the constructor arguments can be positional and/or name/value pairs.
⍝
⍝ When using positional arguments, they are the same as the first four ⎕WC-based MsgBox properties:
⍝       [Caption [Text [Style [Btns [Props]]]]]
⍝
⍝   Caption  - the caption to appear at the top of the MsgBox window
⍝
⍝   Text     - the text to appear in the MsgBox window.
⍝              Note: you can use any HTML in the text.
⍝
⍝   Style    - Case-insensitive generic style for the MsgBox
⍝              One of: 'Msg' (the default), 'Info', 'Warn', 'Error', or 'Query'
⍝
⍝   Btns     - A character scalar, vector, or vector of vectors of the captions to appear on the button(s)
⍝              Unlike the ⎕WC-based MsgBox, you can have any number of buttons.
⍝              Note: you can use any HTML in the button captions.
⍝              If you do not specify the Btns property, it will have default values based on the Style property
⍝
⍝              Style             Btns
⍝              'Msg' or 'Info'   'OK'
⍝              'Warn' or 'Error' 'OK' 'Cancel'
⍝              'Query'           'Yes' 'No'
⍝
⍝   Props    - This parameter allows you to specify any additional properties for the underlying HTMLRenderer object
⍝              MsgBox has default values for Size (400 800) and Coord ('ScaledPixel')
⍝              Additional properties include:
⍝                Posn Size Coord Border Visible Sizeable Moveable SysMenu
⍝                MaxButton MinButton Data Attach Translate KeepOnClose AsChild
⍝              Props must be properly formatted to pass as a constructor argument for HTMLRenderer
⍝              No additional processing or validation is performed
⍝
⍝ Additional Public Fields::
⍝   Coord - The coordinate system to use for HTMLRenderer (default 'ScaledPixel')
⍝   Size  - The size for the HTMLRenderer window (default (400 800)).
⍝           If you change Coord to 'Prop', you should probably change Size as well :)
⍝
⍝ Public Instance Methods::
⍝   btnClicked←Run   - display the MsgBox and return the index of the button that was clicked
⍝                      If the HTMLRenderer is closed without clicking a button, ¯1 is returned
⍝
⍝ Public Shared Methods::
⍝   html←tag Enc content - enclose content in an HTML tag
⍝   Example: 'div class="foo" Enc 'Hello!'  results in>>  <div class="foo">Hello!</div>
⍝
⍝ Examples::
⍝
⍝   Using only positional parameters:
⍝      mb←⎕NEW MsgBox ('Oops!' '<b>Oh no!</b><br/>Something went wrong' 'Error')
⍝      btn←mb.Run
⍝
⍝   Using positional and named parameters:
⍝      mb←⎕NEW MsgBox ('Oops!' ('Btns' ('Ignore it' 'Give up')) ('Text' 'Something went wrong'))
⍝      btn←mb.Run
⍝
⍝   Do it in a single line:
⍝      btn←(⎕NEW MsgBox (('Style' 'Error')('Text' '<b>Oh no!</b><br/>Something went wrong')('Caption' 'Oops!'))).Run
⍝
⍝   Adjust the size:
⍝      mb←⎕NEW MsgBox ('Oops!' ('Btns' ('Ignore it' 'Give up')) ('Text' 'Something went wrong'))
⍝      mb.Size←200 450
⍝      btn←mb.Run

    ∇ r←Version
      :Access public shared
      r←'MsgBox' '1.0.0' '2017-08-28'
    ∇

    :field public Caption←''
    :field public Style←'msg'  ⍝ valid styles are msg, info, warn, error, query
    :field public Text←''
    :field public Btns←''
    :field public Coord←'ScaledPixel'
    :field public Props←⍬
    :field public Size←400 800

    ∇ make
      :Access public
      :Implements constructor
    ∇

    ∇ make1 args;i;positional;ind;d
      :Access public
      :Implements constructor
      args←,⊆args
      positional←1
      :For i :In ⍳≢args ⋄ d←i⊃args
          :If positional
              :If i<4
                  :If positional←1=≡d ⋄ (Caption Text Style)←(args[i]@i)Caption Text Style
                  :EndIf
              :ElseIf i=4 ⋄ Btns←{(⊂⍣(2-≡⍵))⍵}{((,⊂'Btns')≡1↑⍵)↓⍵}d
              :ElseIf i=5 ⋄ Props←d
              :Else ⋄ 'Too many arguments'⎕SIGNAL 11
              :EndIf
          :EndIf
          :If ~positional
              :Select ind←⊃'Caption' 'Text' 'Style' 'Btns' 'Props'⍳1↑d
              :Case 4 ⋄ Btns←{2<d←≡⍵:(⊃⍣(d-2))⍵ ⋄ (⊂⍣(2-d))⍵}{((,⊂'Btns')≡1↑⍵)↓⍵}d
              :CaseList 1 2 3 ⋄ (Caption Text Style)←(d[2]@ind)Caption Text Style
              :Case 5 ⋄ Props←1↓d
              :Else ⋄ ('Invalid argument: ',,⍕d)⎕SIGNAL 11
              :EndSelect
          :EndIf
      :EndFor
    ∇

    ∇ r←Run;ind;html;head;btns;body;msgStyle;renderer;tab
      :Access public
      Clicked←¯1 ⍝ default if form is closed without clicking a button
      :If 5<ind←'msg' 'info' 'warn' 'error' 'query'⍳msgStyle←(819⌶)⊆Style
          ('Invalid style: ',,⍕Style)⎕SIGNAL 11
      :EndIf
      :If 0∊⍴Btns
          Btns←(⌈0.5×ind)⊃(,⊆'OK')('OK' 'Cancel')('Yes' 'No')
      :EndIf
      head←'title'Enc Caption
      head,←'style'Enc CSS
      head,←'script'Enc JavaScript
      head←'head'Enc head
      tab←''
      :If ind≠1 ⍝ everything but 'msg' gets a glyph
          tab,←('td onclick="resize()" class="glyph ',(⊃msgStyle),'"')Enc ind⊃' i!!?'
      :EndIf
      tab←'tr'Enc tab,'td class="msgText"'Enc Text
      tab←'table class="content"'Enc tab,'tr'Enc((ind≠1)/'td'Enc''),'td class="buttons"'Enc'form action=""'Enc∊(⍳≢Btns){('button name="btn" value="',(⍕⍺),'"')Enc ⍵}¨Btns
      body←⊃Enc/'div id="outer" class="outer"' 'div class="inner"'tab
      renderer←⎕NEW'HTMLRenderer'((16=⊃APLVersion)↓('InterceptedURLS'(1 2⍴'*' 1))('Size'Size)('Coord'Coord),Props)
      renderer.HTML←head,body
      renderer.onHTTPRequest←'mbCallback'
      renderer.Wait
      r←Clicked
    ∇

    ∇ mbCallback args
    ⍝ MsgBox callback function
    ⍝ when a button is clicked, the callback URI will have btn= following by the button index
      Clicked←⊃Clicked,⍨⊃(//)⎕VFI{⍵↓⍨3+⍸'btn='⍷⍵}8⊃args
      ⎕NQ(1⊃args)'Close' ⍝ queue "Close" event
    ∇

    ∇ r←JavaScript
      r←ScriptFollows
    ⍝ function resize(){
    ⍝   var x = document.getElementById("outer");
    ⍝   alert("h: " + x.offsetHeight + " w: " + x.offsetWidth);
    ⍝   window.resizeTo((x.offsetWidth + 50),(x.offsetHeight + 50));
    ⍝ }
     
    ∇

    ∇ r←CSS
    ⍝ this is the CSS for MsgBox
    ⍝ modify it to suit your
     
      r←ScriptFollows
⍝ .info,.query{
⍝   color:blue;
⍝   border-color:blue;
⍝   }
⍝ .error{
⍝   color:red;
⍝   border-color:red;
⍝   }
⍝ .warn{
⍝   color:yellow;
⍝   border-color:yellow;
⍝   }
⍝ .outer{
⍝   position:absolute;
⍝   display:table;
⍝   width:90%;
⍝   height:90%;
⍝   left:5%;
⍝   top:5%;
⍝   }
⍝ .inner{
⍝   display:table-cell;
⍝   vertical-align:middle;
⍝   text-align:center;
⍝   }
⍝ .content{
⍝   display:inline-block;
⍝   }
⍝ .glyph{
⍝   font-size:3em;
⍝   font-weight:800;
⍝   float:left;
⍝   border:2px solid;
⍝   text-align:center;
⍝   width:40px;
⍝   margin-right:20px;
⍝   border-radius:10px;
⍝   }
⍝ td{
⍝   text-align: middle;
⍝   }
⍝ .msgText{
⍝   font-family: arial;
⍝   font-size:1.5em;
⍝   }
⍝ button{
⍝   margin:20px 5px;
⍝   font-size:1.3em;
⍝   border-radius:5px;
⍝   }
⍝ form{
⍝   text-align:right;
⍝   }
    ∇

    ∇ r←tag Enc content
      :Access public shared
    ⍝ Enclose content in an HTML tag (optionally with attributes)
    ⍝ 'div class="foo" enc 'Hello!'  >>  <div class="foo">Hello!</div>
      r←tag{'<',⍺,'>',⍵,'</',(⍺↑⍨¯1+⍺⍳' '),'>'}content ⍝ enclose an HTML element
    ∇

    dtlb←{⍵{((∨\⍵)∧⌽∨\⌽⍵)/⍺}' '≠⍵}           ⍝ delete leading and trailing blanks

    ∇ r←ScriptFollows;lines;pgm;from
     ⍝ Treat following commented lines in caller as a script, lines beginning with ⍝⍝ are stripped out
      :If 0∊⍴lines←(from←⎕IO⊃⎕RSI).⎕NR pgm←2⊃⎕SI
          lines←↓from.(180⌶)pgm
      :EndIf
      r←∊{⍵/⍨'⍝'≠⊃¨⍵}{1↓¨⍵/⍨∧\'⍝'=⊃¨⍵}dtlb¨(1+2⊃⎕LC)↓lines
    ∇

    ∇ r←APLVersion
      :Access public shared
      r←2↑{⊃(//)⎕VFI ⍵{⍵\⍵/⍺}⍵∊⎕D}2⊃#.⎕WG'APLVersion'
    ∇

    :Section Documentation Utilities
    ⍝ these are generic utilities used for documentation

    ∇ docn←ExtractDocumentationSections what;⎕IO;box;CR;sections;eis;matches
    ⍝ internal utility function
      ⎕IO←1
      eis←{(,∘⊂∘,⍣(1=≡,⍵))⍵}
      CR←⎕UCS 13
      box←{{⍵{⎕AV[(1,⍵,1)/223 226 222],CR,⎕AV[231],⍺,⎕AV[231],CR,⎕AV[(1,⍵,1)/224 226 221]}⍴⍵}(⍵~CR),' '}
      docn←1↓⎕SRC ⎕THIS
      docn←1↓¨docn/⍨∧\'⍝'=⊃¨docn ⍝ keep all contiguous comments
      docn←docn/⍨'⍝'≠⊃¨docn     ⍝ remove any lines beginning with ⍝⍝
      sections←{∨/'::'⍷⍵}¨docn
      :If ~0∊⍴what
          matches←∨⌿∨/¨(eis(819⌶what))∘.⍷(819⌶)sections/docn
          (sections docn)←((+\sections)∊matches/⍳≢matches)∘/¨sections docn
      :EndIf
      (sections/docn)←box¨sections/docn
      docn←∊docn,¨CR
    ∇

    ∇ r←Documentation
    ⍝ return full documentation
      :Access public shared
      r←ExtractDocumentationSections''
    ∇

    ∇ r←Describe
    ⍝ return description only
      :Access public shared
      r←ExtractDocumentationSections'Description::'
    ∇

    ∇ r←ShowDoc what
    ⍝ return documentation sections that contain what in their title
    ⍝ what can be a character scalar, vector, or vector of vectors
      :Access public shared
      r←ExtractDocumentationSections what
    ∇

    :EndSection

:EndClass
