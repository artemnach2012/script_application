#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================================
; НАСТРОЙКИ
; ============================================================
GITHUB_REPO := "artemnach2012/scripts_update"
RAW_BASE    := "https://raw.githubusercontent.com/" GITHUB_REPO "/main/"
INI_FILE    := A_ScriptDir "\settings.ini"

; Список скриптов – лаунчер помечаем флагом isLauncher
scripts := Map()
scripts["Launcher"]    := { name: "Лаунчер",        file: "Launcher.ahk",    localVer: "0.0.0", isLauncher: true }
scripts["ArmyReports"] := { name: "Армия докладов", file: "ArmyReports.ahk", localVer: "0.0.0" }
scripts["AntiAFK"]     := { name: "Анти-АФК",        file: "AntiAFK.ahk",     localVer: "0.0.0" }
scripts["MoscowLive"]  := { name: "Москва-Live",     file: "MoscowLive.ahk",  localVer: "0.0.0" }

; ============================================================
; ГРАФИЧЕСКИЙ ИНТЕРФЕЙС
; ============================================================
mainGui := Gui(, "Панель управления скриптами"), mainGui.BackColor := "2A2A2A"
mainGui.SetFont("s10 cWhite", "Segoe UI")

; Формируем имена вкладок – порядок важен!
tabNames := ["Главная"]
for k, v in scripts
    tabNames.Push(v.name)
tabPanel := mainGui.Add("Tab3", "x10 y10 w610 h380 cWhite", tabNames)

; ---------- Вкладка "Главная" ----------
tabPanel.UseTab(1)
mainGui.SetFont("s12 Bold cWhite"), mainGui.Add("Text", "x20 y45 w590 Center", "🚀 Управление скриптами AutoHotkey")
mainGui.SetFont("s9 Italic cFF5555"), mainGui.Add("Text", "x20 y70 w590 Center", "Данное приложение находится в статусе: БЕТА-ВЕРСИЯ")

mainGui.SetFont("s10 Bold cWhite")
mainGui.Add("Text", "x30 y100 w150", "Название"), mainGui.Add("Text", "x190 y100 w80", "Версия")
mainGui.Add("Text", "x280 y100 w100", "Статус"), mainGui.Add("Text", "x390 y100 w210", "Действия")

guiControls := Map(), yPos := 130
for key, info in scripts {
    isLauncher := info.HasOwnProp("isLauncher") && info.isLauncher

    mainGui.SetFont("s10 Norm cWhite")
    mainGui.Add("Text", "x30 y" yPos " w150", info.name)
    verText := mainGui.Add("Text", "x190 y" yPos " w80 cYellow", "—")
    statusText := mainGui.Add("Text", "x280 y" yPos " w100 cGray", isLauncher ? "Активен" : "Не запущен")
    
    mainGui.SetFont("s9 cBlack")
    if (isLauncher) {
        btnStart := ""
        btnStop := ""
        (btnUpdate := mainGui.Add("Button", "x390 y" yPos " w65", "🔄 Обн.")).BackColor := "2196F3"
    } else {
        (btnStart := mainGui.Add("Button", "x390 y" yPos " w65", "▶ Старт")).BackColor := "4CAF50"
        (btnStop := mainGui.Add("Button", "x460 y" yPos " w65 Disabled", "⏹ Стоп")).BackColor := "F44336"
        (btnUpdate := mainGui.Add("Button", "x530 y" yPos " w65", "🔄 Обн.")).BackColor := "2196F3"
    }

    guiControls[key] := { verText: verText, statusText: statusText, btnStart: btnStart, btnStop: btnStop, btnUpdate: btnUpdate }
    if (!isLauncher) {
        btnStart.OnEvent("Click", StartScript.Bind(key))
        btnStop.OnEvent("Click", StopScript.Bind(key))
    }
    btnUpdate.OnEvent("Click", UpdateScript.Bind(key))
    yPos += 35
}
mainGui.SetFont("s9 cBlack")
(btnUpdateAll := mainGui.Add("Button", "x30 y" (yPos + 15) " w150", "🔄 Обновить все")).BackColor := "4CAF50"
btnUpdateAll.OnEvent("Click", UpdateAllScripts)

; ---------- Вкладки настроек (только для обычных скриптов) ----------
configFields := Map()

; Переменная для отслеживания текущего номера вкладки
; Вкладка 1 – "Главная", поэтому начинаем с 2
tabIndex := 2

