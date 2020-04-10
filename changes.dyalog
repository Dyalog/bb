 changes←{
 ⍝ return changes made in most recent ⍺ commits to GitHub repository ⍵
 ⍝ ⍺ - number of latest commits to list (default 1)
 ⍝ ⍵ - repository or owner/repository, (default owner is Dyalog)
 ⍝ N.B. - requires HttpCommand

     0=⎕NC'#.HttpCommand':('Please',(⎕UCS 13),'      ]load HttpCommand')⎕SIGNAL 6
     get←{⎕JSON(HttpCommand.Get ⍵).Data}
     changed←{(get ⍵).(commit.committer.(name date),⊂↑files.(status filename))}
     ⍺←1 ⍝ default to last commit
     repo←('Dyalog/'/⍨~'/'∊⍵),⍵
     commits←⍺↑get'https://api.github.com/repos/',repo,'/commits'
     urls←commits.url
     ⍪changed¨urls
 }
