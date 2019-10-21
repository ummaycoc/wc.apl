blockCollapse←{
    adjustment←0 0(-+/(1↓⍵[;1])∧(¯1)↓⍵[;5])0 0
    collapsed←(⍵[1;1]),(+⌿⍵)[2 3 4],(⍵[≢⍵;5])
    adjustment+collapsed
}
