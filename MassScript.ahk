#NoEnv
#Persistent
#SingleInstance, Force


; ----------------------- ГЛОБАЛЬНЫЕ НАСТРОЙКИ ----------------------------
; Глобальные переменные для состояния
global MButtonCount := 0
global EscCount := 0
global AltCount := 0

global KeyPressed := ""
global TimerActive := false
global MonitorBounds := []
global CurrentMonitor := ""
global LastWindowID := ""
global isMinimized := false

global blackoutWindows := {}
global blackoutFile := "C:\Users\User\Desktop\AutoHotkeys\monitor\blackout_state.txt"



; Определение границ экранов
SysGet, MonitorCount, MonitorCount ; Получаем количество мониторов
Loop %MonitorCount% {
    SysGet, Monitor, Monitor, %A_Index%
    MonitorBounds.Push({Left: MonitorLeft, Top: MonitorTop, Right: MonitorRight, Bottom: MonitorBottom})
}



; Устанавливаем режим координат мыши в глобальный (относительно экрана)
CoordMode, Mouse, Screen

; --------------------------------------------------------------------------




; ------------------ ОБРАБОТКА БЛОКИРОВКИ MBUTTON --------------------------
; Обработка MButton
~MButton::
{
    global CurrentMonitor, MonitorBounds, MButtonCount, TimerActive, LastWindowID
    MouseGetPos, MouseX, MouseY, , , Screen ; Получаем текущую позицию мыши

    For index, bounds in MonitorBounds {
        if (MouseX >= bounds.Left && MouseX <= bounds.Right && MouseY >= bounds.Top && MouseY <= bounds.Bottom) {
            CurrentMonitor := index
        }
    }

    ; Проверка на рабочий стол и живые обои
    MouseGetPos,,, WindowUnderMouseID
    WinGetClass, WinClass, ahk_id %WindowUnderMouseID%
    WinGet, ProcessName, ProcessName, ahk_id %WindowUnderMouseID%
    
    MButtonCount++
    SetTimer, CheckKeys, -20 ; Для двойных кликов
    SetTimer, DisableKeyListener, -500 ; Запуск таймера на 1 секунду
    if !(WinClass = "WorkerW" or WinClass = "Progman" or ProcessName = "wallpaper64.exe")
    {
        TimerActive := true
    }
    return
}



; Считает количество нажатий на Esc и запускет в зависимости от это определенную программу
MButton & Esc::
{
    SetTimer, DisableEscListener, -500 ; Обновление основного таймера при нажатии клавиши
    EscCount++
    return
}


; Считает количество нажатий на Alt
~*Alt Up::
{
    SetTimer, DisableAltListener, -20 ; Обновление основного таймера при нажатии клавиши
    AltCount++
    return
}

; ---------------------------------------------------------------------------

  


; ----------------------- РАБОТА С ПРОГРАММАМИ ------------------------------
; Скрипт для Android Studio
MButton & a::
{
    ; Логика для studio64.exe
    IfWinExist, ahk_exe studio64.exe
    {
        IfWinActive
        {
            WinMinimize ; Сворачиваем окно, если оно активно
        }
        else
        {
            WinActivate ; Разворачиваем окно, если оно не активно
        }
    }
    else
    {
        Run, C:\Program Files\Android\Android Studio\bin\studio64.exe ; Запускаем studio64.exe, если оно не запущено 
    }
    return
}


; Объявляем глобальные переменные для хранения ID окон
global YandexWindowID := ""
global ChatGPTWindowID := ""

; Функция для поиска окон с нужными заголовками
FindWindows()
{
    ; Ищем окна с заголовками, содержащими "Яндекс" или точный заголовок "ChatGPT"
    WinGet, windowsList, List, ahk_exe browser.exe
    YandexWindowID := ""  ; Обнуляем переменные перед поиском
    ChatGPTWindowID := ""

    Loop, %windowsList%
    {
        WinGetTitle, thisWindowTitle, % "ahk_id " windowsList%A_Index%
        
        ; Используем регулярные выражения для поиска нужных окон
        if (RegExMatch(thisWindowTitle, "i)^ChatGPT$"))
        {
            ChatGPTWindowID := windowsList%A_Index%
        }
        else
        {
            YandexWindowID := windowsList%A_Index%
        }
    }
}

