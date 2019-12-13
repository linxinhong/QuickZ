class vimd {

    static self = new vimd.instance

    SetWin(winName, config) {
        if ( not StrLen(winName) ){
            return vimd.self.globalWin
        }
        win := new vimd.vimWin(winName, config)
        vimd.self.winList[winName] := win
        if ( strlen(config.winClass)) {
            vimd.self.winClassList[config.winClass] := win
        }
        if ( strlen(config.winExe) ) {
            vimd.self.winExeList[config.winExe] := win
        }
    }

    GetWin(winName:="") {
        if ( StrLen(winName) ) {
            return this.self.winList[winName]
        }
        else {
            return this.self.globalWin
        }
    }

    ActiveWin() {
        ActiveWin := WinExist("A")
        WinGetClass, ActiveClass, ahk_id %ActiveWin%
        WinGet, ActiveExe, ProcessName, ahk_id %ActiveWin%
        win := this.self.winClassList[ActiveClass]
        win := IsObject(win) ? win : this.self.winExeList[ActiveExe]
        return IsObject(win) ? win : this.self.globalWin
    }

    SetMode(winName, modeName) {
        win := vimd.GetWin(winName)
        mode :=  new vimd.vimMode(winName, modeName)
        mode.ownerwinClass := win.winClass
        mode.ownerwinExe := win.winExe
        win.PushMode(modeName, mode)
        return mode
    }

    GetMode(winName, modeName) {
        win := vimd.GetWin(winName)
        if (StrLen(modeName)) {
            return win.HasMode(modeName) ? win.FindMode(modeName) : vimd.SetMode(winName, modeName)
        }
    }

    ModeOn(winName, modeName) {
        mode := vimd.GetMode(winName, modeName)
        mode.on()
    }

    ModeOff(winName, modeName) {
        mode := vimd.GetMode(winName, modeName)
        mode.off()
    }

    ChangeMode(winName, modeName) {
        win := vimd.GetWin(winName)
        if (IsFunc(win.onChangeMode)) {
            Func(win.onChangeMode).call(win)
        }
        vimd.ModeOff(winName, win.modeExist)
        vimd.ModeOn(winName, modeName)
        win.modeExist := modeName
    }

    Map(winName, modeName, key, action, comment:="") {
        if (not (StrLen(modeName) or StrLen(key) or StrLen(action))) {
            msgbox % "无效映射:`nwin: " winName "`nmode: " modeName "`nkey: " key "`naction: " action
            return
        }
        win := vimd.GetWin(winName)
        if (IsFunc(win.onMap)) {
            Func(win.onMap).call(win)
        }
        keyObject := vimd.ConvertKeyObject(key)
        keyObject.action := action
        keyObject.Comment := comment
        if (keyObject.super) {
            win.SuperList[keyObject.string] := keyObject
        }
        mode := vimd.GetMode(winName, modeName)
        mode.mapPush(keyObject.string, keyObject)
        mode.mapAppend(keyObject.String)
        mode.RegisterKey(keyObject, "off")
    }

    MapNum(winName, modeName) {
        Loop 10 {
            key := A_Index - 1
            vimd.map(winName, modeName, key, "<" key ">")
        }
    }

    SendRaw(winName) {
        win := vimd.GetWin(winName)
        win.SendRawOnce := true
    }

    clear(winName) {
        win := vimd.GetWin(winName)
        win.ClaerAll()
    }

    SetCommand(actionName, tipString) {
        vimd.self.CommentList[actionName] := tipString
    }

    GetComment(actionName) {
        return vimd.self.CommentList.HasKey(actionName) ? vimd.self.CommentList[actionName] : actionName
    }

    Key() {
        win := vimd.ActiveWin()
        if (IsFunc(win.onBeforeKey)) {
            Func(win.onBeforeKey).call(win)
        }
        vimd._Key()
        if (IsFunc(win.onAfterKey)) {
            Func(win.onAfterKey).call(win)
        }
    } 

    _Key() {
        win := vimd.ActiveWin()
        mode := vimd.GetMode(win.name, win.modeExist)
        keyPress := vimd.CheckCapsLock(vimd.ConvertKeyVIM(A_ThisHotkey))
        win.keyLast := keyPress
        if (win.SendRawOnce) {
            SendInput, % vimd.ConvertKeyAHK(keyPress, toSend:=true)
            win.SendRawOnce := false
            return
        }
        keyCache := win.AppendPress(keyPress)
        if ( win.SuperList.HasKey(keyCache) ) {
            vimd.DoAction(win.SuperList[keyCache].action, 1)
            return
        }
        if (mode.HasMap(keyCache)) {
            if ( RegExMatch(mode.GetAction(keyCache), "^<(\d)>$", keyCount) and RegExMatch(keyCache, "^\d*$") ){
                win.SumCount(keyCount1)
                win.ClearCache()
                win.ShowTip(win.GetCount())
                return 
            }
            else if ( not mode.GetMore(keyCache) ) {
                vimd.DoAction(mode.GetAction(keyCache), win.GetCount())
                win.ClaerAll()
                return
            }
        }
        timerFunction := objBindMethod(vimd, "Timer", keyCache)
        if ( mode.GetMore(keyCache) ) {
            win.ShowTip(KeyCache)
            if (win.timeOut and mode.HasMap(keyCache)) {
                SetTimer, %timerFunction% , % win.timeOut
            }
        }
        else if ( mode.HasMap(keyPress) ){
            vimd.DoAction(mode.GetAction(keyPress), win.GetCount())
            win.ClaerAll()
        }
        else {
            SendInput, % vimd.ConvertKeyAHK(keyPress, toSend:=true)
        }
    }


    DoAction(actionName, count) {
        win := vimd.ActiveWin()
        if ( not win.isRepeat or not win.isRecordPlay) {
            win.SetKeyHistory(win.keyCache, actionName, count)
        }
        ;win.GetKeyHistory()
        if (IsFunc(win.onBeforeAction)) {
            Func(win.onBeforeAction).call(win)
        }
        if (count < 1) {
            count := 1
        }
        if (IsFunc(actionName)) {
            Loop %count% {
                Func(actionName).call(win)
            }
        } else if (IsLabel(actionName)) {
            Loop %count% {
                Goto, %actionName%
            }
        } else if (IsObject(actionName)) {
            Loop %count% {
                actionName.call(win)
            }
        }
        if ( win.isRepeat ) {
            win.isRepeat := false
        }
        else {
            win.SetLastAction(actionName, count)
        }
        if (IsFunc(win.onAfterAction)) {
            Func(win.onAfterAction).call(win)
        }
    }

    Repeat() {
        win := vimd.ActiveWin()
        win.isRepeat := true
        vimd.DoAction(win.LastAction.action, win.LastAction.count)
        win.isRepeat := true
    }

    Record() {
        win := vimd.ActiveWin()
        win.RecordToggle()
    }

    RecordPlay() {
        win := vimd.ActiveWin()
        record := win.RecordPlay()
        if (record.start > 0 and record.end > 0 and record.end > record.start) {
            win.isRecordPlay := true
            step := record.start
            Loop 
            {
                recordAction := win.KeyHistoryList[step]
                vimd.DoAction(recordAction.action, recordAction.count)
                step += 1
                if (step > record.end) {
                    break
                }
                ;tip .= "Action: " recordAction.action A_Tab "Count: " recordAction.count "`n"
                ;tooltip %tip%, , , 3
            }
            win.isRecordPlay := false
        }
    }

    Timer(key) {
        SetTimer, , off
        win := vimd.ActiveWin()
        mode := vimd.GetMode(win.name, win.modeExist)
        if ( StrLen(win.KeyCache) ) {
            vimd.DoAction(mode.GetAction(key), win.GetCount())
            win.HideTip()
            win.ClearCache()
            win.ClearCount()
        }
    }

    ConvertKeyObject(keyString) {
        keyString := RegExReplace(RegExReplace(RegExReplace(keyString
                , "i)<super>", "", super)
                , "i)<noWait>", "", noWait)
                , "i)<noMulti>", "", noMulti)

        keyObject := {}
        keyObject.sequence := []
        keyObject.error := []
        keyObject.string := ""
        keyObject.raw := keyString
        keyObject.super := super
        keyObject.noWait := noWait
        keyObject.noMulti := noMulti
        keyObject.action := ""
        keyObject.Comment := ""

        keyString := StrReplace(StrReplace(keyString
                       , "<", "`n<")
                       , ">", ">`n")

        seqIndex := 1
        Loop, parse, keyString, `n 
        {
            keyField := A_LoopField
            if (!StrLen(keyField)) {
                continue
            }
            if (RegExMatch(keyField, "^([A-Z])$", matchKey)) {
                StringLower, matchKey, matchKey
                keyField := "<s-" matchKey ">"
            }
            if (RegExMatch(keyField, "^<.*>$")) {
                seqKey := vimd.ConvertKeyAHK(keyField)
                if (StrLen(seqKey)) {
                    keyObject.sequence[seqIndex] := seqKey
                    keyObject.string .= keyField
                    seqIndex++
                } else {
                    keyObject.Error[seqIndex] := keyField
                }
            }
            else if ( StrLen(keyField) > 1) {
                Loop, parse, keyField
                {
                    singleKey := A_LoopField
                    seqkey := singleKey
                    if (RegExMatch(singleKey, "^[A-Z]$")) {
                        singleKey := "<s-" singleKey ">"
                        seqKey := vimd.ConvertKeyAHK(singleKey)
                    } 
                    keyObject.sequence[seqIndex] := seqKey
                    keyObject.string .= singleKey
                    seqIndex++
                }
            }
            else {
                keyObject.sequence[seqIndex] := keyField
                keyObject.string .= keyField
                seqIndex++
            }
        }
        return keyObject
    }

    ConvertKeyAHK(keyString, toSend := False) {
        ahkString := ""
        if (StrLen(vimd.self.DictVimKey[keyString])) {
            ahkString := vimd.self.DictVimKey[keyString]
            if (toSend) {
                ahkString := "{" ahkString "}"
            }
        }
        else if ( RegExMatch(keyString, "i)^<([rl]?[sacwtle])-(.*)>$", matchKey) ) {
            keyLeft := matchKey1
            keyRight := matchKey2
            if (toSend) {
                if (StrLen(vimd.self.DictAhkKey[keyRight])) {
                    keyRight := "{" keyRight "}"
                }
                ahkString := vimd.self.DictVimModifierSend[keyLeft] keyRight
            }
            else {
                ahkString := vimd.self.DictVimModifier[keyLeft] " & " keyRight
            }
        }
        ; else if ( RegExMatch(keyString, "i)^<(.*)>$", matchKey) ) {
        ;     ahkString := toSend ? "{" matchKey1 "}" : matchKey1
        ; }
        else {
            ahkString := keyString 
        }
        return ahkString
    }

    ConvertKeyVIM(keyString) {
        vimString := keyString
        if ( StrLen(vimd.self.DictAhkKey[keyString]) ) {
            vimString := vimd.self.DictAhkKey[keyString]
        }
        else if ( RegExMatch(keyString, "(.*)\s&\s(.*)", matchKey) ) {
            vimString := "<" vimd.self.DictAhkModifier[matchKey1] "-" matchKey2 ">"
        }
        return vimString
    }

    CheckCapsLock(aKey)
    {
        If GetKeyState("CapsLock","T")
        {
            If RegExMatch(aKey, "^[a-z]$")
                return "<S-" aKey ">"
            If RegExMatch(akey, "i)^<S\-([a-zA-Z])>", Match)
            {
                StringLower, aKey, Match1
                return aKey 
            }
        }
        If RegExMatch(aKey, "i)^<w\-(.*)>$", Match) && !GetKeyState("lWin", "P")
            Return Match1
        return akey
    }

    ToMatch(str)
    {
        str := RegExReplace(str,"\+|\?|\.|\-|\*|\{|\}|\(|\)|\||\^|\$|\[|\]|\\","\$0")
        Return RegExReplace(str,"\s","\s")
    }


    class instance {
        __new() {
            this.globalWin := new vimd.vimWin("global", {})
            this.winList := {}
            this.winClassList := {}
            this.winExeList := {}
            this.commentList := {}
            this.DictVimKey := {"<LButton>":"LButton", "<RButton>":"RButton", "<MButton>":"MButton"
            ,"<XButton1>":"XButton1",   "<XButton2>":"XButton2"
            ,"<WheelDown>":"WheelDown", "<WheelUp>":"WheelUp"
            ,"<WheelLeft>":"WheelLeft", "<WheelRight>":"WheelRight"
            ; 键盘控制
            ,"<CapsLock>":"CapsLock", "<Space>":"Space", "<Tab>":"Tab"
            ,"<Enter>":"Enter", "<Esc>":"Escape", "<BS>":"Backspace"
            ; Fn
            ,"<F1>":"F1","<F2>":"F2","<F3>":"F3","<F4>":"F4","<F5>":"F5","<F6>":"F6"
            ,"<F7>":"F7","<F8>":"F8","<F9>":"F9","<F10>":"F10","<F11>":"F11","<F12>":"F12"
            ; 光标控制
            ,"<ScrollLock>":"ScrollLock", "<Del>":"Del", "<Ins>":"Ins"
            ,"<Home>":"Home", "<End>":"End", "<PgUp>":"PgUp", "<PgDn>":"PgDn"
            ,"<Up>":"Up", "<Down>":"Down", "<Left>":"Left", "<Right>":"Right"
            ; 修饰键
            ,"<Lwin>":"LWin", "<Rwin>":"RWin"
            ,"<control>":"control", "<Lcontrol>":"Lcontrol", "<Rcontrol>":"Rcontrol"
            ,"<Alt>":"Alt", "<LAlt>":"LAlt", "<RAlt>":"RAlt"
            ,"<Shift>":"Shift", "<LShift>":"LShift", "<RShift>":"RShift"
            ; 特殊按键
            ,"<Insert>":"Insert", "<Ins>":"Insert"
            ,"<AppsKey>":"AppsKey", "<LT>":"<", "<RT>":">"
            ,"<PrintScreen>":"PrintScreen"
            ,"<controlBreak>":"controlBrek"}
            ; 数字小键盘暂时不支持
            ; 功能键
            this.DictVimModifier := {"S":"shift", "LS":"lshift", "RS":"rshift &"
            ,"A":"alt", "LA":"lalt", "RA":"ralt"
            ,"C":"control", "LC":"lcontrol", "RC":"rcontrol"
            ,"W":"lwin", "LW":"lwin", "RW":"lwin"
            ,"T":"tab", "L":"CapsLock", "E":"Escape"}
            this.DictVimModifierSend := {"S":"+", "LS":"+", "RS":"+"
            ,"A":"!", "LA":"!", "RA":"!"
            ,"C":"^", "LC":"^", "RC":"^"
            ,"W":"#", "LW":"#", "RW":"#"}

            this.DictAhkKey := {}
            This.DictAhkModifier := {}
            For V, A In this.DictVimKey 
            {
                this.DictAhkKey[A] := V
            }
            For V, A In This.DictVimModifier 
            {
                this.DictAhkModifier[A] := V
            }
        }
    }

    class vimWin {
        __new(winName, config) {
            this.name := winName
            this.winClass := config.winClass
            this.winExe := config.winExe
            this.superList := {}
            this.maxCount := strlen(config.maxCount) ? config.maxCount : 999
            this.timeOut := strlen(config.timeOut) ? config.timeOut : 0
            this.modeExist := ""
            this.modeList := {}
            this.keyCache := ""
            this.keyLast := ""
            this.count := 0
            this.SendRawOnce := false
            this.isRepeat := false
            this.isRecord := false
            this.isRecordPlay := false
            this.RecordName := ""
            this.RecordList := {}
            this.KeyHistoryList := {}
            this.LastAction := {}
            ; event list
            this.onMap := config.onMap
            this.onChangeMode := config.onChangeMode
            this.onBeforeKey := config.onBeforeKey
            this.onAfterKey := config.onAfterKey
            this.onBeforeAction := config.onBeforeAction
            this.onAfterAction := config.onAfterAction
            this.onShowTip := config.onShowTip
            this.onHideTip := config.onHideTip
            ; if (IsFunc(config.onInit)) {
            ;     Func(config.onInit).call(this)
            ; }
        }

        HasMode(modeName) {
            return this.modeList.HasKey(modeName)
        }

        FindMode(modeName) {
            return this.modeList[modeName]
        }

        PushMode(modeName, mode) {
            this.modeList[modeName] := mode
        }

        GetMoreList() {
            return this.modeList[this.modeExist].GetMoreList(this.keyCache)
        }

        SumCount(num) {
            this.Count := this.Count * 10 + num
            if ( this.maxCount > 0 and (this.count > this.maxCount) ) {
                this.count := this.maxCount
            }
        }

        ClaerAll() {
            this.ClearCount()
            this.ClearCache()
            this.HideTip()
        }

        ClearCount() {
            this.Count := 0
        }

        GetCount() {
            return this.Count
        }

        AppendPress(keyString) {
            this.keyCache := this.keyCache keyString
            return this.keyCache
        }

        ClearCache() {
            this.keyCache := ""
        }

        TipAlign(nameString, length:=32) {
            template := nameString
            if (InStr(nameString, "`t")) {
                prefixString := RegExReplace(nameString, "\t.*")
                prefixLength := Strlen(prefixString)
                suffixString := RegExReplace(nameString, "^.*?\t")
                suffixLength := StrLen(RegExReplace(suffixString, "&"))
                SpaceCount := length - prefixLength - suffixLength
                If SpaceCount > 0
                {
                    Loop % SpaceCount
                        Spaces .= A_Space
                    template := prefixString Spaces suffixString
                }
            }
            return template
        }
        
        ShowTip(Text) {
            if (IsFunc(this.onShowTip)) {
                Func(this.onShowTip).call(text, this)
            }
            else {
                if (StrLen(this.keyCache)) {
                    Text := this.Count ? this.Count Text : Text
                    Text := Text "`n======================`n"
                    for index , more in this.GetMoreList()
                    {
                        Text .= this.TipAlign(more.key "`t" vimd.GetComment(more.action)) "`n"
                    }
                }
                MouseGetPos, posx, posy, A
                posx += 30
                posy += 30
                Tooltip, %Text%, %posx%, %posy%
            }
        }

        HideTip() {
            if (IsFunc(this.onHideTip)) {
                Func(this.onHideTip).call(this)
            }
            else {
                Tooltip
            }
        }

        SetKeyHistory(key, action, count) {
            this.KeyHistoryList.push({key: key, action: action, count: (count < 1 ? 1 : count)})
        }

        GetKeyHistory() {
            tip := ""
            for step, history in this.KeyHistoryList
            {
                tip .= "Key: " history.key A_Tab "Action: " history.action A_Tab "Count: " history.count "`n"
            }
            tooltip %tip%, , , 2
            return tip
        }

        SetLastAction(action, count) {
            this.LastAction := {action: action, count: count}
        }

        RecordToggle() {
            if (this.isRecord) {
                this.IsRecord := false
                record := this.RecordList[this.RecordName]
                record.end := this.KeyHistoryList.MaxIndex() -1
            }
            else {
                InputBox, macroName, VimD 录制宏, 请输入宏的名称 
                this.RecordName := macroName
                record := {start: this.KeyHistoryList.MaxIndex() + 1, end: 0}
                this.RecordList[this.RecordName] := record
                this.IsRecord := true
            }
        }

        RecordList() {
        }

        RecordPlay() {
            InputBox, macroName, VimD 执行录制宏, 请输入宏的名称 
            return this.RecordList[macroName]
        }

    }

    class vimMode {

        __new(winName, modeName) {
            this.name := modeName
            this.ownerWin := winName
            this.ownerwinClass := ""
            this.ownerwinExe := ""
            this.mapList := {}
            this.mapString := "`n"
        }

        GetMap(mapString) {
            return this.mapList[mapString]
        }

        GetAction(mapString) {
            return this.mapList[mapString].action
        }

        HasMap(mapString) {
            return this.mapList.HasKey(mapString)
        }

        GetMore(keyString) {
            return RegExMatch(this.mapString, "i)\n" vimd.ToMatch(keyString) "[^\n]+")
        }

        GetMoreList(keyString) {
            moreList := []
            match := "i)^" vimd.ToMatch(keyString) ".+"
            for keyString, keyObject in this.mapList
            {
                If (RegExMatch(keyString, match)) {
                    moreList.push({key: keyString, action: (StrLen(keyObject.Comment) ? keyObject.Comment : keyObject.action)})
                }
            }
            return moreList
        }

        mapPush(mapString, keyObject) {
            this.mapList[mapString] := keyObject
        }

        mapAppend(appendString) {
            this.mapString := this.mapString appendString "`n"
        }

        RegisterKey(keyObject, ctrl:="on") {
            winClass := this.ownerwinClass
            winExe := this.ownerwinExe
            if (keyObject.super) {
                ctrl := "on"
            }
            keyFunction := objBindMethod(vimd, "key")
            Loop % keyObject.sequence.MaxIndex()
            {
                regKey := keyObject.sequence[A_Index]
                if (not StrLen(regKey)) {
                    msgbox % "映射热键失败:`n`n[程序名称]:  " this.ownerWin "`n[模式]:  " this.name "`n[热键序列]:  " keyObject.String "`n[热键]:  " keyObject.Error[A_Index] "`n`n热键序列生效，但已经忽略此热键"
                    continue
                }
                if (not StrLen(winClass winExe)) {
                    Hotkey, IfWinActive
                    Hotkey, %regKey%, %keyFunction%, %ctrl%
                }
                else {
                    if ( StrLen(winClass) ) {
                        Hotkey, IfWinActive, ahk_class %winClass%
                        Hotkey, %regKey%, %keyFunction%, %ctrl%
                    }
                    if ( StrLen(winExe) ) {
                        Hotkey, IfWinActive, ahk_exe %winExe%
                        Hotkey, %regKey%, %keyFunction%, %ctrl%
                    }
                }
            }
        }

        on() {
           for keyName, keyObject in this.mapList 
           {
               this.RegisterKey(keyObject, "on")
           }
        }

        off() {
           for keyName, keyObject in this.mapList 
           {
               this.RegisterKey(keyObject, "off")
           }
        }
    }
}

__vimd:
    vimd.key()
