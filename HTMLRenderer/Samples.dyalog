:Namespace Samples


    ∇ btnIndex←SampleMsgBox;mb
      mb←⎕NEW #.MsgBox ⍝ #.MsgBox is a new class
      mb.Caption←'Are you sure?'
      mb.Style←'Query' ⍝ could also be: msg (default), info, error, warning
      mb.Text←'Do you really want <b>ludicrous</b> speed Captain?'
      mb.Btns←'You Bet!' 'No Way!' ⍝ button captions
      btnIndex←mb.Run ⍝ returns button index that was clicked
    ∇


    ∇ SampleSimpleForm;frm;ig
      frm←⎕NEW #.App 'path to MiServer' ⍝ #.SimpleForm is a new class
      ig←frm.Add #._.InputGrid
      ig.Labels←'First' 'Last' 'DOB' 'Email'
      frm.Run
    ∇
    
    ∇myCallback1

    ∇



    ∇ SampleMiSite;myApp
    ⍝ this is how one would run a MiSite using HTMLRenderer
      myApp←⎕NEW #.MiSite  ⍝ #.App is a new class
      myApp.MiServerPath←'c:/git/miserver'
      myApp.AppPath←'c:/dyalog17/SampleHTMLRendererApp'
      myApp.Run
    ⍝ could be shortened to
    ⍝ (⎕NEW #.App'c:/dyalog17/SampleMiSiteApp' 'c:/git/miserver').Run
    ∇


:EndNamespace

⍝)(!SampleMiSite!brian!2017 8 23 16 45 12 0!0
⍝)(!SampleMsgBox!brian!2017 8 23 16 45 12 0!0
⍝)(!SampleSimpleForm!brian!2017 8 23 16 45 12 0!0
⍝)(!myCallback1!brian!2017 8 23 16 45 12 0!0