; Хоткей для взаимодействия с главным окном (Яндекс)
MButton & 1::
{
    FindWindows()

    if (YandexWindowID != "")
    {
        IfWinExist, ahk_id %YandexWindowID%
        {
            IfWinActive, ahk_id %YandexWindowID%
            {
                WinMinimize ; Сворачиваем окно браузера, если оно активно
            }
            else
            {
                WinActivate ; Активируем окно браузера, если оно не активно
            }
        }
    }
    else
    {
        Run, C:\Users\User\AppData\Local\Yandex\YandexBrowser\Application\browser.exe
        ; Запуск основного браузера
    }
    return
}

; Хоткей для взаимодействия с мини-приложением (ChatGPT)
MButton & 2::
{
    FindWindows()

    if (ChatGPTWindowID != "")
    {
        IfWinExist, ahk_id %ChatGPTWindowID%
        {
            IfWinActive, ahk_id %ChatGPTWindowID%
            {
                WinMinimize ; Сворачиваем окно, если оно активно
            }
            else
            {
                WinActivate ; Активируем окно, если оно не активно
            }
        }
    }
    else
    {
        SendInput, {LWin down}{0}{LWin up}
    }
    return
}

; Хоткей для взаимодействия с Obsidian
MButton & 3::
{
    ; Логика для Obsidian.exe
    IfWinExist, ahk_exe Obsidian.exe
    {
        IfWinActive
        {
            WinMinimize ; Сворачиваем окно, если оно активно
        }
        else
        {
            WinActivate ; Разворачиваем окно, если оно не активно
        }
    }
    else
    {
        Run, C:\Users\User\AppData\Local\Programs\Obsidian\Obsidian.exe ; Запускаем Obsidian.exe, если оно не запущено 
    }
    return
}

; Переменные для отслеживания состояния
global toggleState := false

; Горячая клавиша MButton + 4
MButton & 4::
{
    global toggleState

    ; Переключаем состояние
    toggleState := !toggleState
    
    ; Загружаем файл
    filePath := "D:\MyDataBase\.obsidian\snippets\Obsidian.css"

    FileRead, fileContent, %filePath%
    if (toggleState) {
        ; Включение (удаляем комментарий)
        modifiedContent := StrReplace(fileContent, "/* DELETE THIS LINE TO ENABLE", "/* MARKER: ENABLED */")
    } else {
        ; Отключение (добавляем комментарий обратно)
        modifiedContent := StrReplace(fileContent, "/* MARKER: ENABLED */", "/* DELETE THIS LINE TO ENABLE")
    }
    
    ; Записываем изменения обратно в файл
    FileDelete, %filePath% ; Удаляем файл, чтобы перезаписать его
    FileAppend, %modifiedContent%, %filePath%
    
    return
}


; Горячая клавиша MButton + 5
MButton & 5::
{
    global toggleState

    ; Переключаем состояние
    toggleState := !toggleState
    
    ; Загружаем файл
    filePath := "D:\MyDataBase\.obsidian\snippets\MouseFocuse.css"

    FileRead, fileContent, %filePath%
    if (toggleState) {
        ; Включение (удаляем комментарий)
        modifiedContent := StrReplace(fileContent, "/* DELETE THIS LINE TO ENABLE", "/* MARKER: ENABLED */")
    } else {
        ; Отключение (добавляем комментарий обратно)
        modifiedContent := StrReplace(fileContent, "/* MARKER: ENABLED */", "/* DELETE THIS LINE TO ENABLE")
    }
    
    ; Записываем изменения обратно в файл
    FileDelete, %filePath% ; Удаляем файл, чтобы перезаписать его
    FileAppend, %modifiedContent%, %filePath%
    
    return
}


; Скрипт для Notepad
MButton & q::
{
    global MButtonCount

    ; Логика для блокнота (Notepad)
    IfWinExist, ahk_exe notepad.exe
    {
        if (MbuttonCount >= 2) {
            Run, C:\Program Files\Notepad++\notepad++.exe
            MbuttonCount := 0
        }else {
            IfWinActive
            {
                WinMinimize ; Сворачиваем блокнот, если он активен
            }
            else
            {
                WinActivate ; Разворачиваем блокнот, если он не активен
            }
        }
    }
    else
    {
        if (MbuttonCount >= 2) {
            Run, C:\Program Files\Notepad++\notepad++.exe
            MbuttonCount := 0
        }else {
            Run, notepad.exe ; Запускаем блокнот, если он не запущен
        }
    }
    return
}

; ---------------------------------------------------------------------------



; ------------------------ РАБОТА СО СТРОКАМИ -------------------------------

