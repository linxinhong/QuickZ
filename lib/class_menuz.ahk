class menuz {
    static _instance = new menuz.instance()

    Config(cnf) { 
        menuz._instance.onGetClip := cnf.onGetClip
        menuz._instance.onGetWin := cnf.onGetWin
        menuz._instance.ClipUseInsert := cnf.ClipUseInsert
        menuz._instance.ClipTimeOut := cnf.ClipTimeOut ? cnf.ClipTimeOut/1000 : 0.4
    } 


    Active() {
        env := new menuz.env(menuz._instance)
        menuz._instance.envLast := env
        m := menuz._instance.createMenu()
        menuz.Build(m, menuz._instance.menuStructure, env)
        m.show(env.x, env.y)
    }

    Build(parentMenu, menuList, env) {
        Loop % menuList.MaxIndex()
        {
            item := menuList[A_Index]
            if (item.HasKey("sub") and IsObject(item["sub"])) {
                sm := menuz._instance.createMenu()
                menuz.Build(sm, item.sub, env)
                item.submenu := sm
            }
            item.filter := menuz.ReplaceVar(item.filter)
            allowAdd := true
            if ( StrLen(item.filter) ) {
                Operator := "AND"
                tagPos := 1
                Loop {
                    if (tagPos := RegExMatch(item.filter, "({[^{}]*})([\s,\|]*)", tagMatch, tagPos)) {
                        tagPos := tagPos + StrLen(tagMatch1) -1
                        tagResult := env.JudgeFilterTag(tagMatch1)
                        if (RegExMatch(tagMatch2, "^[\s,]$")) {
                            Operator := "AND"
                        }
                        else if (RegExMatch(tagMatch2, "^[\s|]$")) {
                            Operator := "OR"
                        }
                        allowAdd := Operator == "AND" ? allowAdd and tagResult : allowAdd or tagResult
                    }
                    else {
                        break
                    }
                }
            }
            if (allowAdd) {
                if (not StrLen(item.name)) {
                    parentMenu.add()
                }
                else if (not menuz.CheckDynamic(item.name, parentMenu)) {
                    item.name := menuz.ItemNameAlign(item.name)
                    item.icon := menuz.ReplaceVar(item.icon)
                    item.tcolor := menuz.ReplaceVar(item.tcolor)
                    item.bgcolor := menuz.ReplaceVar(item.bgcolor)
                    parentMenu.add(item)
                }
            }
        }
    }

    CheckDynamic(nameString, pm) {
        env := menuz._instance.envLast
        if (RegExMatch(nameString, "<([^<>]*)>", tagMatch)) {
            dynamicTarget := menuz._instance.dynamicList[tagMatch1]
            if (IsFunc(dynamicTarget)) {
                item := Func(dynamicTarget).call(env, pm)
            }
            else if (IsObject(dynamicTarget)) {
                item := dynamicTarget.call(env, pm)
            }
            else {
                return false
            }
            return true
        }
    }

    FromObject(menuObject) {
        Loop % menuObject.MaxIndex()
        {
            itemObject := menuObject[A_Index]
            if ( IsObject(itemObject.Sub) ) {
                itemObject.Sub := menuz.FromObject_Sub(itemObject.sub)
            }
            menuz.Push(menuObject[A_Index])
        }
    }

    FromObject_Sub(menuObject) {
        subMenu := {}
        Loop % menuObject.MaxIndex() 
        {
            itemObject := menuObject[A_Index]
            if ( IsObject(itemObject.Sub) ) {
                itemObject.Sub := menuz.FromObject_Sub(itemObject.sub)
            }
            subMenu.push(menuz.Sub(itemObject))
        }
        return subMenu
    }

    Push(itemConfig) {
        item := new menuz.item(itemConfig)
        menuz._instance.menuList[item.uuid] := item
        menuz._instance.menuStructure.push(item)
        return item
    }

    Sub(itemConfig) {
        item := new menuz.item(itemConfig)
        menuz._instance.menuList[item.uuid] := item
        return item
    }

    SetTag(tag, function) {
        if (IsFunc(function) or IsObject(function)) {
            menuz._instance.tagList[tag] := function
        }
        else {
            msgbox tag 映射的 %function% 函数不存在
        }
    }

    SetDynamic(tag, function) {
        if (IsFunc(function) or IsObject(function)) {
            menuz._instance.dynamicList[tag] := function
        }
        else {
            msgbox tag 映射的 %function% 函数不存在
        }
    }

    SetFilter(tag, function) {
        if (IsFunc(function) or IsObject(function)) {
            menuz._instance.filterList[tag] := function
        }
        else {
            msgbox tag 映射的 %function% 函数不存在
        }
    }

    SetVar(var, function) {
        menuz._instance.varList[var] := function
    }

    SetExec(tag, function) {
        if (IsFunc(function) or IsObject(function)) {
            menuz._instance.execList[tag] := function
        }
        else {
            msgbox tag 映射的 %function% 函数不存在
        }
    }

    Exec(event, item) {
        env := menuz._instance.envLast
        if (IsFunc(item.uuid)) {
            Func(item.uuid).call(env, event, item)
            return
        }
        else if (IsObject(item.uuid)) {
            item.uuid.call(env, event, item)
            return
        }
        itemObject := menuz._instance.menuList[item.uuid]
        command := menuz.ReplaceExec(menuz.ReplaceVar(itemObject.exec), item)
        if (StrLen(command)) {
            param := menuz.ReplaceTag(menuz.ReplaceVar(itemObject.Param))
            workdir := menuz.ReplaceTag(itemObject.workdir)
            ; msgbox %command% %param%
            Run, %command% %param%, %workdir%, UseErrorLevel, PID
            if (ErrorLevel) {
                msgbox 运行失败：%command% %param%
            }
        }
    }

    ReplaceExec(execString, item) {
        env := menuz._instance.envLast
        template := execString
        tagPos := 1
        Loop {
            if (tagPos := RegExMatch(execString, "<([^<>]*)>", tagMatch, tagPos)) {
                tagPos := tagPos + StrLen(tagMatch) -1
                if (menuz._instance.execList.HasKey(tagMatch1)) {
                    execTarget := menuz._instance.execList[tagMatch1]
                    if (IsFunc(execTarget)) {
                        repString := Func(execTarget).call(env, item)
                    }
                    else if (IsObject(execTarget)) {
                        repString := execTarget.call(env, item)
                    }
                    else {
                        repString := execTarget
                    }
                    template := StrReplace(template, tagMatch , repString)
                }
            }
            else {
                break
            }
        }
        return template
    }

    ReplaceVar(varString) {
        env := menuz._instance.envLast
        template := varString
        tagPos := 1
        Loop {
            if (tagPos := RegExMatch(varString, "%([^%]*)%", tagMatch, tagPos)) {
                tagPos := tagPos + StrLen(tagMatch) -1
                varTarget := menuz._instance.varList[tagMatch1]
                if (IsFunc(varTarget)){
                    repString := Func(varTarget).call(env)
                }
                else if (IsObject(varTarget)) {
                    repString := varTarget.call(env)
                }
                else {
                    repString := varTarget
                }
                template := StrReplace(template, tagMatch , repString)
            }
            else {
                break
            }
        }
        return template
    }

    ReplaceTag(tagString) {
        env := menuz._instance.envLast
        template := tagString
        tagPos := 1
        Loop {
            if (tagPos := RegExMatch(tagString, "{[^{}]*}", tagMatch, tagPos)) {
                tagPos := tagPos + StrLen(tagMatch) -1
                template := StrReplace(template, tagMatch, env.ConvertTag(tagMatch))
            }
            else {
                break
            }
        }
        return template
    }

    ItemNameAlign(nameString, length:=40) {
        template := nameString
        if (InStr(nameString, ">>")) {
            prefixString := RegExReplace(nameString, ">>.*")
            prefixLength := Strlen(prefixString)
            suffixString := RegExReplace(nameString, "^.*?>>")
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

    FirstMenu(env, pm) {
        nameLength := 24
        if (env.IsFile) {
            if (env.isFileMulti) {
                icon := A_WinDir "\system32\shell32.dll:54"
                FolderCount := env.fileMulti.extList["*Folder"]
                fileCount := 0
                For ext, count in env.fileMulti.extList
                {
                    if (ext == "*Folder") {
                        Continue
                    }
                    fileCount += count
                }
                name := "选中 " fileCount " 个文件,  " FolderCount " 个目录"
            }
            else {
                if (StrLen(env.file.path) > nameLength) {
                    leftString := SubStr(env.file.path, 1, nameLength/2)
                    rightString := SubStr(env.file.path, 0 - nameLength/2)
                    name := leftString " ... " rightString
                }
                else {
                    name := env.file.path
                }
                if (env.file.ext == "*Folder") {
                    icon := A_WinDir "\system32\shell32.dll:4"
                }
                else {
                    icon := menuz.GetIcon(env.file.path)
                }
            }
        }
        else if (env.IsText) {
            icon := A_WinDir "\system32\shell32.dll:267"
            if (StrLen(env.text) > nameLength) {
                leftString := SubStr(env.text, 1, nameLength/2)
                rightString := SubStr(env.text, 0 - nameLength/2)
                name := leftString " ... " rightString
            }
            else {
                name := env.text
            }
        }
        else {
            icon := env.winExeFullPath ":0"
            name := env.winTitle
        }
        item := {name: name
            ,uuid: objBindMethod(menuz, "FirstMenu_Run")
            ,icon: icon}
        pm.add(item)
        pm.add()
    }

    FirstMenu_Run(env, event, item) {
        if (env.isWin) {
            Run, % A_WinDir "\explorer.exe /select," env.winExeFullPath
        }
    }

    GetIcon(filePath) {
        /*
        Author - axlar
        url - https://autohotkey.com/board/topic/89679-why-i-use-shgetfileinfo-get-file-type-name-failed-in-ahk-h/ 
        Thansk !
        */ 
        SHGFI_TYPENAME = 0x000000400
        SHGFI_DISPLAYNAME = 0x000000200
        SHGFI_ICON = 0x000000100
        SHGFI_ATTRIBUTES = 0x000000800
        MAX_PATH := 260
        SHFILEINFO := "
        (
        INT_PTR hIcon;
        DWORD   iIcon;
        DWORD   dwAttributes;
        WCHAR   szDisplayName[" MAX_PATH "];
        WCHAR   szTypeName[80];
        )"
        SHFO := Struct(SHFILEINFO)
        DllCall("Shell32\SHGetFileInfo" . (A_IsUnicode ? "W":"A"), "str", FilePath, "uint", 0, "ptr", SHFO[""], "uint", sizeof(SHFILEINFO), "uint", SHGFI_TYPENAME|SHGFI_DISPLAYNAME|SHGFI_ICON|SHGFI_ATTRIBUTES)
        hIcon := SHFO.hIcon
        Return hIcon
    }


    Class Env {

        __new(config) {
            this.config := config

            this.isFile := false
            this.isFileMulti := false
            this.isText := false
            this.isWin := false

            this.file := {}
            this.fileMulti := {}
            this.text := ""

            this.x := 0
            this.y := 0
            this.winHwnd := 0
            this.winClass := ""
            this.winExe := ""
            this.winExeFullPath := ""
            this.winControl := ""
            this.winTitle := ""

            this.IsGetWin := false
            this.IsGetClip := false

            this.GetWinInfo()
            this.GetClip()
        }

        BreakGetClip() {
            this.IsGetClip := true
        }

        BreakGetWin() {
            this.IsGetWin := true
        }

        GetKeyword() {

        }

        GetClip() {
            if (IsFunc(this.config.onGetClip)) {
                Func(this.config.onGetClip).call(this, "GetClip")
            }
            else if (IsObject(this.config.onGetClip)) {
                this.config.onGetClip.call(this, "GetClip")
            }
            If (not this.IsGetClip) {
                clipBackup := ClipboardAll
                Clipboard := ""
                if (this.config.ClipUseInsert) {
                    SendInput, ^{Ins}
                }
                else {
                    SendINput, ^c
                }
                ClipWait, % this.config.ClipTimeOut, 1
                this.isWin := ErrorLevel
                this.isFile := DllCall("IsClipboardFormatAvailable", "UInt", 15)
                clipData := Clipboard
                Clipboard := clipBackup
                if (this.isFile) {
                    files := clipData
                    if (InStr(files, "`n")) {
                        fileList := {}
                        extList := {}
                        Loop, parse, files, `n, `r
                        {
                            fileString := A_LoopField
                            fileObject := this.GetFileObject(fileString)
                            Ext := fileObject.Ext
                            fileList[A_Index] := fileObject
                            extList[Ext] := extList[Ext] > 0 ? extList[Ext] + 1 : 1
                        }
                        this.isFileMulti := true
                        this.fileMulti.Files := files
                        this.fileMulti.FileList := fileList
                        this.fileMulti.ExtList :=  extList
                    }
                    else {
                        this.file := this.GetFileObject(files)
                    }
                }
                else if (StrLen(clipData)) {
                    this.isText := true
                    this.text := clipData
                }
            }
        }

        GetWinInfo() {
            if (IsFunc(this.config.onGetClip)) {
                Func(this.config.onGetClip).call(this, "GetWinInfo")
            }
            else if (IsObject(this.config.onGetClip)) {
                this.config.onGetClip.call(this, "GetWinInfo")
            }
            if (not this.IsGetWin) {
                MouseGetPos, _PosX, _PosY, _ID, _CTRL
                WinGetTitle, _Title, ahk_id %_ID%
                WinGetClass, _Class, ahk_id %_ID%
                WinGet, _Exe,  ProcessName, ahk_id %_ID%
                WinGet, _ExeFullPath, ProcessPath, ahk_id %_ID%
                this.x := _PosX
                this.y := _PosY
                this.winHwnd := _ID
                this.winClass := _Class
                this.winExe := _Exe
                this.winExeFullPath := _ExeFullPath
                this.winControl := _Ctrl
                this.winTitle := _Title
                this.IsGetWin := true
            }
        }

        GetFileObject(path) {
            SplitPath, path, name, dir, ext, namenoext, drive
            if (InStr(FileExist(path), "D")) {
                ext := "*Folder"
                namenoext := name
            }
            else if (not StrLen(ext)) {
                ext := "*NoExt"
            }
            fileObject := {path: path
                ,name: name
                ,dir: dir
                ,ext: ext
                ,namenoext: namenoext
                ,drive: drive}
            return fileObject
        }

        ConvertTag(tag) {
            RegExMatch(tag, "{([\w]*).*}", match)
            customizeTag := match1
            if (this.config.tagList.HasKey(customizeTag)) {
                return Func(this.config.tagList[customizeTag]).call(this, tag)
            }
            else if (RegExMatch(tag, "i)^{file:(\w*)}$", match) and this.isFile and not this.isFileMulti) {
                return this.file[match1]
            } 
            else if (RegExMatch(tag, "i)^{text}$", match) and this.isText) {
                return this.text
            } 
            else if (RegExMatch(tag, "i)^{list:(.*)}$", match) and this.isFileMulti) {
                template := match1
                if (RegExMatch(template, "\[<(\d*)]", subchar)) {
                    StringReplace, template, template, %subchar%
                }
                ListString := ""
                Loop % this.fileMulti.fileList.MaxIndex()
                {
                    fileString := template
                    fileObject := this.fileMulti.fileList[A_Index]
                    StringReplace, fileString, fileString, [Path], % fileObject.path
                    StringReplace, fileString, fileString, [name], % fileObject.name
                    StringReplace, fileString, fileString, [namenoext], % fileObject.namenoext
                    StringReplace, fileString, fileString, [ext], % fileObject.ext
                    StringReplace, fileString, fileString, [dir], % fileObject.dir
                    StringReplace, fileString, fileString, [Drive], % fileObject.drive
                    StringReplace, fileString, fileString, [cr], `n
                    StringReplace, fileString, fileString, [tab], `t
                    StringReplace, fileString, fileString, [Index], A_Index
                    ListString .= fileString
                }
                if (subchar1 > 0) {
                    ListString := SubStr(ListString, 1, StrLen(ListString) - subchar1)
                }
                return ListString
            }
        }
        /*
        ext=ahk,js
        */

        JudgeFilterTag(tag) {
            if (not RegExMatch(tag, "{([\w]*).*}", match)) {
                return true
            }
            customizeTag := match1
            if (this.config.filterList.HasKey(customizeTag)) {
                if (Func(this.config.filterList[customizeTag])) {
                    return Func(this.config.filterList[customizeTag]).call(this, tag)
                }
                else if (IsObject(this.config.filterList[customizeTag])) {
                    return this.config.filterList[customizeTag].call(this, tag)
                }
            }
            else if (RegExMatch(tag, "i)^{only:(\w*)}$", match)) {
                return (match1 == "file") ? this.isFile 
                    : ((match1 == "text") ? this.isText : false)
            }
            else if (RegExMatch(tag, "i)^{ext:(.*)}$", match)) {
                return this.RuleTest(match1, this.file.ext)
            }
            else if (RegExMatch(tag, "i)^{filename:(.*)}$", match)) {
                return this.RuleTest(match1, this.file.name)
            }
            else if (RegExMatch(tag, "i)^{dirname:(.*)}$", match)) {
                SplitPath, % this.file.dir, dirName
                return this.RuleTest(match1, dirName)
            }
            else if (RegExMatch(tag, "i)^{text:(.*)}$", match)) {
                return this.RuleTest(match1, this.text)
            }
            else if (RegExMatch(tag, "i)^{winclass:(.*)}$", match)) {
                return this.RuleTest(match1, this.winClass)
            }
            else if (RegExMatch(tag, "i)^{winexe:(.*)}$", match)) {
                return this.RuleTest(match1, this.winExe)
            }
            else if (RegExMatch(tag, "i)^{wintitle:(.*)}$", match)) {
                return this.RuleTest(match1, this.winTitle)
                return  match1
            }
            else if (RegExMatch(tag, "i)^{winctrl:(.*)}$", match)) {
                return this.RuleTest(match1, this.winControl)
            }
            else if (RegExMatch(tag, "i)^{pos:(.*)}$", match)) {
                ; {pos:x>100, y<100}
                result_x := true
                result_y := true
                if (RegExMatch(match1, "x([<>])(\d*)", xpos)) {
                   xpos_operator := xpos1
                   xpos_number := xpos2
                   result_x := (xpos_operator = ">") ? this.x > xpos_number : ( (xpos_operator = "<") ? this.x < xpos_number  : true)
                }
                if (RegExMatch(match1, "y([<>])(\d*)", ypos)) {
                   ypos_operator := ypos1
                   ypos_number := ypos2
                   result_y := (ypos_operator = ">") ? this.y > ypos_number : ( (ypos_operator = "<") ? this.y < ypos_number : true)
                }
                return result_x and result_y
            }
            else {
                return true
            }
        }

        RuleTest(ruleString, testString) {
            if (RegExMatch(ruleString, "([=!@])(.*)", expression)) {
                operator := expression1
                equation := expression2
                testString := this.ToMatch(testString)
                tomatch := "i)(^[\s,]*" testString "(?=[\s,]))|((?<=[\s,])" testString "(?=[\s,]))|((?<=[\s,])" testString "[\s,]*$)|(^[\s,]*" testString "[\s,]*$)"
                result := RegExMatch(equation, tomatch)
                return (operator == "=") ? result : (operator == "!" ? not result : (operator == "@" ? RegExMatch(testString, equation) : true))
            }
        }

        TestRule(filter, testString) {
            RegExMatch(filter, ":([^\{\}]*)}", match)
            filterString := match1
            return this.RuleTest(filterString, testString)
        }

        ToMatch(str)
        {
           str := RegExReplace(str,"\+|\?|\.|\-|\*|\{|\}|\(|\)|\||\^|\$|\[|\]|\\","\$0")
           Return RegExReplace(str,"\s","\s")
        }
    }

    class Item {

        __new(config) {
            this.uuid := uuidCreate()
            this.name := config.name
            this.icon := config.icon
            this.tcolor := config.tcolor
            this.bgcolor := config.bgcolor
            this.exec := config.exec
            this.param := config.param
            this.workdir := config.workdir
            this.filter := config.filter
            this.sub := config.sub
        }
    }

    class instance {
        __new() {
            this.menuStructure := []
            this.menuList := {}
            this.envLast := {}
            this.tagList := {}
            this.execList := {}
            this.filterList := {}
            this.varList := {}
            this.dynamicList := {}
            this.onGetClip := ""
            this.onGetWin := ""
            this.ClipUseInsert := false
            this.ClipTimeOut := 0.6
            this.Pum := new Pum(this.PumParams())
        }

        CreateMenu() {
            return this.pum.createMenu(this.PumParams())
        }

        PumParams() {
            return {"SelMethod" : "Fill"            ;item selection method, may be frame,fill
            ;,"selTColor"   : -1         ;selection text color
            ;,"selBGColor"  : -1         ;selection background color, -1 means invert current color
            ,"oninit"      : ""   ;function which will be called when any menu going to be opened
            ,"onuninit"    : ""   ;function which will be called when any menu going to be closing
            ,"onselect"    : ""   ;;function which will be called when any item selected with mouse (hovered)
            ,"onrbutton"   : ""   ;function which will be called when any item right clicked
            ,"onmbutton"   : ""   ;function which will be called when any item clicked with middle mouse button
            ,"onrun"       : objBindMethod(Menuz, "Exec")   ;function which will be called when any item clicked with left mouse button
            ,"onshow"      : ""   ;function which will be called before any menu shown using Show method
            ,"onclose"     : ""   ;function called just before quitting from Show metho
            ,"pumfont"     : ""
            ;,"mnemonicCMD" : "select"
            ;,"tcolor"      : ""   ;RGB text color of the items in the menu
            ;,"bgcolor"	    : ""   ;RGB background color of the menu
            ,"nocolors"   : 0    ;if 1, will be used default color for menu's background and item's text color
            ,"noicons"    : 0    ;if 1, icons will not be shown in the menu
            ,"notext"     : 0    ;if 1, text will not be shown for the item, should not be used with "noicons"
            ,"iconssize"  : 16   ;icon size for items
            ,"textoffset" : 5    ;between icon and item's text in pixels
            ,"maxheight"  : 0    ;height of the menu, scroll will be added if menu is bigger
            ,"xmargin"    : 3    ;margin for the left and right of item boundary
            ,"ymargin"    : 3    ;margin for the top and bottom of item boundary
            ,"textMargin" : 5 }  ;pixels amount which will be added after the text to make menu look pretty
        }

    }
}