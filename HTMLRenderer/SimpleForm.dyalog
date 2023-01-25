 r←SimpleForm args;evt;html;req;resp;who;dob
 :If 0∊⍴args ⍝ setup
     html←'<title>Simple Form Example</title>'
     html,←'<form method="post" action="SimpleForm"><table>'
     html,←'<tr><td>First: </td><td><input name="first"/></td></tr>'
     html,←'<tr><td>Last: </td><td><input name="last"/></td></tr>'
     html,←'<tr><td>DOB: </td><td><input name="dob" type="date"/></td></tr>'
     html,←'<tr><td colspan="2"><button type="submit">Click Me</button></td></tr>'
     html,←'</table></form>'
     evt←'Event' 'HTTPRequest' 'SimpleForm'
     'hr'⎕WC'HTMLRenderer'('HTML'html)('Coord' 'ScaledPixel')('Size' 400 400)evt
     :Return
 :Else      ⍝ handle the callback
     req←⎕NEW #.HttpUtils.HttpRequest args   ⍝ create a request from the callback data
     resp←⎕NEW #.HttpUtils.HttpResponse args ⍝ create a response based on the request
     ∘∘∘
     who←req.(FormData∘Get)¨'first' 'last'   ⍝ req.FormData has the data from the form
     dob←{0::⍬ ⋄ #.DateToIDN ⍵}⊃(//)⎕VFI(' '@('-'∘=))req.(FormData Get'dob')
     who←∊' ',¨who
     resp.Content←'<h3>Welcome',who,'!</h3>' ⍝ set the content for the response page
     :If 0∊⍴dob ⋄ resp.Content,←'Invalid date of birth'
     :Else ⋄ resp.Content,←'You''ve been alive for ',(⍕(#.DateToIDN 3↑⎕TS)-dob),' days!'
     :EndIf
     r←resp.ToHtmlRenderer                   ⍝ and send it back
 :EndIf
⍝)(!SimpleForm!brian!2017 9 1 14 11 53 0!0
