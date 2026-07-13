#Requires AutoHotkey v2.0
#SingleInstance Force

; ==================== ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ ====================
reports := []
currentIndex := 1
intervalMinutes := 1.0
timerRunning := false
remainingMs := 0

rank := ""
surname := ""
post := ""

; ==================== СОЗДАНИЕ GUI ====================
MyGui := Gui(, "Армия докладов")
MyGui.BackColor := "2A2A2A"

; Заголовок
MyGui.SetFont("s14 cYellow Bold", "Segoe UI")
MyGui.Add("Text", "xm w400 Center", "📢 АРМИЯ ДОКЛАДОВ")

; Поля ввода
MyGui.SetFont("s10 cWhite", "Segoe UI")
MyGui.Add("Text", "xm y+20", "Звание:")
MyGui.SetFont("s10 cBlack", "Segoe UI")
edtRank := MyGui.Add("Edit", "w200 xm y+5 BackgroundFFFFFF", "")

MyGui.Add("Text", "xm y+15", "Фамилия:")
edtSurname := MyGui.Add("Edit", "w200 xm y+5 BackgroundFFFFFF", "")

MyGui.Add("Text", "xm y+15", "Пост:")
edtPost := MyGui.Add("Edit", "w200 xm y+5 BackgroundFFFFFF", "КПП-1")

MyGui.Add("Text", "xm y+15", "Интервал (минуты):")
edtInterval := MyGui.Add("Edit", "w80 xm y+5 BackgroundFFFFFF", "10")

; Кнопки
MyGui.SetFont("s10 cBlack Bold", "Segoe UI")
btnStart := MyGui.Add("Button", "xm y+20 w100", "▶ Старт")
btnStart.BackColor := "4CAF50"
btnStop := MyGui.Add("Button", "x+10 w100 Disabled", "⏹ Стоп")
btnStop.BackColor := "F44336"
btnConfirm := MyGui.Add("Button", "x+10 w120 Hidden", "✅ Отправил")
btnConfirm.BackColor := "2196F3"

; Таймер
MyGui.SetFont("s28 cLime Bold", "Segoe UI")
txtTimer := MyGui.Add("Text", "xm y+20 w400 Center", "⏳ 00:00.00")

; Статус
MyGui.SetFont("s10 cWhite", "Segoe UI")
txtStatus := MyGui.Add("Text", "xm y+15 w400 Center", "Готов к работе.")

; ==================== ОБРАБОТЧИКИ ====================
btnStart.OnEvent("Click", StartReports)
btnStop.OnEvent("Click", StopReports)
btnConfirm.OnEvent("Click", ConfirmSent)
MyGui.OnEvent("Close", (*) => ExitApp())

; ==================== ФУНКЦИИ ====================
StartReports(*) {
    global rank, surname, post, intervalMinutes, reports, currentIndex, timerRunning
    rank := edtRank.Value
    surname := edtSurname.Value
    post := edtPost.Value
    if (rank = "" || surname = "" || post = "") {
        MsgBox("Заполните все поля!", "Ошибка", "Icon!")
        return
    }
    intervalMinutes := edtInterval.Value + 0.0
    if !IsNumber(intervalMinutes) || intervalMinutes <= 0 {
        MsgBox("Интервал должен быть положительным числом (в минутах)!", "Ошибка", "Icon!")
        return
    }

    ; ========== ГЕНЕРАЦИЯ 5 ДОКЛАДОВ С АВТО-ВРЕМЕНЕМ ==========
    reports := []
    ; 1. Заступление
    reports.Push("Докладывает: " rank " " surname " | Заступил на пост: " post " | Состав: 1 | Пост принял | Доклад окончен.")
    ; 2, 3, 4 – с временем, кратным интервалу
    Loop 3 {
        timeMinutes := intervalMinutes * A_Index   ; A_Index = 1,2,3
        ; Округляем до целого, если хотим без дробей (опционально)
        ; timeMinutes := Round(timeMinutes)
        reports.Push("Докладывает: " rank " " surname " | Пост: " post " | Состав: 1 | " timeMinutes " мин | Состояние: стабильное | Доклад окончен.")
    }
    ; 5. Сдача поста
    reports.Push("Докладывает: " rank " " surname " | Пост: " post " | Состав: 1 | Состояние стабильное | Пост сдал | Доклад окончен.")

    currentIndex := 1
    timerRunning := false
    SetTimer(UpdateTimer, 0)
    txtTimer.Value := "⏳ 00:00.00"

    A_Clipboard := reports[currentIndex]
    txtStatus.Value := "📋 Доклад №" currentIndex " скопирован. Отправьте и нажмите 'Отправил'."
    btnStart.Enabled := false
    btnStop.Enabled := true
    btnConfirm.Visible := true
    btnConfirm.Enabled := true
    btnConfirm.Text := "✅ Отправил"
}

