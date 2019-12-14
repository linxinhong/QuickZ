CoordMode, mouse, Screen
; SetBatchLines, -1
DetectHiddenWindows On


class gesturez {
    static self := new gesturez._instance

    class _instance {
        __new() {
            this.pr := {}
            this.gestureList := {}
            this.gestruePNGdir := A_ScriptDir "\ges\"
            this.gesturePNGSave := false
            this.ElapsedTime := 120
            this.OCRMode := false
            this.OCRMode_min_direction_count := 1
        }
    }

    class PosRecord {
        __new(Width, Height) {
            this.xmax := 0
            this.ymax := 0
            this.xmin := Width
            this.ymin := Height
            this.Count := 0
            this.List := []
        }

        Push(x1, y1, x2, y2) {
            this.Count += 1
            this.List.push({x1: x1, y1: y1, x2: x2, y2: y2})
            If (x1 >= this.xmax) {
                this.xmax := x1
            }
            If (x2 >= this.xmax) {
                this.xmax := x2
            }
            If (x1 <= this.xmin) {
                this.xmin := x1
            }
            If (x2 <= this.xmin) {
                this.xmin := x2
            }
            If (y1 >= this.ymax) {
                this.ymax := y1
            }
            If (y2 >= this.ymax) {
                this.ymax := y2
            }
            If (y1 <= this.ymin) {
                this.ymin := y1
            }
            If (y2 <= this.ymin) {
                this.ymin := y2
            }
            ; tooltip % this.xmax "`n" this.xmin "`n" this.ymax "`n" this.ymin
        }


    }

    add(gesName, gesAction) {
        gesturez.self.gestureList[gesName] := gesAction
    }

    DoAction(gesName) {
        Action := gesturez.self.gestureList[gesName]
        quickz.log({topic: "GestureZ", content: "name: " gesName " action: " Action})
        if (IsFunc(Action)) {
            Func(Action).call()
        }
        else if (IsLabel(Action)) {
            Gosub, %Action%
        }
        else if (IsObject(Action)) {
            Action.call()
        }
    }

    Recognize() {
        Critical
        OCRMode := gesturez.self.OCRMode
        OCRMode_min_direction_count := gesturez.self.OCRMode_min_direction_count
        direction_count := 0
        gesturez.self.action := action
        IsDrawLine := false
        StartTime := A_TickCount
        MouseGetPos, x_init, y_init, win, ctrl
        x_start := x_init
        y_start := y_init
        x_angle_start := x_init
        y_angle_start := y_init
        Loop {
            if (not GetKeyState("RButton", "P")) {
                if (IsDrawLine) {
                    GUI, gesturez:Destroy
                }
                WinActive("ahk_id " win)
                ElapsedTime := A_TickCount - StartTime
                if (ElapsedTime < gesturez.self.ElapsedTime) {
                    send {%A_ThisHotkey%}
                }
                else {
                    if (OCRMode) {
                        gesturez.Review()
                    }
                    else {
                        gesturez.DoAction(DirectionList)
                    }
                }
                if (IsDrawLine and pToken) {
                    Gdip_DeletePen(pPen)
                    SelectObject(hdc, obm)
                    DeleteObject(hbm)
                    DeleteDC(hdc)
                    Gdip_DeleteGraphics(G)
                    Gdip_Shutdown(pToken)
                }
                break
            }
            MouseGetPos, x_end, y_end
            moveradius := gesturez.GetRadius(x_start, y_start, x_end, y_end)
            if (direction_count <= OCRMode_min_direction_count) {
                x_angle_end := x_end
                y_angle_end := y_end
                angleRadius := gesturez.GetRadius(x_angle_start, y_angle_start, x_angle_end, y_angle_end)
                if (angleRadius >= 20) {
                    LastDirection := gesturez.GetDirection(gesturez.GetAngle(x_angle_start, y_angle_start, x_angle_end, y_angle_end))
                    if (LastDirection <> PrevDirection) {
                        direction_count += 1
                        DirectionList .= LastDirection
                        PrevDirection := LastDirection
                    }
                    x_angle_start := x_end
                    y_angle_start := y_end
                }
            }
            else {
                OCRMode := true
            }
            if (moveradius >= 3) {
                if (not IsDrawLine) {
                    Width := A_ScreenWidth , Height := A_ScreenHeight
                    gesturez.self.pr := new gesturez.PosRecord(Width, Height)
                    Gui, gesturez: -Caption +E0x80000 +LastFound +OwnDialogs +Owner +AlwaysOnTop
                    Gui, gesturez: Show, NA W%Width% H%Height%
                    Gui, gesturez: Default
                    hwnd1 := WinExist()
                    if (not pToken := GDIP_StartUp()) {
                        return
                    }
                    hbm := CreateDIBSection(Width, Height)
                    hdc := CreateCompatibleDC()
                    obm := SelectObject(hdc, hbm)
                    G := Gdip_GraphicsFromHDC(hdc)
                    Gdip_SetSmoothingMode(G, 4)
                    pPen := Gdip_CreatePen(gesturez.ARGB_FromRGB(0xAA, 0xff), 3)
                    IsDrawLine := true
                }
                Gdip_DrawLine(G, pPen, x_start, y_start, x_end, y_end)
                gesturez.self.pr.push(x_start, y_start, x_end, y_end)
                x_start := x_end
                y_start := y_end
                UpdateLayeredWindow(hwnd1, hdc, 0, 0, Width, Height)
            }
            else {
                sleep 50
            }
        }
        Critical, off
    }

