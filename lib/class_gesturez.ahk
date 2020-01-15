

class gesturez {
    static self := new gesturez.instance

    class instance {
        __new() {
            this.pr := {}
            this.gestureList := {}
            this.gestruePNGdir := A_ScriptDir "\ges\"
            this.gesturePNGSave := false
            this.showDraw := true
            this.ElapsedTime := 200
            this.OCRMode := false
            this.OCRMode_min_direction_count := 2
            this.tess := new tesseract(A_ScriptDir "\lib", "gesture", A_ScriptDir "\lib\tesseract50.dll", A_ScriptDir "\lib\leptonica1780.dll")
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
        }


    }

    add(gesName, gesAction) {
        gesturez.self.gestureList[gesName] := gesAction
    }

    DoAction(gesName) {
        if ( not gesName ) {
            return
        }
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
        a := 1
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
                WinActive("ahk_id " win)
                ElapsedTime := A_TickCount - StartTime
                if (ElapsedTime < gesturez.self.ElapsedTime) {
                    send {%A_ThisHotkey%}
                }
                if (IsDrawLine and gesturez.self.ShowDraw) {
                    GUI, gesturez:Destroy
                }
                if (IsDrawLine and gesturez.self.showDraw) {
                    Gdip_DeletePen(pPen)
                    SelectObject(hdc, obm)
                    DeleteObject(hbm)
                    DeleteDC(hdc)
                    Gdip_DeleteGraphics(G)
                }
                if (ElapsedTime >= gesturez.self.ElapsedTime) {
                    if (OCRMode) {
                        gesturez.Review()
                    }
                    else {
                        gesturez.DoAction(DirectionList)
                    }
                }
                If (gdip_Token) {
                    Gdip_Shutdown(gdip_Token)
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
                    If (gdip_Token := Gdip_Startup()) {
                        Width := A_ScreenWidth , Height := A_ScreenHeight
                        gesturez.self.pr := new gesturez.PosRecord(Width, Height)
                        if ( gesturez.self.ShowDraw ) {
                            Gui, gesturez: -Caption +E0x80000 +LastFound +OwnDialogs +Owner +AlwaysOnTop
                            Gui, gesturez: Show, NA W%Width% H%Height%
                            Gui, gesturez: Default
                            hwnd1 := WinExist()
                            hbm := CreateDIBSection(Width, Height)
                            hdc := CreateCompatibleDC()
                            obm := SelectObject(hdc, hbm)
                            G := Gdip_GraphicsFromHDC(hdc)
                            Gdip_SetSmoothingMode(G, 4)
                            pPen := Gdip_CreatePen(gesturez.ARGB_FromRGB(0xAA, 0xff), 3)
                        }
                    }
                    IsDrawLine := true
                }
                gesturez.self.pr.push(x_start, y_start, x_end, y_end)
                if (gdip_Token and gesturez.self.ShowDraw) {
                    Gdip_DrawLine(G, pPen, x_start, y_start, x_end, y_end)
                    UpdateLayeredWindow(hwnd1, hdc, 0, 0, Width, Height)
                    a += 1
                }
                x_start := x_end
                y_start := y_end
            }
            else {
                sleep 50
            }
        }
        Critical, off
    }

    Review() {
        pr := gesturez.self.pr
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
        pBitmap := Gdip_ResizeBitmap(pBitmap, "w16 h16")
        if (gesturez.self.gesturePNGSave) {
          if FileExist(gesturez.self.gestruePNGdir) {
              pfile := gesturez.self.gestruePNGdir "GestureZ" A_Now ".png"
              Gdip_SaveBitmapToFile(pBitmap, pfile)
          }
          else {
              msgbox % gesturez.self.gestruePNGdir " 目录不存在" 
          }
        }
        size := Gdip_SaveBitmapToStream(pBitmap, buffer)
        Gdip_DeletePen(pPen)
        Gdip_DisposeImage(pBitmap)
        Gdip_DeleteGraphics(G2)
        tess := gesturez.self.tess
        gestext := Trim(tess.GetTextFromPix(tess.pixReadMem(&buffer, size)), OmitChars := " `t`r`n")
        gesturez.DoAction(gestext)
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
}
