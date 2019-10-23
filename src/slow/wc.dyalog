res←wc fn;c;w;l;fd;data;blk;nl;sp;lnsp;words
words←{≢(~⍵)⊆⍵}
blk←256×1024
nl←⎕UCS¨10 11 12 13
sp←nl,⎕UCS¨9 32
c←w←l←0
fd←fn ⎕NTIE 0
lnsp←0
:Repeat
    data←⎕NREAD fd 80 blk
    :If 0=≢data
        :Leave
    :EndIf
    c←c+(≢data)
    l←l++/data∊nl
    data←data∊sp
    w←(w+words data)-(lnsp∧~1↑data)
    lnsp←~(¯1)↑data
:EndRepeat
⎕NUNTIE fd
res←l w c
