blockCount←{
    l←+/⍵∊⎕UCS¨10 11 12 13  ⍝ #lines
    s←⍵∊⎕UCS¨9 10 11 12 13 32  ⍝ is space
    w←(~(¯1)↑s)++/1=(1↓s)-(¯1)↓s  ⍝ words
    ⍝ first-non-space, chars, words, lines, last-non-space
    (~1↑s)(≢⍵)w l(~(¯1)↑s)
}
