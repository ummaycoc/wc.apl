res←fd(m rc r)init;data
res←init
:Repeat
    data←⎕NREAD fd 80(1024×1024)
    :If 0<≢data
        res←res r m data
    :EndIf
:Until 0=≢data
