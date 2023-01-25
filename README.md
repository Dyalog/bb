bb
==

Brian's Playground

This repository contains stuff I've tinkered with, some of it may be interesting, some of it may be incomplete.  The contents are provided "as is".

----------

## `xhtml.dyalog` namespace

Contains utilities to:
- convert HTML to XHTML which is subsequently able to be parsed by `⎕XML`
- search and extract elements from the result of `⎕XML`

### `HTMLtoXHTML`
`xhtml ← xhtml.HTMLtoXHTML html`
`html` is a character vector containing HTML
`xhtml` is a matrix form of the XHTML

`HTMLtoXHTML` assumes that the HTML is reasonably formed (e.g. open tags have corresponding closing tags). It handles most, but probably not all, HTMLisms of some elements not requiring a closing tag.

### `Xfind`
`boolvec ← xml xhtml.Xfind spec`
`xml` is an XML matrix (could be XHTML, but doesn't have to be)
`spec` is a delimited-string search specification (first character is the delimiter) in the form `/levels/elements/content/attribute/value` where:
- `levels`, if non-empty, specifies the level(s) to consider in the search.  For example:
    - `3` specifies level 3 elements only, `3-` level 3 and lower (to 0), `3+` level 3 and higher, `3-5` levels 3 through 5
- `elements` is a space-delimited list of elements to select
- `content` is case-insensitive content to search for using `⍷`
- `attribute` is a case-sensitive attribute name to exactly search for
- `value` is a case-insensitive attribute value to search for using `⍷`, if no `attribute` is specified, all attributes will be searched.

`boolvec` is a Boolean vector marking matching elements

Examples:
```

      xml xhtml.Xfind '//table//class/results' ⍝ find all <table> elements with a class attribute containing 'results'

      xml xhtml.Xfind '/2////foobar' ⍝ find all level 2 elements with any attribute containing 'foobar'

      xml xhtml.Xfind '/3+/th td/bloof' ⍝ find all level 3 or higher <th> or <td> elements containing 'bloof' 
```
### `Xsel`
`elements ← xml Xsel boolvec`
`xml` is an XML matrix (could be XHTML, but doesn't have to be)
`boolvec` is a Boolean vector with as many elements as rows in `xml`
`elements` is a nested vector of elements marked by `boolvec` and their descendants

### Typical Use Case
In general, you'll convert some HTML to XHTML and then search for and extract element of interest to you.  For example:

```

      resp ← HttpCommand.Get 'someurl.com/somefile.html' ⍝ make a request 
      'request failed' ⎕SIGNAL (0 200≢resp.(rc HttpStatus))/777 ⍝ check that it succeeded
      h ← resp.Data ⍝ grab the response data
      x ← xhtml.HTMLtoXHTML h ⍝ convert to XHTML
      mytables ← x xhtml.Xsel x xhtml.Xfind '//table/class/results' ⍝ extract all the <table> elements with a class attribute containing "results" 


