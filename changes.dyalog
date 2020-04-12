 changes←{
 ⍝ return changes made in most recent ⍺ commits to GitHub repository ⍵
 ⍝ ⍺ - number of latest commits to list (default 1)
 ⍝ ⍵ - {credentials@}repository or owner/repository, (default owner is Dyalog)
 ⍝ N.B. - requires HttpCommand
     0=⎕NC'#.HttpCommand':('Please',(⎕UCS 13),'      ]load HttpCommand')⎕SIGNAL 6
     creds←{~∨/m←'@'=⍵:'' ⋄ ⌽{⍵/⍨∧\⍵≠'/'}(⌽⍵)/⍨∨\⌽m}⍵
     inject←{i←⎕IO+⍸<\'//'⍷⍵ ⋄ (i↑⍵),⍺,i↓⍵}
     url←(creds ⎕R'')⍵
     get←{⎕JSON(HttpCommand.Get ⍵).Data}
     changed←{(get ⍵).(commit.committer.(name date),(⊂↑files.(status filename)),⊂↑(⎕UCS 10)(≠⊆⊢)commit.message)}
     ⍺←1 ⍝ default to last commit
     repo←('Dyalog/'/⍨~'/'∊⍵),url
     commits←⍺{⍵↑⍨⍺⌊≢⍵}↑get'https://',creds,'api.github.com/repos/',repo,'/commits'
     2=(⊃commits).⎕NC'message':(⊃commits).message
     urls←creds∘inject¨commits.url
     ↑changed¨urls
 }
