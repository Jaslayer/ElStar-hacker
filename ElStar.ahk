CoordMode("Mouse", "Window")
CoordMode("Pixel", "Window")

images := ["./arrow/up.png", "./arrow/down.png", "./arrow/left.png", "./arrow/right.png"]
coordinate_file := "./arrow/coordinate.txt"
delay := 100

;讀取方向鍵座標
fileContent := FileRead(coordinate_file)
lines := StrSplit(fileContent, "`n")
coordinates := StrSplit(lines[lines.Length], " ")

if (coordinates.Length != 3) {
    MsgBox coordinate_file " 內容不符合預期。"
} else {
    X := coordinates[1]
    Y := coordinates[2]
    SZ := coordinates[3]
}
if (X = 0 || Y = 0 || SZ = 0) { 
    MsgBox "初次使用，請進行座標設定。" 
}

DetectImagesInRange() {
    x1 := X
    y1 := Y
    detectTimes := 10

    matchedIndices := []

    Loop detectTimes {
        x2 := x1 + SZ
        y2 := y1 + SZ

        Loop images.Length {
            index := A_Index
            foundX := 0
            foundY := 0

            found := ImageSearch(&foundX, &foundY, x1, y1, x2, y2, "*180 " images[index])
            if found {
                matchedIndices.Push(index)
                break
                ;MsgBox "圖片: " images[index]
            } else {
                ;MsgBox "圖片未找到: " images[index]
            }
        }
        x1 += SZ
    }
    return matchedIndices
}

Sendkey(seq) {
    for key in seq {
        switch(key) {
            case 1: 
                Send "{Up down}"
                Sleep delay
                Send "{Up up}"
            case 2: 
                Send "{Down down}"
                Sleep delay
                Send "{Down up}"
            case 3: 
                Send "{Left down}"
                Sleep delay
                Send "{Left up}"
            case 4: 
                Send "{Right down}"
                Sleep delay
                Send "{Right up}"
            default: 
                MsgBox "key error"
        }
        Sleep 50
    }
    Send "{Escape down}"
    Sleep delay
    Send "{Escape up}"
}

NextStage() {
    Send "{Up down}{Down down}{Left down}{Right down}"
    Sleep delay
    Send "{Up up}{Down up}{Left up}{Right up}"
    Sleep 50
    Send "{Escape down}"
    Sleep delay
    Send "{Escape up}"
}

ShowResult(seq) {
    indicesStr := "" 
    for index in seq { 
        switch index {
            case 1:
                indicesStr .= "▲ "
            case 2:
                indicesStr .= "▼ "
            case 3:
                indicesStr .= "◄ "
            case 4:
                indicesStr .= "► "  
        }
    }
    MsgBox indicesStr
}

$\:: {
    Loop 3 {
        Loop 3 {
            seq := DetectImagesInRange()
            if (seq.Length != 10) { 
                MsgBox "偵測失敗" 
                return
            }
            Sendkey(seq)
        }
        NextStage()
    }
    Sleep 4300

    Send "{Up down}"
    Sleep delay
    Send "{Up up}"
}

$+\:: {
    ;設定方向鍵座標

    ; 第一次點擊
    while !GetKeyState("LButton", "P")
        Sleep(10)
    MouseGetPos(&x1, &y1)
    while GetKeyState("LButton", "P")
        Sleep(10)

    ; 第二次點擊
    while !GetKeyState("LButton", "P")
        Sleep(10)
    MouseGetPos(&x2, &y2)
    while GetKeyState("LButton", "P")
        Sleep(10)

    ; 顯示記錄的座標
    sz := (x2 - x1)//9
    MsgBox  x1 " " y1 " " sz
    ExitApp
}


$^\::ExitApp
