FileEncoding, UTF-8

; -----------------------------------------------------------------
; Скрипт AutoHotkey для уведомлений с интервалами от 07:00 до 24:00
; -----------------------------------------------------------------


; ----------------------------------------
; Вводные данные и переменные
; ----------------------------------------
; Загрузка сообщений из файла
; Формат файла: 08:00=Сообщение для 8:00
; Каждая строка содержит время и сообщение через знак равно (=)

; Если сообщение пустое, будет использовано дефолтное сообщение
global DefaultMessage := "
(
=================================
------->>>  ДОРОГУ ОСИЛИТ ИДУЩИЙ!
=================================
------->>>  ДИСЦИПЛИНА!
=================================
)"

; ----------------------------------------
; Глобальные переменные
; ----------------------------------------
; Путь к файлу с сообщениями
global filePath := "C:\...\...\...\AutoHotkeys\Reminder\messages.txt"

global messages := {}
global title := ""
global imagePath := ""
global numberLines := 1

; Значения по умолчанию для цветов
global backgroundColor := ""
global textColor := ""



; ----------------------------------------
; Настройка интервалов времени
; ----------------------------------------
global times := ["07:00", "08:00", "09:00", "10:00", "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "16:30", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00", "23:00", "24:00"]



; ----------------------------------------
; Функция для создания окна с многострочным текстом и отступами
; ----------------------------------------
CreateCustomWindow(text, bgColor, textColor) {
    global numberLines

    ; Создаем новое окно GUI
    Gui, New
    
    ; Устанавливаем цвет текста и шрифт
    Gui, Font, s10, Tahoma

    ; Добавляем title-время
    Gui, Add, Text, cGreen w500 r1, %title%

    ; Добавляем многострочный текст 
    Gui, Add, Text, c%textColor% w500 r%numberLines%, %text%
    
    ; Добавляем изображение, если оно задано и существует
    if (imagePath != "") {
        Gui, Add, Picture, h500 w500, %imagePath%
    }

    ; Устанавливаем цвет фона
    Gui, Color, %bgColor%
    
    ; Дополнительные настройки окна
    Gui, +LastFound +AlwaysOnTop +ToolWindow

    ; Автоматически подстраиваем размер окна под все элементы
    Gui, Show, AutoSize, %title%

    StartingBeep() ; Вызов звукового сигнала

    ; Устанавливаем таймер (300000 миллисекунд)
    Sleep, 300000

    ; Уничтожаем окно GUI
    Gui, Destroy

    return
}



; ----------------------------------------
; Читаем файл с уведомлениями и возвращаем сообщение для текущего времени
; ----------------------------------------
GetMessageForTime(currentTime){
    global filePath, DefaultMessage, backgroundColor, textColor, numberLines, imagePath

    ; Проверка наличия файла перед чтением
    if !FileExist(filePath) {
        MsgBox, 16, Error, The file does not exist: %filePath%
        ExitApp
    }

    currentMessage := ""
    isReadingMessage := false

    Loop, Read, %filePath%
    {
        ; Если мы нашли разделитель "===END===", прекращаем чтение текущего сообщения
        if (Trim(A_LoopReadLine) = "===END===" && isReadingMessage)
        {
            return RTrim(currentMessage, "`n")  ; Возвращаем сообщение
        }else if (isReadingMessage)
        {
            ; Проверяем, является ли текущая строка настройкой цвета
            StringSplit, timeMsg, A_LoopReadLine, `:  
            if (Trim(timeMsg1) = "===ColorB===")
            {
                backgroundColor := Trim(timeMsg2)
            }
            else if (Trim(timeMsg1) = "===ColorT===")
            {
                textColor := Trim(timeMsg2)
            }
            else if (Trim(timeMsg1) = "===IMAGE===")
            {
                imagePath := Trim(timeMsg2) ":" timeMsg3
            }
            else
            {
                numberLines++
                currentMessage .= A_LoopReadLine "`n"  ; Добавляем строки
            }
        }
        else
        {
            ; Если строка соответствует текущему времени
            StringSplit, timeMsg, A_LoopReadLine, =
            if (Trim(timeMsg1) = currentTime and Trim(timeMsg2) != "")
            {
                numberLines++
                currentMessage .= Trim(timeMsg2) "`n"  ; Начало сообщения
                title := currentTime
                isReadingMessage := true  ; Активируем чтение сообщения
            }
        }
    }
    
    title := currentTime
    global backgroundColor := "Black"
    global textColor := "Red"
    global imagePath := "C:\...\...\...\AutoHotkeys\photo\1.jpg"
    global numberLines := 7
    return DefaultMessage  ; Если ничего не найдено, возвращаем дефолтное сообщение
}



StartingBeep(){
    Run, C:\...\...\...\AutoHotkeys\Reminder\timer.mp3
    Sleep, 1000
    Run, C:\...\...\...\AutoHotkeys\anno\1.mp3
    
    ; Run, C:\...\...\...\AutoHotkeys\Reminder\timer.mp3
    ; Sleep, 1000
    ; Закрываем Windows Media Player
    ; Process, Close, wmplayer.exe
}



; ----------------------------------------
; Главный цикл проверки времени
; ----------------------------------------
Loop
{
    SetTimer, ShowMessage, 45000
    FormatTime, currentTime,, HH:mm

    ; Засыпаем на одну минуту
    Sleep, 45000
}



; ----------------------------------------
; Функция для проверки наличия элемента в массиве
; ----------------------------------------
IsInArray(arr, val)
{
    for each, element in arr
    {
        if (element = val)
            return true
    }
    return false
}



; ----------------------------------------
; Вывод сообщения
; ----------------------------------------
ShowMessage:
    global times, backgroundColor, textColor, numberLines

    FormatTime, currentTime,, HH:mm
    ; Проверяем, есть ли текущее время в списке времен
    if (IsInArray(times, currentTime))
    {
        ; Вызов функции
        msg := GetMessageForTime(currentTime)
        if (msg != "") {
            CreateCustomWindow(msg, backgroundColor, textColor)
        }
    }
    numberLines := 1
    return