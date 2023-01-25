 InputDemo2;pg;frm;fs;ig;btn;fname;dob;nextBd;fav;msg
 pg←⎕NEW WC2.Page  ⍝ create a new page
 pg.Size←400 500
 frm←pg.Add _.Form ⍝ add a form
 fs←frm.Add _.Fieldset'Tell Us About You'
 ig←'ig'fs.Add _.InputGrid
 pg.Add _.Style'.ig_label'(('background-color' 'yellow')('font-family' 'arial'))
 ig.Labels←'First' 'Last' 'DOB' 'Favorite Color'
 ig.Inputs←'first' 'last' 'dob' 'color'{⍺ pg.New ⍵}¨_.(Input Input ejDatePicker ejColorPicker)
 fs.Add _.br
 btn←fs.Add _.Button'Submit'
 btn.On'click' 'InputDemoCallback' ⍝ assign the callback to this function
 'output' 'style="text-align:center;"'pg.Add _.div
 pg.Run
⍝)(!InputDemo2!brian!2017 9 8 14 56 1 0!0