for key, info in scripts {
    ; Пропускаем лаунчер – для него нет настроек
    if (info.HasOwnProp("isLauncher") && info.isLauncher) {
        tabIndex += 1   ; всё равно сдвигаем индекс, чтобы сохранить соответствие
        continue
    }
    
    ; Переключаемся на нужную вкладку
    tabPanel.UseTab(tabIndex)
    tabIndex += 1   ; готовим для следующего скрипта

    mainGui.SetFont("s12 Bold cWhite"), mainGui.Add("Text", "x30 y50 w550", "Настройки: " info.name)
    mainGui.SetFont("s10 Bold cFF5555")
    mainGui.Add("Text", "x30 y80 w550", "⚠️ ВНИМАНИЕ: Настройки в данный момент НЕ РАБОТАЮТ!")
    mainGui.SetFont("s10 Norm cWhite")
    
    if (key == "ArmyReports") {
        cfg1 := mainGui.Add("CheckBox", "x40 y115 w300", "Включить автоматический доклад по таймеру")
        cfg1.Value := IniRead(INI_FILE, "ArmyReports", "AutoReport", 0)
        mainGui.Add("Text", "x40 y155", "Клавиша для ручного доклада:")
        cfg2 := mainGui.Add("Edit", "x250 y152 w100 Background3A3A3A cWhite", IniRead(INI_FILE, "ArmyReports", "Hotkey", "F8"))
        configFields["ArmyReports"] := [cfg1, cfg2]
    }
    else if (key == "AntiAFK") {
        mainGui.Add("Text", "x40 y115", "Интервал между действиями (в секундах):")
        cfg1 := mainGui.Add("Edit", "x320 y112 w80 Background3A3A3A cWhite Number", IniRead(INI_FILE, "AntiAFK", "Interval", "30"))
        cfg2 := mainGui.Add("CheckBox", "x40 y155 w300", "Отправлять случайный символ в чат вместо прыжка")
        cfg2.Value := IniRead(INI_FILE, "AntiAFK", "ChatAntiAFK", 0)
        configFields["AntiAFK"] := [cfg1, cfg2]
    }
    else if (key == "MoscowLive") {
        cfg1 := mainGui.Add("CheckBox", "x40 y115 w300", "Автоматически ловить объявления на сервере")
        cfg1.Value := IniRead(INI_FILE, "MoscowLive", "CatchAds", 0)
        mainGui.Add("Text", "x40 y155", "Задержка перед редактированием (мс):")
        cfg2 := mainGui.Add("Edit", "x300 y152 w100 Background3A3A3A cWhite Number", IniRead(INI_FILE, "MoscowLive", "Delay", "500"))
        configFields["MoscowLive"] := [cfg1, cfg2]
    }
    
    mainGui.SetFont("s9 cBlack")
    mainGui.Add("Button", "x40 y330 w150", "💾 Сохранить").OnEvent("Click", SaveSettings.Bind(key))
}

tabPanel.UseTab()  ; снимаем выделение
mainGui.SetFont("s10 cGray")
statusBar := mainGui.Add("Text", "x15 y400 w610", "Готов к работе.")
mainGui.Show("w630 h430")

; ============================================================
; ФУНКЦИИ (без изменений)
; ============================================================

HideFile(p) {
    if FileExist(p)
        FileSetAttrib("+H", p)
}

GetLocalVersion(p) {
    if !FileExist(p)
        return "0.0.0"
    Loop Read, p, "UTF-8" {
        if (A_Index <= 10 && RegExMatch(A_LoopReadLine, "; @version\s+([\d\.]+)", &m))
            return m.1
    }
    return "0.0.0"
}

HTTPGet(url) {
    try {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("GET", url "?t=" A_TickCount, false)
        whr.SetRequestHeader("Pragma", "no-cache")
        whr.SetRequestHeader("Cache-Control", "no-cache")
        whr.Send()
        if (whr.Status == 200)
            return whr.ResponseText
    }
    return ""
}

ParseSimpleJSON(j) {
    obj := Map()
    j := Trim(j, "{} `t`n`r")
    if (j == "")
        return obj
    for part in StrSplit(j, ",") {
        part := Trim(part)
        if RegExMatch(part, '"(.*?)"\s*:\s*"(.*?)"', &m)
            obj[m.1] := m.2
    }
    return obj
}

GetRemoteVersions() {
    jsonText := HTTPGet(RAW_BASE "version.json")
    return (jsonText != "") ? ParseSimpleJSON(jsonText) : Map()
}

