; <COMPILER: v1.1.37.02>
#Requires AutoHotkey v2.0
#SingleInstance Force
; @version 1.2.0
; остальной код...
#SingleInstance Force
if not A_IsAdmin {
Run('*RunAs "' A_ScriptFullPath '"')
ExitApp()
}
global paragraphs := []
global infoGui := ""
global helpGui := ""
IsHoroscope(text) {
if RegExMatch(text, "♈|♉|♊|♋|♌|♍|♎|♏|♐|♑|♒|♓")
return true
if RegExMatch(text, "Овен|Телец|Близнецы|Рак|Лев|Дева|Весы|Скорпион|Стрелец|Козерог|Водолей|Рыбы")
return true
return false
}
GroupByTwo(arr) {
grouped := []
loop arr.Length {
if (Mod(A_Index, 2) = 1) {
if (A_Index = arr.Length) {
grouped.Push(arr[A_Index])
} else {
paired := arr[A_Index] . "`n`n" . arr[A_Index + 1]
grouped.Push(paired)
}
}
}
return grouped
}
SplitByQuestions(text) {
blocks := []
pos := 1
while (pos <= StrLen(text)) {
if (RegExMatch(text, "Вопрос\s+\d+:", &match, pos)) {
startQ := match.Pos
endQ := startQ + match.Len - 1
nextPos := RegExMatch(text, "Вопрос\s+\d+:", , endQ + 1)
if (nextPos = 0)
nextPos := StrLen(text) + 1
questionBlock := SubStr(text, startQ, nextPos - startQ)
questionBlock := StrReplace(questionBlock, "`r`n", " ")
questionBlock := StrReplace(questionBlock, "`n", " ")
questionBlock := RegExReplace(questionBlock, " {2,}", " ")
questionBlock := Trim(questionBlock)
if (questionBlock != "")
blocks.Push(questionBlock)
pos := nextPos
} else {
break
}
}
return blocks
}
^!c:: {
global paragraphs, infoGui
paragraphs := []
oldClip := ClipboardAll()
A_Clipboard := ""
Send("^c")
if !ClipWait(1) {
ToolTip("Ошибка: не удалось скопировать текст")
SetTimer(() => ToolTip(), -2000)
return
}
rawText := A_Clipboard
rawText := StrReplace(rawText, "`r`n", "`n")
cleanLines := ""
Loop Parse, rawText, "`n" {
cleanLines .= Trim(A_LoopField, " `t`r") "`n"
}
cleanLines := RegExReplace(cleanLines, "\n{3,}", "`n`n")
cleanLines := Trim(cleanLines, "`n")
if RegExMatch(cleanLines, "Вопрос\s+\d+:", &match) {
paragraphs := SplitByQuestions(cleanLines)
} else if IsHoroscope(cleanLines) {
rawBlocks := StrSplit(cleanLines, "`n`n")
tempBlocks := []
for block in rawBlocks {
cleanBlock := Trim(StrReplace(block, "`n", " "))
cleanBlock := RegExReplace(cleanBlock, " {2,}", " ")
if (cleanBlock != "")
tempBlocks.Push(cleanBlock)
}
paragraphs := GroupByTwo(tempBlocks)
} else {
rawBlocks := StrSplit(cleanLines, "`n`n")
for index, block in rawBlocks {
cleanBlock := StrReplace(block, "`n", " ")
cleanBlock := RegExReplace(cleanBlock, " {2,}", " ")
cleanBlock := Trim(cleanBlock)
if (cleanBlock != "")
paragraphs.Push(cleanBlock)
}
if (paragraphs.Length > 1) {
lastIndex := paragraphs.Length
lastBlock := paragraphs[lastIndex]
if (RegExMatch(cleanLines, "`n([^\n]+)$", &lastLineMatch)) {
lastLineText := Trim(lastLineMatch.1)
if (InStr(lastBlock, lastLineText) && lastBlock != lastLineText) {
paragraphs[lastIndex] := Trim(StrReplace(lastBlock, lastLineText, ""))
paragraphs.Push(lastLineText)
}
}
}
}
A_Clipboard := oldClip
ShowHelpWindow()
}
ShowHelpWindow() {
global paragraphs, infoGui
if (infoGui != "")
infoGui.Destroy()
if (paragraphs.Length == 0)
return
infoGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
infoGui.BackColor := "1F1F1F"
infoGui.SetFont("s10 cYellow Bold", "Segoe UI")
infoGui.Add("Text", "w380 Center", "📋 ШПАРГАЛКА NUMPAD:")
maxCount := (paragraphs.Length > 10) ? 10 : paragraphs.Length
Loop maxCount {
preview := SubStr(paragraphs[A_Index], 1, 60)
if (StrLen(paragraphs[A_Index]) > 60)
preview .= "..."
keyName := (A_Index == 10) ? "Numpad0" : "Numpad" A_Index
infoGui.SetFont("s9 cYellow Bold", "Segoe UI")
infoGui.Add("Text", "w70 x15 y+8", keyName)
infoGui.SetFont("s9 cWhite", "Segoe UI")
infoGui.Add("Text", "w290 x+5 yp", "➔  " preview)
}
infoGui.SetFont("s9 cGray Bold", "Segoe UI")
infoGui.Add("Text", "w350 x15 y+12 Center", "─────────────────────────────────")
infoGui.SetFont("s9 cYellow Bold", "Segoe UI")
infoGui.Add("Text", "w70 x15 y+8", "Numpad +")
infoGui.SetFont("s9 c00FF66 Bold", "Segoe UI")
infoGui.Add("Text", "w290 x+5 yp", "➔  продолжаем редакт")
infoGui.SetFont("s9 cYellow Bold", "Segoe UI")
infoGui.Add("Text", "w70 x15 y+8", "Numpad ,")
infoGui.SetFont("s9 cFF5555 Bold", "Segoe UI")
infoGui.Add("Text", "w290 x+5 yp", "➔  стоп редакт!")
infoGui.Show("x" (A_ScreenWidth - 500) " y250 NoActivate")
WinSetTransparent(220, infoGui)
}
ShowHelpInfo() {
global helpGui
if (helpGui != "") {
helpGui.Destroy()
helpGui := ""
}
helpGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
helpGui.BackColor := "2A2A2A"
helpGui.SetFont("s10 cWhite", "Segoe UI")
helpGui.Add("Text", "w420 Center", "🚀 Скрипт Москва-Live активен!")
helpGui.SetFont("s9 cYellow", "Segoe UI")
helpGui.Add("Text", "w420 y+10 Center", "Горячие клавиши:")
helpGui.SetFont("s9 cWhite", "Segoe UI")
helpGui.Add("Text", "w420 y+5", "  Ctrl+Alt+C  – скопировать выделенное и разбить на абзацы")
helpGui.Add("Text", "w420", "  Ctrl+Alt+X  – показать шпаргалку (после Ctrl+Alt+C)")
helpGui.Add("Text", "w420", "  Numpad1-0   – вставить соответствующий абзац")
helpGui.Add("Text", "w420", "  Numpad+     – вставить «продолжаем редакт»")
helpGui.Add("Text", "w420", "  Numpad,     – вставить «стоп редакт!»")
helpGui.Add("Text", "w420", "  Esc         – закрыть активное окно (шпаргалку или справку)")
helpGui.SetFont("s9 cGray", "Segoe UI")
helpGui.Add("Text", "w420", "Для повторного открытия этой справки: Ctrl+Alt+H")
helpGui.SetFont("s8 cSilver", "Segoe UI")
helpGui.Add("Text", "w420 y+10 Center", "(окно автоматически закроется через 15 секунд)")
helpGui.Show("x" (A_ScreenWidth - 450) " y150 NoActivate")
WinSetTransparent(230, helpGui)
SetTimer(CloseHelpInfo, -15000)
}
CloseHelpInfo() {
global helpGui
if (helpGui != "") {
helpGui.Destroy()
helpGui := ""
}
}
SendParagraph(index) {
global paragraphs
if (index <= paragraphs.Length) {
oldClip := ClipboardAll()
A_Clipboard := paragraphs[index]
Send("^v")
Sleep(100)
Send("{Enter}")
Sleep(50)
A_Clipboard := oldClip
}
}
SendCustomText(textToText) {
oldClip := ClipboardAll()
A_Clipboard := textToText
Send("^v")
Sleep(100)
Send("{Enter}")
Sleep(50)
A_Clipboard := oldClip
}
$Numpad1:: SendParagraph(1)
$Numpad2:: SendParagraph(2)
$Numpad3:: SendParagraph(3)
$Numpad4:: SendParagraph(4)
$Numpad5:: SendParagraph(5)
$Numpad6:: SendParagraph(6)
$Numpad7:: SendParagraph(7)
$Numpad8:: SendParagraph(8)
$Numpad9:: SendParagraph(9)
$Numpad0:: SendParagraph(10)
$NumpadDot:: SendCustomText("стоп редакт!")
$NumpadAdd:: SendCustomText("продолжаем редакт")
^!x:: {
global paragraphs
if (paragraphs.Length > 0)
ShowHelpWindow()
else {
ToolTip("Буфер пуст! Сначала скопируйте текст через Ctrl+Alt+C")
SetTimer(() => ToolTip(), -2000)
}
}
^!h:: {
global helpGui
if (helpGui != "") {
helpGui.Destroy()
helpGui := ""
} else {
ShowHelpInfo()
}
}
~Esc:: {
global infoGui, helpGui
if (infoGui != "") {
infoGui.Destroy()
infoGui := ""
}
if (helpGui != "") {
helpGui.Destroy()
helpGui := ""
}
}
ShowHelpInfo()