ConfirmSent(*) {
    global currentIndex, reports, intervalMinutes, timerRunning, remainingMs
    if (timerRunning)
        return

    if (currentIndex >= reports.Length) {
        timerRunning := false
        SetTimer(UpdateTimer, 0)
        txtTimer.Value := "⏳ 00:00.00"
        txtStatus.Value := "🏁 Все доклады отправлены! Работа завершена."
        btnConfirm.Visible := false
        btnStart.Enabled := true
        btnStop.Enabled := false
        SoundBeep(1500, 300)
        ToolTip("✅ Все доклады отправлены!")
        SetTimer(() => ToolTip(), -3000)
        return
    }

    timerRunning := true
    remainingMs := intervalMinutes * 60 * 1000
    btnConfirm.Enabled := false
    btnConfirm.Text := "⏳ Ожидание..."
    txtStatus.Value := "⏳ Следующий доклад через " intervalMinutes " мин."
    SetTimer(UpdateTimer, 50)
}

UpdateTimer() {
    global timerRunning, remainingMs, currentIndex, reports, intervalMinutes
    if !timerRunning {
        SetTimer(UpdateTimer, 0)
        return
    }

    remainingMs -= 50
    if (remainingMs <= 0) {
        timerRunning := false
        SetTimer(UpdateTimer, 0)
        txtTimer.Value := "⏳ 00:00.00"
        currentIndex += 1
        A_Clipboard := reports[currentIndex]
        SoundBeep(1000, 300)
        ToolTip("🔔 Доклад №" currentIndex " скопирован в буфер!")
        SetTimer(() => ToolTip(), -3000)
        txtStatus.Value := "📋 Доклад №" currentIndex " скопирован. Отправьте и нажмите 'Отправил'."
        btnConfirm.Enabled := true
        btnConfirm.Text := (currentIndex >= reports.Length) ? "🏁 Завершить" : "✅ Отправил"
        return
    }

    totalSec := remainingMs / 1000
    minutes := Floor(totalSec / 60)
    seconds := Floor(Mod(totalSec, 60))
    centiseconds := Floor(Mod(totalSec * 100, 100))
    txtTimer.Value := "⏳ " Format("{:02}:{:02}.{:02}", minutes, seconds, centiseconds)
}

StopReports(*) {
    global timerRunning
    timerRunning := false
    SetTimer(UpdateTimer, 0)
    txtTimer.Value := "⏳ 00:00.00"
    btnStart.Enabled := true
    btnStop.Enabled := false
    btnConfirm.Visible := false
    btnConfirm.Enabled := false
    txtStatus.Value := "⏹ Остановлено."
    currentIndex := 1
}

IsNumber(val) {
    if val is Number
        return true
    if (Type(val) = "String" && RegExMatch(val, "^-?\d+(\.\d+)?$"))
        return true
    return false
}

; ==================== ЗАПУСК ====================
MyGui.Show()
return
