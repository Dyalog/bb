 r←WC2Start site;appRoot;dyalog;FileSep;isWin;sampleMiSite;APLVersion
⍝ Start a MiSite using HTMLRenderer
⍝ site is either:
⍝   - a character vector containing the path of the MiSite to run
⍝   - a 2 element vector of character vectors containing [1] the path of the MiSite and [2] the path to MiServer
⍝ loadfirst is a Boolean indicating whether to load all of the necessary classes in the Root namespace (#)
⍝           this is useful when developing MiSites in that you can edit MiPages in the Root

 APLVersion←#.⎕WG'APLVersion'
 :If 16>⊃(//)⎕VFI{⍵/⍨∧\'.'≠⍵}2⊃APLVersion
     r←'*** HTMLRenderer is available in Dyalog version 16 and later'
     →0
 :EndIf

 :If 1<≡site ⋄ site MSRoot←2↑site ⋄ :EndIf

 :If 0=⎕NC'⎕SE.SALT' ⍝ Do we have SALT?
     #.SALT.Boot
    ⍝ Set up a trap for runtime errors
     :If ' '∧.=2 ⎕NQ'.' 'GetEnvironment' 'RIDE_INIT'
         ⎕TRAP←(0 'E' '⍎#.RuntimeError ⎕DMX')
     :EndIf
 :EndIf

 FileSep←'/\'[1+isWin←'Win'≡3↑1⊃APLVersion]

 :If 0=⎕NC'MSRoot' ⋄ MSRoot←⊃1 ⎕NPARTS ⎕WSID ⋄ :EndIf

 MSRoot←1 ⎕NPARTS MSRoot,'/'

 :Trap 912 ⍝ 912 is signalled by DrA in the event of a server failure
     ⎕SE.SALT.Load MSRoot,'Core/Boot'
     ⎕SE.SALT.Load MSRoot,'Utils/Files'
     appRoot←MSRoot #.Boot.makeSitePath site
     :If #.Files.DirExists appRoot
         MSRoot Boot.HtmlRun appRoot
         r←'HtmlApp started'
         :If ('R'=1⍴4⊃APLVersion)∨~0∊⍴2 ⎕NQ'.' 'GetEnvironment' 'runtime'
             :Repeat  ⍝ if runtime, do not return to immediate execution
                 {}⎕DL 10
             :Until ¯1=Boot.ms.TID
         :EndIf
     :Else
         r←'HtmlApp NOT started - "',site,'" not found'
     :EndIf
 :Else
     ⎕OFF
 :EndTrap
