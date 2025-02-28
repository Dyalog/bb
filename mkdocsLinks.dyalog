 rpt←{walk}mkdocsLinks url;h;r;x;m;redir;t;queue;path;prot;refs;links;ids;page;beginsWith;this;intern;resolveURL;new;i;v;preconnect;mask;anchors;docs;anchor;missingAnchors;missingRefs;otherErrors;missingFiles;removeBase;missing;toUTF8;canonical;first;URLbase
⍝ validate links within a mkdocs documentation site
⍝ {walk} is 1 (the default) to walk down the doc tree, or 0 to just check links on the given page

 walk←{6::⍵ ⋄ walk}1
 :If 0=⎕NC'HttpCommand' ⋄ ⎕SE.SALT.Load'HttpCommand' ⋄ {}HttpCommand.Upgrade ⋄ :EndIf

 url←{∨/'localhost'⍷⍥⎕C ⍵:⍵ ⋄ '.'∊⍵:⍵ ⋄ 'https://dyalog.github.io/',⍵,'/'}url

 h←HttpCommand.New'get'url
 'Accept-Encoding'h.SetHeader'' ⍝ turn off accepting zipped files (it seems there's a bug in Conga)

 beginsWith←{⍵≡(≢⍵)↑⍺}
 resolveURL←{
 ⍝ ⍺-page URL
 ⍝ ⍵-URL to resolve
 ⍝ ←-resolved URL
     '#'=⊃⍵:⍵
     1=≢'^https?:\/\/'⎕S'&'⊢⍵:⍵ ⍝ exit if begins with http[s]://
     url←⍺,⍵
     (prot path)←url(↑{⍺ ⍵}↓)⍨2+⍸<\'://'⍷url
     prot,(≢⊃1 ⎕NPARTS'')↓∊1 ⎕NPARTS path
 }
 URLbase←{⍵{(⍵↑⍺),(⊢↑⍨⍳∘'/')⍵↓⍺,'/'}⊃2+⍸<\'://'⍷⍵}
 removeBase←{⍵↓⍨(≢⍺)×⍵ beginsWith ⍺}

 toUTF8←{0::⍵ ⋄ 'UTF-8'⎕UCS ⎕UCS ⍵⊣'UTF-8'⎕UCS'UTF-8'⎕UCS ⍵}

 :If ∨/'dyalog.github.io'⍷url
     :Repeat
         r←h.Run
         :If ~r.IsOK ⋄ ⎕←'Unable to retrieve "',url,'": ',⍕r ⋄ →0 ⋄ :EndIf
         :If ~∨/'text/html'⍷r.GetHeader'content-type' ⋄ ⎕←'"',url,'" content-type is not text/html?? ',⍕r ⋄ →0 ⋄ :EndIf
         x←xhtml.HTMLtoXHTML toUTF8 r.Data
         redir←''
         :If ∨/m←x xhtml.Xfind'/3/meta//http-equiv/refresh'
             redir←(t←x xhtml.Xsel m)xhtml.Xattr'content'
             :If 0∊⍴redir←'url='{(≢⍺)↓⍵/⍨∨\⍺⍷⍵}∊redir ⋄ ⎕←'No redirection link found?'t ⋄ →0 ⋄ :EndIf
             h.URL,←redir
             (prot path)←h.URL(↑{⍺ ⍵}↓)⍨2+⍸<\'://'⍷h.URL
             h.URL←prot,(≢⊃1 ⎕NPARTS'')↓⊃1 ⎕NPARTS path
         :EndIf
     :Until ~∨/m
 :EndIf

 h.(BaseURL URL)←h.URL''
 links←⍬
 queue←,⊂h.URL
 ⍞←'Scanning: '
 first←1
 :While ~0∊⍴queue
     h.URL←⊃queue
     r←h.Run
     ⍞←'.'
     links,←page←⎕NS''
     page.URL←(1+first)⊃h.URL r.URL ⍝ save the URL we actually retrieved
     page.Response←⍕r ⍝ save the HttpCommand response
     page.HttpStatus←r.HttpStatus
     page.IsHTML←0
     :If page.IsOK←r.IsOK
         page.Internal←page.URL beginsWith h.BaseURL
         :If (page.Internal∧walk∨first)∨walk∧first ⍝ don't walk if walk=0 or this page isn't internal
             :If page.IsHTML←∨/'text/html'⍷r.GetHeader'content-type'
                 x←xhtml.HTMLtoXHTML toUTF8 r.Data
                 canonical←x xhtml.Xsel x xhtml.Xfind'//link//rel/canonical'
                 :Select ≢canonical
                 :Case 0
                     canonical←''
                 :Case 1
                     canonical←⊃canonical xhtml.Xattr'href'
                     page.URL←∊canonical
                     :If first
                         h.BaseURL←URLbase page.URL
                     :EndIf
                 :Else
                     ∘∘∘ ⍝ more than 1 <link rel="canonical"> element???
                 :EndSelect
                 first←0
                 refs←canonical~⍨x xhtml.Xattrval'////href'
                 refs,←x xhtml.Xattrval'////src'
                 preconnect←x xhtml.Xsel x xhtml.Xfind'//link//rel/preconnect'
                 preconnect←preconnect xhtml.Xattr'href'
                 refs←(∪refs)~(,'.')('..'),⊃,/preconnect ⍝ remove preconnects
                 refs←refs[1+'^(?!https:\/\/github.com\/.*\/edit\/.*\.md)'⎕S{⍵.BlockNum}⊢refs] ⍝ remove mkdocs "edit" links
                 refs/⍨←~refs beginsWith¨⊂'data:' ⍝ remove inline image data refs
                 page.ids←x xhtml.Xattrval'////id'
                 page.refsFound←(≢refs)⍴¯1 ⍝ make refs for searching - ¯1=not searched, 0=not found, 1=found
                 this←'#'=⊃¨refs ⍝ internal refs to anchors in this page
                 (this/page.refsFound)←(1↓¨this/refs)∊(⊂''),page.ids ⍝ mark internal refs that match ids in this page
                 ((~this)/refs)←new←page.URL∘resolveURL¨(~this)/refs
                 page.refs←refs
                 queue,←∪({⍵↑⍨¯1+⍵⍳'#'}¨new)~queue,links.URL
             :EndIf
         :EndIf
     :EndIf
     queue↓⍨←1
 :EndWhile
 ⎕←'Done!'
 missingFiles←links.URL/⍨404≡¨links.HttpStatus
 otherErrors←links.URL/⍨~links.HttpStatus∊200 404
 missingAnchors←missingRefs←0 2⍴⊂''
 :For page :In links/⍨links.IsHTML ⍝ only track links in HTML files
     v←⍸page.refsFound=¯1 ⍝ mark references to check
     anchors←page.refs[v]⍳¨'#' ⍝ mark anchor position, if any, in references
     m←(≢links)≥docs←links.URL⍳(¯1+anchors)↑¨page.refs[v] ⍝ drop off anchors
     (page.refsFound[m/v])←200=links[m/docs].HttpStatus ⍝ and see if file exists
     missing←⍬
     :For i :In ⍸anchors<≢¨page.refs[v] ⍝ now check that anchors exist in the target pages
         :If links[docs[i]].IsHTML ⍝ only follow links in HTML files (e.g. not .pdf)
             :If ~(⊂anchor←anchors[i]↓i⊃page.refs[v])∊links[docs[i]].ids
                 missing,←⊂h.BaseURL removeBase i⊃page.refs[v]
             :EndIf
         :EndIf
     :EndFor
     :If ~0∊⍴missing
         missingAnchors⍪←page.URL(↑missing)
     :EndIf
     :If ∨/mask←1≢¨page.refsFound
         missingRefs←page.URL(↑h.BaseURL∘removeBase¨mask/page.refs) ⍝ report any references not found
     :EndIf
 :EndFor
 missingFiles←h.BaseURL∘removeBase¨missingFiles
 missingRefs←h.BaseURL∘removeBase¨missingRefs
 missingAnchors←h.BaseURL∘removeBase¨missingAnchors
 otherErrors←h.BaseURL∘removeBase¨otherErrors
 rpt←1 2⍴'Missing Files'(↑missingFiles)
 rpt⍪←'Missing Refs'missingRefs
 rpt⍪←'Missing Anchors'missingAnchors
 rpt⍪←'Non 200/404 Errors'(↑otherErrors)
