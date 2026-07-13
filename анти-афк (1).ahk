; ==============================================================================
; НАЗВАНИЕ: Умный Бесшумный Anti-AFK (Рандомный WASD кликер)
; АВТОР: Zagorodnev Scripts
; ОПИСАНИЕ: Имитирует случайные движения человека для обхода жестких анти-АФК.
; КЛАВИША АКТИВАЦИИ: F8
; ==============================================================================

#Persistent
#SingleInstance, Force
#MaxThreadsPerHotkey, 2

Toggle := false

F8::
    Toggle := !Toggle
    if (Toggle) {
        ; Включаем подсказку на экране и запускаем таймер
        ToolTip, Random WASD: ВКЛ, 100, 100
        SetTimer, RandomPress, -1   ; Немедленный первый запуск
    } else {
        ; Выключаем подсказку и останавливаем таймер
        ToolTip, Random WASD: ВЫКЛ, 100, 100
        SetTimer, RandomPress, Off
        Sleep 1000
        ToolTip
    }
return

RandomPress:
    if (!Toggle)
        return

    ; 🎲 Шаг 1: Случайный выбор клавиши (1 - W, 2 - A, 3 - S, 4 - D)
    Random, r, 1, 4
    key := (r = 1 ? "w" : r = 2 ? "a" : r = 3 ? "s" : "d")

    ; ⏳ Шаг 2: Случайное время удержания клавиши (от 50 до 400 мс)
    Random, holdTime, 50, 400

    ; 💤 Шаг 3: Случайная пауза до следующего шага (от 200 до 1500 мс)
    Random, nextDelay, 200, 1500

    ; Выполнение действия в игре
    Send, {%key% down}
    Sleep, %holdTime%
    Send, {%key% up}

    ; Планируем следующее случайное нажатие
    if (Toggle)
        SetTimer, RandomPress, % -nextDelay
return