    Review() {
        pr := gesturez.self.pr
        pfile := gesturez.self.gestruePNGdir "GestureZ" A_Now ".png"
        If !pToken := Gdip_Startup()
            return
        width:= pr.xmax - pr.xmin + 20
        height:= pr.ymax - pr.ymin + 20
        xmin := pr.xmin - 10
        ymin := pr.ymin - 10
        pBitmap := Gdip_CreateBitmap(width, height)
        G2 := Gdip_GraphicsFromImage(pBitmap)
        Gdip_SetSmoothingMode(G2, 4)
        pBrushWhite := Gdip_BrushCreateSolid(0xffffffff)
        Gdip_FillRectangle(G2, pBrushWhite, 0, 0, w, h)
        Gdip_DeleteBrush(pBrushWhite)
        pPen := Gdip_CreatePen(0xffff0000,3)
        Loop % pr.count
        {
            pos := pr.list[A_Index]
            Gdip_DrawLine(G2, pPen, Pos.x1-xmin, Pos.y1-ymin, Pos.x2-xmin, Pos.y2-ymin)
        }
        pBitmap := gesturez.Gdip_ResizeBitmap(pBitmap, "w16 h16")
        Gdip_SaveBitmapToFile(pBitmap, pfile)
        Gdip_DeletePen(pPen)
        Gdip_DisposeImage(pBitmap)
        Gdip_DeleteGraphics(G2)
        Gdip_Shutdown(pToken)
        tooltip 识别手势中...
        RunWaitOne( A_ScriptDir "\lib\tesseract.exe  " pfile " " A_TEMP "\gesturez.output -l gesture --psm 7 --tessdata-dir " A_ScriptDir "\lib")
        FileRead, gestext, %A_TEMP%\gesturez.output.txt
        tooltip
        gesturez.DoAction(SubStr(gestext, 1, strlen(gestext) - RegExMatch(gestext, "\n")))
    }

    GetRadius(StartX, StartY, EndX, EndY) {
        a := Abs(endX-startX), b := Abs(endY-startY), Radius := Sqrt(a*a+b*b)
        Return Radius    
    }

    GetAngle(StartX, StartY, EndX, EndY) {
        x := EndX - StartX
        y := EndY - StartY
        if (x = 0) {
            if (y > 0) {
                return 180
            }
            else if ( y < 0 ) {
                return 360
            }
            else {
                return
            }
        }
        deg := ATan(y/x)*57.295779513
        if ( x > 0 ) 
            return deg + 90
        else 
            return deg + 270	
    }

    GetDirection(Angle) {
        if ( Angle > 337.5 ) OR ( Angle <= 22.5)
            return 2
        if ( Angle > 22.5 ) And ( Angle <= 67.5)
            return 3
        if ( Angle > 67.5 ) And ( Angle <= 112.5)
            return 6
        if ( Angle > 112.5 ) And ( Angle <= 157.5)
            return 9
        if ( Angle > 157.5 ) And ( Angle <= 202.5)
            return 8
        if ( Angle > 202.5 ) And ( Angle <= 247.5)
            return 7
        if ( Angle > 247.5 ) And ( Angle <= 292.5)
            return 4
        if ( Angle > 292.5 ) And ( Angle <= 337.5)
            return 1
    }

    Say(direction){
        direction := RegExReplace(direction,"2","↑")
        direction := RegExReplace(direction,"3","↗")
        direction := RegExReplace(direction,"6","→")
        direction := RegExReplace(direction,"9","↘")
        direction := RegExReplace(direction,"8","↓")
        direction := RegExReplace(direction,"7","↙")
        direction := RegExReplace(direction,"4","←")
        Return direction := RegExReplace(direction,"1","↖")
    }

    ARGB_FromRGB(A,RGB){
        A := A & 0xFF, RGB := RGB & 0xFFFFFF
        return ((RGB | (A << 24)) & 0xFFFFFFFF)
    }

    Gdip_ResizeBitmap(pBitmap, PercentOrWH, Dispose=1) {	; returns resized bitmap. By Learning one.
        Gdip_GetImageDimensions(pBitmap, origW, origH)
        if PercentOrWH contains w,h
        {
            RegExMatch(PercentOrWH, "i)w(\d*)", w), RegExMatch(PercentOrWH, "i)h(\d*)", h)
            NewWidth := w1, NewHeight := h1
            NewWidth := (NewWidth = "") ? origW/(origH/NewHeight) : NewWidth
            NewHeight := (NewHeight = "") ? origH/(origW/NewWidth) : NewHeight
        }
        else {
            NewWidth := origW*PercentOrWH/100, NewHeight := origH*PercentOrWH/100		
        }
        pBitmap2 := Gdip_CreateBitmap(NewWidth, NewHeight)
        G2 := Gdip_GraphicsFromImage(pBitmap2), Gdip_SetSmoothingMode(G2, 4), Gdip_SetInterpolationMode(G2, 7)
        Gdip_DrawImage(G2, pBitmap, 0, 0, NewWidth, NewHeight)
        Gdip_DeleteGraphics(G2)
        if Dispose
            Gdip_DisposeImage(pBitmap)
        return pBitmap2
    }	; http://www.autohotkey.com/community/viewtopic.php?p=477333#p477333
}

RunWaitOne(command) {
    RunWait %comSpec% /c %command%, , hide 
    ;shell := ComObjCreate("WScript.Shell")
    ;exec := shell.Exec(ComSpec " /C " command)
    ;return exec.StdOut.ReadAll()
}