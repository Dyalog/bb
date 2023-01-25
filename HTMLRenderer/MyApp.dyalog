 r←MyApp arg;pg;frm;ig
⍝ self contained mini app using MS3 HTML
 :If 0∊⍴arg ⍝ initialize?
     :If 0≠WC2.Init'/path/to/MiServer'
         →0⊣⎕←'Unable to initialize WC2'
     :EndIf
     pg←⎕NEW WC2.App ⍝ create a page
     pg.Title←'Simple Sample Application'
     frm←pg.Add _.Form  ⍝ add a form to the page
     ig←frm.Add _.InputGrid  ⍝ add an input grid to the form
     ig.Labels←'First' 'Last' 'DOB'
     ig.Inputs←'first' 'last' 'dob'{⍺ WC2.New ⍵}¨_.(input input jqDatePicker)
     frm.Add _.br
     (frm.Add _.Button'OK').On'Click' 'MyApp'
     (frm.Add _.Button'Cancel').On'Click' 'MyApp'
     'output'pg.Add _.div
     pg.Callback←'MyApp'
     pg.Run
 :Else ⍝ callback
     ∘∘∘
 :EndIf
⍝)(!MyApp!brian!2017 8 31 17 27 19 0!0