; Скрипт для перевода многострочного кода в одну строку и обратно
^MButton::
{
    ; Сохраняем текущее содержимое буфера обмена
    ClipboardBackup := ClipboardAll
    Clipboard := ""  ; Очищаем буфер обмена

    ; Копируем выделенный текст
    Send ^c
    ClipWait, 0.5

    if (Clipboard != "")
    {
        ; Проверяем, является ли текст многострочным
        if (InStr(Clipboard, "`n") or InStr(Clipboard, "`r"))
        {
            ; Обработка многострочного текста: удаление переносов строк
            RemainingText := RegExReplace(Clipboard, "s)(\R|\n|\r)+", " ")

            ; Заменяем множественные пробелы на один пробел
            RemainingText := RegExReplace(RemainingText, "\s+", " ")

            ; Заменяем множественные пробелы на один пробел
            RemainingText := RegExReplace(RemainingText, "\s\.", ".")

            RemainingText := RegExReplace(RemainingText, "\(\s+", "(")
            RemainingText := RegExReplace(RemainingText, "\s+\)", ")")

            ; Переносим отформатированный текст в буфер обмена
            Clipboard := RemainingText
        }
        else
        {
            ; Обработка однострочного текста: форматирование модификаторов
            TransformedText := RegExReplace(Clipboard, "\.(?=\w+\()", "`n            .")

            ; Если форматирование модификаторов не было найдено, ищем функции с параметрами
            if (TransformedText = Clipboard)
            {
                ; Этап 1: Оставляем скобку на месте и добавляем перенос строки перед параметрами
                TransformedText := RegExReplace(Clipboard, "\((.*?)\)", "(`n$1`n)")

                ; Этап 2: Добавляем перенос строки после запятых
                TransformedText := RegExReplace(TransformedText, ",\s*", ",`n    ")
            }

            ; Обновляем буфер обмена измененным текстом
            Clipboard := TransformedText
        }

        ; Вставляем измененный текст
        Send ^v{Sleep 30}{Home}{Sleep 30}
    }

    ; Восстанавливаем исходное содержимое буфера обмена
    Clipboard := ClipboardBackup
    return
}


; ---------------------------------------------------------------------------



; -------------------------- РАБОТА С ОКНАМИ --------------------------------

; ChatGPT >>> переход к полю ввода
MButton & Tab::
{
    Send +{Esc}
    return
}


; CTRL + SHIFT + MButton - закрывает приложение
^+MButton::
{
    ; Получаем ID окна под указателем мыши
    MouseGetPos,,, WindowUnderMouseID

    ; Проверка на рабочий стол и живые обои
    WinGetClass, WinClass, ahk_id %WindowUnderMouseID%
    WinGet, ProcessName, ProcessName, ahk_id %WindowUnderMouseID%

    ; Если окно под указателем мыши является рабочим столом или живыми обоями, ничего не делаем
    if (WinClass = "WorkerW" or WinClass = "Progman" or ProcessName = "wallpaper64.exe")
    {
        return
    }else {
        WinClose, ahk_id %WindowUnderMouseID%
	return
    }
}


; Обработка MButton
MButton & z::
{
    ; Прожимает ctrl + \
    Send ^\
    return
}


; Скрипт для сворачивания/разворачивания всех окон
MButton & s::
{
    global isMinimized

    ; Если окна уже скрыты, развернуть их
    if (isMinimized)
    {
        WinMinimizeAllUndo ; Восстанавливаем все окна
        isMinimized := false
    }
    else
    {
        ; Сворачиваем все окна
        WinMinimizeAll
        isMinimized := true
    }
    return
}


!MButton::
{
    global AltCount

    ; Получаем ID окна под указателем мыши
    MouseGetPos,,, WindowUnderMouseID

    ; Проверка на рабочий стол и живые обои
    WinGetClass, WinClass, ahk_id %WindowUnderMouseID%
    WinGet, ProcessName, ProcessName, ahk_id %WindowUnderMouseID%

    ; Если окно под указателем мыши является рабочим столом или живыми обоями, ничего не делаем
    if (WinClass = "WorkerW" or WinClass = "Progman" or ProcessName = "wallpaper64.exe")
    {
        ; Проверяем, свернуто ли окно
        WinGet, MinimizedState, MinMax, ahk_id %LastWindowID%
        
        if (MinimizedState = -1) ; Если окно свернуто
        {
            WinRestore, ahk_id %LastWindowID% ; Разворачиваем окно
        }
        else
        {
            WinMinimize, ahk_id %LastWindowID% ; Сворачиваем окно
        }
    }
    else
    {
        ; Проверяем, свернуто ли окно
        WinGet, MinimizedState, MinMax, ahk_id %LastWindowID%
        
        if (MinimizedState = -1 && AltCount >= 2) ; Если окно свернуто
        {
            WinRestore, ahk_id %LastWindowID% ; Разворачиваем окно
        }else {
	    ; Свернуть окно под указателем мыши
            WinMinimize, ahk_id %WindowUnderMouseID%
            LastWindowID := WindowUnderMouseID  ; Сохраняем ID свернутого окна
	}
    }

    AltCount := 0
    return
}