StopScript(key, *) {
    p := A_ScriptDir "\" scripts[key].file
    DetectHiddenWindows(true)
    SetTitleMatchMode(2)
    winTitle := p " ahk_class AutoHotkey"
    if WinExist(winTitle) {
        try {
            PostMessage(0x0111, 65405, 0,, winTitle)
            Sleep(250)
        }
        if WinExist(winTitle) {
            try {
                WinKill(winTitle)
                Sleep(250)
            }
        }
        if WinExist(winTitle) {
            try {
                scriptPID := WinGetPID(winTitle)
                if scriptPID
                    ProcessClose(scriptPID)
                Sleep(250)
            }
        }
    }
    guiControls[key].statusText.Value := "Остановлен"
    guiControls[key].statusText.SetFont("cFF5555")
    guiControls[key].btnStart.Enabled := true
    guiControls[key].btnStop.Enabled := false
    statusBar.Value := "⏹ Остановлен: " scripts[key].name
    DetectHiddenWindows(false)
}

StartScript(key, *) {
    info := scripts[key]
    p := A_ScriptDir "\" info.file
    if !FileExist(p) {
        MsgBox("Файл " info.file " не найден! Сначала нажмите 'Обн.'.", "Ошибка", "Iconi")
        return
    }
    HideFile(p)
    ahkRuntime := A_AhkPath
    if (A_IsCompiled) {
        if FileExist("C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe")
            ahkRuntime := "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
        else if FileExist("C:\Program Files\AutoHotkey\v2\AutoHotkey32.exe")
            ahkRuntime := "C:\Program Files\AutoHotkey\v2\AutoHotkey32.exe"
        else
            ahkRuntime := "AutoHotkey64.exe"
    }
    Run('"' ahkRuntime '" "' p '"')
    guiControls[key].statusText.Value := "Запущен"
    guiControls[key].statusText.SetFont("c00FF00")
    guiControls[key].btnStart.Enabled := false
    guiControls[key].btnStop.Enabled := true
    statusBar.Value := "▶ Запущен: " info.name
}

SaveSettings(key, *) {
    fields := configFields[key]
    if (key == "ArmyReports") {
        IniWrite(fields[1].Value, INI_FILE, "ArmyReports", "AutoReport")
        IniWrite(fields[2].Text,  INI_FILE, "ArmyReports", "Hotkey")
    } else if (key == "AntiAFK") {
        IniWrite(fields[1].Text,  INI_FILE, "AntiAFK", "Interval")
        IniWrite(fields[2].Value, INI_FILE, "AntiAFK", "ChatAntiAFK")
    } else if (key == "MoscowLive") {
        IniWrite(fields[1].Value, INI_FILE, "MoscowLive", "CatchAds")
        IniWrite(fields[2].Text,  INI_FILE, "MoscowLive", "Delay")
    }
    p := A_ScriptDir "\" scripts[key].file
    DetectHiddenWindows(true)
    if WinExist(p " ahk_class AutoHotkey") {
        StopScript(key, "")
        Sleep(200)
        StartScript(key, "")
        statusBar.Value := "🔄 Настройки сохранены. Скрипт '" scripts[key].name "' перезапущен."
    } else {
        MsgBox("Настройки для скрипта '" scripts[key].name "' успешно сохранены!", "Успешно", "Iconi")
    }
    DetectHiddenWindows(false)
}

; ============================================================
; ОБНОВЛЕНИЕ ЛАУНЧЕРА (САМООБНОВЛЕНИЕ)
; ============================================================
UpdateLauncher() {
    info := scripts["Launcher"]
    p := A_ScriptDir "\" info.file
    rem := GetRemoteVersions()
    rv := rem.Has("Launcher") ? rem["Launcher"] : ""
    if (rv == "") {
        scriptText := HTTPGet(RAW_BASE info.file)
        if (scriptText != "") {
            Loop Parse, scriptText, "`n", "`r" {
                if (A_Index <= 10 && RegExMatch(A_LoopField, "; @version\s+([\d\.]+)", &m)) {
                    rv := m.1
                    break
                }
            }
        }
        if (rv == "") {
            MsgBox("Не удалось получить версию для лаунчера.", "Ошибка", "Iconi")
            return false
        }
    }
    lv := GetLocalVersion(p)
    if (rv == lv && lv != "0.0.0") {
        MsgBox("У вас уже последняя версия лаунчера (" lv ").", "Информация", "Iconi")
        guiControls["Launcher"].btnUpdate.Enabled := false
        return true
    }
    newFile := A_ScriptDir "\Launcher_new.ahk"
    try {
        Download(RAW_BASE info.file "?t=" A_TickCount, newFile)
    } catch {
        MsgBox("Ошибка скачивания нового лаунчера.", "Ошибка", "Iconi")
        return false
    }
    ; Создаём обновлятор с надёжным экранированием кавычек
    updaterScript := A_ScriptDir "\_updater.ahk"
    q := Chr(34)  ; двойная кавычка
    updaterContent := "#Requires AutoHotkey v2.0`n"
        . "#SingleInstance Force`n"
        . "Sleep 1000`n"
        . "FileCopy " q newFile q ", " q p q ", 1`n"
        . "Run " q A_AhkPath q " " q p q "`n"
        . "Sleep 500`n"
        . "try FileDelete " q newFile q "`n"
        . "try FileDelete A_ScriptFullPath`n"
        . "ExitApp"
    try {
        FileDelete(updaterScript)
        FileAppend(updaterContent, updaterScript, "UTF-8")
    } catch {
        MsgBox("Не удалось создать обновлятор.", "Ошибка", "Iconi")
        return false
    }
    Run('"' A_AhkPath '" "' updaterScript '"')
    ExitApp()
}

