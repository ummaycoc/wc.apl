v←(f rc)fd;data
v←⍬
:Repeat
    data←⎕NREAD fd 80(1024×1024)
    :If 0<≢data
        v←f data
    :EndIf
:Until 0=≢data
