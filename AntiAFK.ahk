#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxThreadsPerHotkey 2

; @version 2.0.0

Toggle := false

F8:: {
    global Toggle
    Toggle := !Toggle
    if Toggle {
        ToolTip("Random WASD: ВКЛ", 100, 100)
        SetTimer(RandomPress, -1)
    } else {
        ToolTip("Random WASD: ВЫКЛ", 100, 100)
        SetTimer(RandomPress, 0)
        Sleep(1000)
        ToolTip()
    }
}

RandomPress() {
    global Toggle
    if !Toggle
        return
    r := Random(1, 4)
    key := (r = 1) ? "w" : (r = 2) ? "a" : (r = 3) ? "s" : "d"
    holdTime := Random(50, 400)
    nextDelay := Random(200, 1500)
    Send("{" key " down}")
    Sleep(holdTime)
    Send("{" key " up}")
    if Toggle
        SetTimer(RandomPress, -nextDelay)
}