; ============================================================
; ОБНОВЛЕНИЕ ЛЮБОГО СКРИПТА (ВКЛЮЧАЯ ЛАУНЧЕР)
; ============================================================
UpdateScript(key, *) {
    if (key == "Launcher") {
        return UpdateLauncher()
    }
    info := scripts[key]
    p := A_ScriptDir "\" info.file
    rem := GetRemoteVersions()
    rv := rem.Has(key) ? rem[key] : ""
    if (rv == "") {
        scriptText := HTTPGet(RAW_BASE info.file)
        if (scriptText != "") {
            Loop Parse, scriptText, "`n", "`r" {
                if (A_Index <= 10 && RegExMatch(A_LoopField, "; @version\s+([\d\.]+)", &m)) {
                    rv := m.1
                    break
                }
            }
        }
        if (rv == "") {
            MsgBox("Не удалось получить версию для " info.name, "Ошибка", "Iconi")
            return false
        }
    }
    lv := GetLocalVersion(p)
    if (rv == lv && lv != "0.0.0") {
        MsgBox("У вас уже последняя версия (" lv ").", "Информация", "Iconi")
        guiControls[key].btnUpdate.Enabled := false
        return true
    }
    DetectHiddenWindows(true)
    if WinExist(p " ahk_class AutoHotkey") {
        StopScript(key, "")
        Sleep(500)
    }
    DetectHiddenWindows(false)
    try {
        if FileExist(p)
            FileSetAttrib("-H", p)
        Download(RAW_BASE info.file "?t=" A_TickCount, p ".new")
        FileMove(p ".new", p, 1)
        HideFile(p)
        info.localVer := rv
        guiControls[key].verText.Value := rv
        guiControls[key].btnUpdate.Enabled := false
        statusBar.Value := "✅ Обновлён: " info.name " до версии " rv
        MsgBox("Скрипт " info.name " обновлён до версии " rv, "Успешно", "Iconi")
        return true
    } catch {
        MsgBox("Критическая ошибка при скачивании " info.name, "Ошибка", "Iconi")
        return false
    }
}

UpdateAllScripts(*) {
    statusBar.Value := "Проверка обновлений..."
    updated := 0
    for k, v in scripts {
        if UpdateScript(k, "")
            updated++
    }
    MsgBox(updated ? "Обновление завершено. Обновлено: " updated : "Все скрипты уже актуальны.", "Результат", "Iconi")
    statusBar.Value := "Обновление завершено."
}

CheckAllVersions() {
    rem := GetRemoteVersions()
    for k, v in scripts {
        p := A_ScriptDir "\" v.file
        if FileExist(p)
            HideFile(p)
        lv := GetLocalVersion(p)
        v.localVer := lv
        guiControls[k].verText.Value := lv
        if !FileExist(p)
            guiControls[k].btnUpdate.Enabled := true
        else if (rem.Has(k) && rem[k] != lv)
            guiControls[k].btnUpdate.Enabled := true
        else
            guiControls[k].btnUpdate.Enabled := false
    }
    statusBar.Value := "✅ Проверка версий завершена"
}

; Запускаем проверку версий при старте
SetTimer(CheckAllVersions, -500)

; Горячая клавиша для выхода
~Esc:: {
    if WinActive("ahk_class AutoHotkeyGUI")
        ExitApp()
}
