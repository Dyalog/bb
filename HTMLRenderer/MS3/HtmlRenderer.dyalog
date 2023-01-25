:Namespace HtmlRenderer

    (⎕IO ⎕ML ⎕WX)←1 1 3

    ∇ Init root
      :Access public
      :Implements constructor
     
      MSRoot←⊃1 ⎕NPARTS ⎕WSID
      #.Boot.AppRoot←MSRoot #.Boot.makeSitePath root
      #.Boot.ms←⎕NS''
      #.Boot.(ms.Config←ConfigureServer AppRoot)
      #.Boot.(Configure ms)
    ∇

:EndNamespace
