:Class Git

    fromJSON←7159⌶
    get←{w←2↑(##.HTTPCommand.eis ⍵),'' '' ⋄ 2=⍺.⎕NC (1⊃w):⍺⍎1⊃w ⋄ 2⊃w}

    ∇ r←Get args;url;hdrs;z
      :Access public shared
      (url hdrs)←2↑(##.HTTPCommand.eis args),'' ''
      z←⎕NEW ##.HTTPCommand
      z.(URL Command Headers)←url'GET'hdrs
      'Accept'z.AddHeader'application/vnd.github.v3+json'
      r←z.Run
    ∇

    ∇ r←GetSource url;t;j
      :Access public shared
      t←Get url
      :If 200=t.httpstatus
          j←fromJSON t.data
          :If 'base64'≡j get'encoding'
              :If ''≢r←j get'content'
                  :If 239 187 191≡⎕UCS 3↑r←##.HTTPCommand.B64Decode r
                      r←'UTF-8'⎕UCS ⎕UCS 3↓r
                  :EndIf
              :EndIf
          :Else
              ∘∘∘ ⍝ not base64??
          :EndIf
      :Else
          ∘∘∘ ⍝ failed HTTP request
      :EndIf
    ∇
:EndClass
