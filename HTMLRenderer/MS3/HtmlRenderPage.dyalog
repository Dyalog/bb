:Class HtmlRenderPage

    (⎕IO ⎕ML ⎕WX)←1 1 3

    :field public _Renderer←''
    :field public _Html←''
    :field public _Url←''
    :field public _Request
    :field public _CallbackFn←''

    begins←{⍺≡(⍴⍺)↑⍵}

    ∇ make
      :Access public
      :Implements constructor
    ∇

    ∇ make1 arg
        ⍝ args are: [1] HTML content [2] URL
      :Access public
      :Implements constructor
      arg←,⊆arg
      (content _Url)←2↑arg,(⍴arg)↓'' ''
      :If ~0∊⍴content ⋄ Add content ⋄ :EndIf
    ∇

    ∇ {r}←Wait
      :Access public
      Render
      :If ~0∊⍴_Url ⋄ _Renderer.URL←_Url ⋄ :EndIf
      _Renderer.Visible←1
      r←_Renderer.Wait
    ∇

    ∇ Render;x
      :Access public
      _Renderer←{6::⎕NEW⊂'HTMLRenderer' ⋄ _Renderer}''
      _Renderer.onHTTPRequest←'__CallbackFn'
      _Renderer.InterceptedURLs←1 2⍴'*dyalog_host*' 1
      :If 9=#.⎕NC'HtmlElement'
          x←⎕NEW #.HtmlElement
          #.HtmlElement._interactive←0
          {}x.Add _Html
          #.HtmlElement._interactive←_Interactive
          _Renderer.HTML←x.Render
      :Else
          _Renderer.HTML←_Html
      :EndIf
    ∇

    ∇ {r}←{args}Add content
      :Access public
      :If 0=⎕NC'args' ⋄ args←⊢ ⋄ :EndIf
      :If 9=#.⎕NC'HtmlElement'
          content←args(⎕NEW #.HtmlElement).Add content
      :EndIf
      _Html,←r←content
    ∇

    ∇ r←__CallbackFn _Args
      :Access public
      :If 'ProcessRequest'≡3⊃_Args
          _Request←⎕NEW #.HtmlRender.HtmlRenderRequest _Args
          :If ''≢CallbackFn
              r←⍎'_Args ',CallbackFn,' _Request'
          :Else
              r←Callback
          :EndIf
      :Else
          ∘∘∘ ⍝ unknown action - should not happen
      :EndIf
    ∇

    ∇ r←Callback;valence
      :Access public overridable
      r←''
      :If ''≢_callback
          :If 3=⎕NC _callback
              valence←|1 2⊃⎕AT _callback
              r←⍎('args '/⍨valence=2),_callback,' _Request'/⍨valence>0
          :EndIf
      :EndIf
    ∇

    ∇ r←ScriptFollows
      :Access public
      r←2↓∊(⎕UCS 13 10)∘,¨Follows
    ∇

    ∇ r←Follows;n
      n←1++/∧\{∨/'.HtmlRenderPage.'⍷⍵}¨⍕¨⎕XSI
      r←{⍵/⍨'⍝'≠⊃¨⍵}{1↓¨⍵/⍨∧\'⍝'=⊃¨⍵}{⍵{((∨\⍵)∧⌽∨\⌽⍵)/⍺}' '≠⍵}¨(1+n⊃⎕LC)↓↓(180⌶)n⊃⎕XSI
    ∇

    ∇ r←{default}Get names
      :Access public
    ∇

    ∇ r←Close
      :Access public
      :If ''≢_Renderer
          _Renderer.Close
      :EndIf
      r←0
    ∇

:EndClass
