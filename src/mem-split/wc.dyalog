wc←{
    blockAdd←{(⍺[1],(⍺+⍵)[2 3 4],⍵[5])-(0 0(⍺[5]∧⍵[1])0 0)}
    fd←⍵ ⎕NTIE 0
    res←fd blockCount rc blockAdd 5⍴0
    _←⎕NUNTIE fd
    res[4 3 2]
}
