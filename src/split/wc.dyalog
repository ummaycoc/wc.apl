wc←{
    res←1 5⍴0
    update←{
        val←res,[1]blockCount ⍵
        res∘←val
        val
    }
    fd←⍵ ⎕NTIE 0
    _←update rc fd
    _←⎕NUNTIE fd
    (blockCollapse res)[4 3 2]
}