#MButton::
{
    ; Получаем ID окна под указателем мыши
    MouseGetPos,,, WindowUnderMouseID

    ; Проверка на рабочий стол и живые обои
    WinGetClass, WinClass, ahk_id %WindowUnderMouseID%
    WinGet, ProcessName, ProcessName, ahk_id %WindowUnderMouseID%

    ; Если окно под указателем мыши является рабочим столом или живыми обоями, ничего не делаем
    if (WinClass = "WorkerW" or WinClass = "Progman" or ProcessName = "wallpaper64.exe")
    {
        return ; Прерываем скрипт, если под указателем рабочий стол или живые обои
    }
    
    ; Проверяем, развернуто ли окно на весь экран
    WinGet, WindowState, MinMax, ahk_id %WindowUnderMouseID%
    if (WindowState = 1) ; Окно развернуто
    {
        WinRestore, ahk_id %WindowUnderMouseID% ; Восстанавливаем окно до нормального размера
    }
    else
    {
        WinMaximize, ahk_id %WindowUnderMouseID% ; Разворачиваем окно на весь экран
    }
    return
}


; Обеспечиваем, чтобы Win не блокировался
~LWin Up::Send {LWin Up}


; Увеличение сторон окна во все стороны, адаптивно к экрану
; Обработчики горячих клавиш
~MButton & g:: SelectedSymbol("g")
~MButton & h:: SelectedSymbol("h")
~MButton & j:: SelectedSymbol("j")
~MButton & y:: SelectedSymbol("y")
~MButton & f:: SelectedSymbol("f")
~MButton & k:: SelectedSymbol("k")
~MButton & u:: SelectedSymbol("u")
~MButton & n:: SelectedSymbol("n")


SelectedSymbol(Key) {
    global KeyPressed, TimerActive
    KeyPressed := Key ; Получаем нажатую клавишу
    if (!TimerActive) {
        return
    }
    
    ExecuteResize()
    SetTimer, DisableKeyListener, -500 ; Обновление основного таймера при нажатии клавиши
    return
}

ExecuteResize() {
    global KeyPressed, MButtonCount
    if (KeyPressed = "") {
        return
    }

    ; Определяем увеличение или уменьшение
    IsIncrease := (MButtonCount = 1)
    
    ; Вызов функции изменения размера
    ResizeWindow(KeyPressed, IsIncrease)
    
    ; Сброс состояния после выполнения изменения
    KeyPressed := ""
    return
}

ResizeWindow(Direction, IsIncrease) {
    global CurrentMonitor, MonitorBounds
	
    ; Если не удалось определить монитор, отменяем изменение размера
    if (CurrentMonitor = 0) {
        return
    }

    ; Определяем текущие границы экрана для активного монитора
    bounds := MonitorBounds[CurrentMonitor]

    WinGet, WinID, ID, A
    WinGetPos, X, Y, W, H, ahk_id %WinID%
    ResizeStep := 0.1 ; 10%
    MinSize := 100 ; Минимальный размер окна

    
    NewX := X
    NewW := W
    NewY := Y
    NewH := H
    
    if (IsIncrease) { ; Увеличение
        if (Direction = "g") {
            NewX := X - (W * ResizeStep)
            NewW := W * (1 + ResizeStep)
        } else if (Direction = "h") {
            NewH := H * (1 + ResizeStep)
        } else if (Direction = "j") {
            NewW := W * (1 + ResizeStep)
        } else if (Direction = "y") {
            NewY := Y - (H * ResizeStep)
            NewH := H * (1 + ResizeStep)
        }
    } else { ; Уменьшение
        if (Direction = "g") {
            NewW := W * (1 - ResizeStep)
        } else if (Direction = "h") {
            NewY := Y + (H * ResizeStep)
            NewH := H * (1 - ResizeStep)
        } else if (Direction = "j") {
            NewX := X + (W * ResizeStep)
            NewW := W * (1 - ResizeStep)      
        } else if (Direction = "y") {
            NewH := H * (1 - ResizeStep)
        }
    }

    if (Direction = "f") {
        NewX := X - 100
    }
    if (Direction = "k") {
        NewX := X + 100
    }
    if (Direction = "u") {
        NewY := Y - 100
    }
    if (Direction = "n") {
        NewY := Y + 100
    }
    
    NL := bounds.Left
    NT := bounds.Top
    NR := bounds.Right
    NB := bounds.Bottom

    ; Проверка на границы экрана
    if (NewX < bounds.Left) {
        NewX := bounds.Left
    }
    if (NewY < bounds.Top) {
        NewY := bounds.Top
    }
    if ((NewX + NewW) > bounds.Right) {
        NewW := bounds.Right - NewX
    }
    if ((NewY + NewH) > bounds.Bottom) {
        NewH := Bounds.Bottom - NewY
    }
    
    ; Проверка минимальных размеров
    if (NewW < MinSize) {
        NewW := MinSize
    }
    if (NewH < MinSize) {
        NewH := MinSize
    }
    
    ; Изменение размера окна
    WinMove, ahk_id %WinID%, , %NewX%, %NewY%, %NewW%, %NewH%
}
; ---------------------------------------------------------------------------




