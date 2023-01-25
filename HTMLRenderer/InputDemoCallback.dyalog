 r←InputDemoCallback req;fname;fav;dob;nextBd;msg
 ⍝ at this point we have all the form data in the request object
 fname←req.Get'first'
 fav←req.Get'color'
 dob←¯1⌽#.Dates.ParseDate req.Get'dob'
 nextBd←1 #.Dates.DateFormat{⍵,⍨⎕TS[1]+(10⊥⍵)<10⊥⎕TS[2 3]}dob[2 3]
 msg←'<br>',fname,', on ',nextBd,' we''ll wish you a'
 msg,←'<h2 style="color:',fav,';">Happy Birthday!</h2>'
 r←'#output'#.JQ.Replace msg
⍝)(!InputDemoCallback!brian!2017 9 8 14 44 27 0!0
