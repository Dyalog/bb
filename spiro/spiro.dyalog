:Namespace spiro                                    
    (⎕IO ⎕ML ⎕WX)←1 1 3

    ∇ points←spiro Rrp;degrees;turns;theta
      ⍝ simple Spirograph
      ⍝ inspired by:
      ⍝ http://www.personal.psu.edu/dpl14/java/parametricequations/spirograph/
      ⍝ Rrp is a 3 element vector of:
      ⍝ R is the radius of the stationary circle
      ⍝ r is the radiun of the moving circle (negative means the moving circle is inside the stationary circle)
      ⍝ p is the length of the "drawing stick"
      degrees←180 ⍝ "granularity"
      turns←|Rrp[2]÷∨/2↑Rrp ⍝ number of "turns" the moving circle needs to make to complete the spirograph
      theta←degrees{⍺÷⍨0,⍳⌊⍺×○2×⍵}turns ⍝ compute the
      theta,←⊃theta
      points←theta yx Rrp ⍝ do it
    ∇

    ∇ animate;Rrp;size;origin;keypress;xlate;animate;draw;degrees;turns;theta;points;path;lcc;count;x;f;timer
      ⍝ simple Spirograph
      ⍝ inspired by:
      ⍝ http://www.personal.psu.edu/dpl14/java/parametricequations/spirograph/
      Rrp←99 33 50
      ⍝ R is the radius of the stationary circle
      ⍝ r is the radiun of the moving circle (negative means the moving circle is inside the stationary circle)
      ⍝ p is the length of the "drawing stick"
      size←2⍴600 ⍝ drawing area size
      origin←⌊0.5×size
      f←⎕NEW'Form'(('Coord' 'Pixel')('Size'(size+30 0))('Caption' 'APL Spirograph')('AutoConf' 0)('Sizeable' 0))
      f.edit←{('Posn'(##.size[1],⍺))('Size'(20 40))('FieldType' 'Numeric')('Value'⍵)}
      f.label←{('Posn'(##.size[1],⍺))('Size'(20 40))('Caption'(⍵,': '))('Justify' 'right')}
      f.(R←⎕NEW'Edit'(75 edit 99))
      f.(r←⎕NEW'Edit'(210 edit 33))
      f.(p←⎕NEW'Edit'(340 edit 50))
      f.(l1←⎕NEW'Label'(30 label'Fixed'))
      f.(l2←⎕NEW'Label'(165 label'Moving'))
      f.(l3←⎕NEW'Label'(300 label'Stick'))
      f.(cb←⎕NEW'Button'(('Posn'(##.size[1],400))('Caption' 'Animate?')('Style' 'check')('State' 0)))
      f.(b←⎕NEW'Button'(('Posn'(##.size[1],475))('Caption' 'Draw')('Style' 'push')))
      f.(pts←⎕NEW'Poly'(,⊂'Points'(0 2⍴0)))
      f.(R r p).onChange←1
      f.(CR←⎕NEW'Circle'(('Points'(0 0))('Radius' 0)))
      f.(Cr←⎕NEW'Circle'(('Points'(0 0))('Radius' 0)))
      f.(Lp←⎕NEW'Poly'(,⊂'Points'(2 2⍴0)))
      f.(timer←⎕NEW'Timer'(('Interval' 1)('Active' 0)))
      f.timer.onTimer←'animate'
      f.onKeyPress←'keypress'
      f.b.onSelect←'draw'
      ⍝ we calculate y,x pairs because Dyalog's GUI uses coordinates in that order (as opposed to x,y)
      keypress←{
          27=4⊃⍵:→ ⍝ esc - exit
          32=4⊃⍵:0⊣timer.Active←~timer.Active ⍝ space - draw
          122=4⊃⍵:0⊣animate ⍬ ⍝ z - single step
          0}
      xlate←{(+/2↑⍺)×1 2○⍵}
      animate←{
          len←5
          last←⊃¯1↑inds←(⍴theta)⌊count,count+⍳len-1
          count≥⍴theta:0⊣f.timer.Active←0⊣f.pts.Points⍪←points[inds,1;]
          f.Cr.Points←last⊃path
          f.Lp.Points←2 2⍴(last⊃path),points[last;]
          f.pts.Points⍪←points[inds;]
          count+←len
          0}
      draw←{
          count←1
          1=f.cb.State:0⊣f.pts.Points←0 2⍴0⊣f.timer.Active←1
          f.timer.Active←0
          f.pts.Points←points
          0}
     Calc:
      degrees←180 ⍝ "granularity"
      turns←|Rrp[2]÷∨/2↑Rrp ⍝ number of "turns" the moving circle needs to make to complete the spirograph
      theta←degrees{⍺÷⍨0,⍳⌊⍺×○2×⍵}turns
      theta,←⊃theta
      points←(0.5×size)+[2]theta yx Rrp ⍝ do it
      path←origin∘+¨Rrp∘xlate¨theta ⍝ path of the mobile circle
      ⍝ pts.(FillCol FStyle)←(0 0 255)0
      lcc←origin+0,+/2↑Rrp
      f.CR.(Points Radius)←origin(1⊃Rrp)
      f.Cr.(Points Radius)←lcc(2⊃Rrp)
      f.Lp.Points←2 2⍴lcc,lcc+0,3⊃Rrp
      count←1
     dq:→0⍴⍨0∊⍴x←⎕DQ'f' ⍝ display it
      Rrp[f.(R r p)⍳⊃x]←(⊃x).Value
      f.pts.Points←0 2⍴0
      →Calc
    ∇

    ∇ show points;size;offset;f;min
      ⍝ simple Spirograph
      ⍝ inspired by:
      ⍝ http://www.personal.psu.edu/dpl14/java/parametricequations/spirograph/
      min←⌊⌿points
      size←⌈(⌈⌿points)-min
      offset←0-min
      f←⎕NEW'Form'(('Coord' 'Pixel')('Size'size)('Caption' 'APL Spirograph')('AutoConf' 0)('Sizeable' 0))
      f.(pts←⎕NEW'Poly'(,⊂'Points'(0 2⍴0)))
      f.pts.Points←offset+[2]points
      f.(onKeyPress onClick)←1
      {}⎕DQ'f' ⍝ display it
    ∇

    ∇ r←{type}html points;enc;min;size;script
  ⍝ return the HTML to draw a spirograph
  ⍝ points is the YX points returned by the spiro function
  ⍝ type - 0=svg, 1=HTML5 canvas
      points←⌽points  ⍝ HTML does XY, Dyalog GUI does YX
      points←points-[2]min←⌊⌿points
      size←(⌈⌿-⌊⌿)points
      enc←{'<',⍺,'>',(∊⍵),'</',(⍺⍴⍨¯1+⍺⍳' '),'>'}           ⍝ enclose an HTML element
      :If {6::⍵ ⋄ type}0
          size+←20
          script←'var pts = [',(1↓∊',',¨{{'[',⍺,',',⍵,']'}/⍕¨⍵}¨↓points+10),'];'
          script,←ScriptFollows
⍝ var c = document.getElementById("myCanvas");
⍝ var ctx = c.getContext("2d");
⍝ ctx.strokeStyle = "red";
⍝ ctx.beginPath();
⍝ ctx.moveTo(pts[0][0],pts[0][1]);
⍝ var pt;
⍝ for (pt = 1; pt<pts.length; pt++){ctx.lineTo(pts[pt][0],pts[pt][1]);}
⍝ ctx.stroke();
          r←('canvas id="myCanvas" width="',(⍕size[2]),'" height="',(⍕size[1]),'"')enc'Your browser does not support the HTML5 canvas tag.'
          r,←'script' enc script
      :Else
          size←20+⌈size
          r←'<polygon style="stroke:red;stroke-width:1;fill-opacity:0;" points="',(1↓∊{' ',(⍕⍺),',',(⍕⍵)}/¨↓points+5),'"/>'
          r←('svg width="',(⍕size[2]),'" height="',(⍕size[1]),'"')enc r
      :EndIf
      r←'<!DOCTYPE html>','html'enc'body'enc r
    ∇

    dtlb←{⍵{((∨\⍵)∧⌽∨\⌽⍵)/⍺}' '≠⍵} ⍝ delete leading and trailing blanks
    yx←{(R r p)←⍵ ⋄ Rr←R+r ⋄ ⍉(Rr×1 2∘.○⍺)+p×1 2∘.○Rr×⍺÷r} ⍝ calculate the y and x coordinates

    ∇ r←ScriptFollows
     ⍝ treat following commented lines in caller as a script, lines beginning with ⍝⍝ are stripped out
      r←{⎕ML←1 ⋄ ∊{'⍝'=⊃⍵:'' ⋄ ' ',dtlb ⍵}¨1↓¨⍵/⍨∧\'⍝'=⊃¨⍵}dtlb¨(1+2⊃⎕LC)↓⎕NR 2⊃⎕SI
    ∇


:EndNamespace