; -------------------------- Слушатели и тд ---------------------------------

DisableKeyListener:
    global TimerActive, MButtonCount, KeyPressed
    TimerActive := false
    MButtonCount := 0
    KeyPressed := ""
    return

CheckKeys:
    global MButtonCount

    if (MButtonCount < 2){
        MButtonCount := 1
    }else if (MButtonCount >= 2){
        MButtonCount := 2
    }

    return


DisableAltListener:
    global AltCount

    if (AltCount < 2){
        AltCount := 1
    }else if (AltCount >= 2){
        AltCount := 2
    }
    return


DisableEscListener:
    global EscCount

    if (EscCount = 1){
	Run, "C:\Program Files\WindowsApps\TelegramMessengerLLP.TelegramDesktop_4.15.0.0_x64__t4vj0pshhgkwm\Telegram.exe" -- tg://join?invite=paR4TdiojoozODAy
    }else if (EscCount = 2) {
	Run, "C:\Program Files\WindowsApps\TelegramMessengerLLP.TelegramDesktop_4.15.0.0_x64__t4vj0pshhgkwm\Telegram.exe" -- tg://resolve?domain=cuvalinao
    } else if (EscCount = 3) {
	Run, "C:\Program Files\WindowsApps\TelegramMessengerLLP.TelegramDesktop_4.15.0.0_x64__t4vj0pshhgkwm\Telegram.exe" -- tg://join?invite=dT1_Is_r2DUxMTEy
    } else if (EscCount = 4) {
        Run, "C:\Program Files\WindowsApps\TelegramMessengerLLP.TelegramDesktop_4.15.0.0_x64__t4vj0pshhgkwm\Telegram.exe" -- tg://join?invite=qe2chOzZDdtmNDJi
    } else if (EscCount = 5) {
        Run, C:\Users\User\Desktop\AutoHotkeys\anno\5.png
    }


    EscCount := 0
    return

; ---------------------------------------------------------------------------





; -------------------------- Гашу экран ---------------------------------
MButton & Space:: ; TOGGLE
MouseGetPos, mx, my

loop % MonitorBounds.Length() {
    mon := MonitorBounds[A_Index]
    if (mx >= mon["Left"] && mx <= mon["Right"] && my >= mon["Top"] && my <= mon["Bottom"]) {
        id := A_Index
        break
    }
}

if !id {
    MsgBox, Не удалось определить монитор под мышкой.
    return
}

winTitle := "Blackout_" id

if WinExist(winTitle) {
    Gui, % "Blackout" id ":Destroy"
    return
}

mon := MonitorBounds[id]
x := mon["Left"]
y := mon["Top"]
w := (mon["Right"] - mon["Left"]) * 0.8 ; уменьшили ширину на 20%
h := mon["Bottom"] - mon["Top"]

Gui, % "Blackout" id ":New", +AlwaysOnTop -Caption +ToolWindow +E0x20 +LastFound
Gui, % "Blackout" id ":Color", 0x000000
WinSet, Transparent, 255
Gui, % "Blackout" id ":Show", x%x% y%y% w%w% h%h%, %winTitle%
return
; ---------------------------------------------------------------------------




























