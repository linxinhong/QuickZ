class quickz {
    static self := new quickz.instance

    class instance {
        __new() {
            debug := 1
            this.Plugins := {}
            this.Actions := {}
            this.config := {}
            this.UserDir := A_ScriptDir "\User"
            this.configFile := this.UserDir "\config.json"
            this.IncludeFile := this.UserDir "\include.ahk"
            this.LogFile := this.UserDir "\run.log"
            this.logLevel := debug
            this.ReciveMsgTimer := ""
        }
    }

    class Config {
        __new(configFile:="") {
            cf := StrLen(configfile) ? configfile : quickz.self.configFile
            if (FileExist(cf)) {
                FileRead, configString, %cf%
                configJson := json.load(configString)
                if (IsObject(configJson.menuz)) {
                    menuz.FromObject(configJson.menuz)
                }
            }
            else {
                msgbox % configFile " not exist!"
            }
        }
    }

    class Plugin {
        __new(plugin) {
            this.name    :=  plugin.plugin.name
            this.author  :=  plugin.plugin.author
            this.version :=  plugin.plugin.version
            this.info    :=  plugin.plugin.info
            this.include :=  plugin.plugin.include
            this.init    :=  plugin.plugin.init
            this.config  :=  plugin.config
            this.commands :=  plugin.commands
            this.vimd    :=  plugin.vimd
            this.menu    :=  plugin.menu
            this.gesture :=  plugin.gesture
            this.var     :=  plugin.var
            this.dir :=  ""
        }

        Init() {
            if IsFunc(this.init) {
                Func(this.init).call()
            }
            else {
                msgbox  % "插件: " this.name "`n`n初始化函数: " this.init " 无法加载"
            }
        }

        LoadVimd() {
            if (IsObject(this.vimd)) {
                vimd.SetWin(this.vimd.name, this.vimd)
                defaultMode := ""
                for modeName , mode in this.vimd.mode
                {
                    if (mode.mapnum) {
                        vimd.mapNum(this.vimd.name, modeName)
                    }
                    if (mode.default) {
                        defaultMode := modeName
                    }
                    for key, action in mode.map
                    {
                        vimd.map(this.vimd.name, modeName, key, action)
                    }
                }
                vimd.changeMode(this.vimd.name, defaultMode)
            }
        }

        LoadMenuZ() {
            if (IsObject(this.menu)) {
                menuz.FromObject(this.menu)
            }
        }


        LoadGestureZ() {
            if (IsObject(this.gesture)) {
                for name, action in this.gesture
                {
                    gesturez.add(name, action)
                    quickz.log({content: "gesture: " name " = " action, topic: "Plugin: " this.name})
                }
            }
        }

        LoadVar() {
            if (IsObject(this.var)) {
                for key , value in this.var
                {
                    menuz.SetVar(key, value)
                    quickz.log({content: "Var: " key " = " value, topic: "Plugin: " this.name})
                }
            }
        }

        LoadCommands() {
            if (IsObject(this.commands)) {
                for key , value in this.commands
                {
                    quickz.SetCommand(key, value)
                }
            }
        }

        LoadConfig() {

        }

        YamlToMenu(yamlConfig) {
            menuConfig := {}
            Loop % yamlConfig.()
            {
                Item := yamlConfig.(A_Index)
                if IsObject(Item.sub) {
                    Item["Sub"] := this.YamlToMenu(Item.sub)
                }
                if IsObject(Item.Peer) {
                    Item["Peer"] := this.YamlToMenu(Item.Peer)
                }
                menuConfig.push(Item)
            }
            return menuConfig
        }

    }

    Init() {
        menuz.self := new menuz.instance()
        vimd.self := new vimd.instance()
        gesturez.self := new gesturez.instance()
        quickz.self.config := new quickz.config()

    }

    OnWMCopyData() {
        static WM_COPYDATA := 0x4A
        INIWrite, %A_Scripthwnd%, %A_TEMP%\QZRunTime, Auto, HWND
        INIWrite, %A_ScriptFullPath%, %A_TEMP%\QZRunTime, Auto, FullPath
        OnMessage(WM_COPYDATA, objBindMethod(quickz, "ReciveWMData"))
    }

    ReciveWMData(wParam, lParam) {
        Func := objBindMethod(quickz, "ParseMessage", StrGet(NumGet(lParam + 2*A_PtrSize)))
        quickz.self.ReciveMsgTimer := Func
        Settimer, % Func , 0 ; 使用settimer运行，方便直接return一个true过去
        return True
    }

    ParseMessage(message) {
        Func := quickz.self.ReciveMsgTimer
        Settimer, % Func, off
        if (message == "reload") {
            quickz.reload()
        }
    }

    start() {
        quickz.Init()
        quickz.OnWMCopyData()
        quickz.LoadPlugins()
        quickz.InitPlugins()
    }

    reload() {
        menuz.self.menuList := {}
        menuz.self.menuStructure := []
        quickz.self.config := new quickz.config()
        quickz.InitPlugins()
    }

    SendWMData(aString, IsGUI:=False)
    {
        Prev_DetectHiddenWindows := A_DetectHiddenWindows
        Prev_TitleMatchMode := A_TitleMatchMode
        DetectHiddenWindows On
        SetTitleMatchMode 2
        If IsGUI
        {
            IniRead, nHwnd, %A_TEMP%\QZRunTime, GUI, HWND
            IniRead, FullPath, %A_TEMP%\QZRunTime, GUI, FullPath
            Param := A_Space  aString
        }
        Else
        {
            IniRead, nHwnd, %A_TEMP%\QZRunTime, Auto, HWND
            IniRead, FullPath, %A_TEMP%\QZRunTime, Auto, FullPath
            ;FullPath := A_ScriptDir "\QuickZ.ahk"
        }
        If !WinExist("ahk_id " nHwnd)
        {
            Run,%A_AhkPath% "%FullPath%" %Param%
        }
        Else
        {
            VarSetCapacity(CopyDataStruct, 3*A_PtrSize, 0)  
            SizeInBytes := (StrLen(aString) + 1) * (A_IsUnicode ? 2 : 1)
            NumPut(SizeInBytes, CopyDataStruct, A_PtrSize) 
            NumPut(&aString, CopyDataStruct, 2*A_PtrSize)
            Prev_DetectHiddenWindows := A_DetectHiddenWindows
            Prev_TitleMatchMode := A_TitleMatchMode
            SendMessage, 0x4a, 0, &CopyDataStruct,, ahk_id %nHwnd%
        }
        DetectHiddenWindows %Prev_DetectHiddenWindows%  
        SetTitleMatchMode %Prev_TitleMatchMode% 
        return ErrorLevel  
    }


    LoadPluginsyaml() {
        Loop Files, % quickz.self.UserDir "\plugin.yml", R
        {
            p := yaml(A_LoopFileFullPath)
            if IsObject(p.plugin) {
                qPlugin := new quickz.Plugin(p)
                qPlugin.dir := A_LoopFileDir
                SplitPath, A_LoopFileFullPath, , , , OutNameNoExt
                name := StrLen(p.plugin.name) ? p.plugin.name : OutNameNoExt
                quickz.self.Plugins[name] := qPlugin
            }
        }
    }

    LoadPlugins() {
        Loop Files, % quickz.self.UserDir "\plugin.json", R
        {
            p := yaml(A_LoopFileFullPath)
            FileRead, jsonString, %A_LoopFileFullPath%
            p := json.load(jsonString)
            if IsObject(p.plugin) {
                qPlugin := new quickz.Plugin(p)
                qPlugin.dir := A_LoopFileDir
                SplitPath, A_LoopFileFullPath, , , , OutNameNoExt
                name := StrLen(p.plugin.name) ? p.plugin.name : OutNameNoExt
                quickz.self.Plugins[name] := qPlugin
            }
        }
    }

    ; dump to qzp

    DumpPlugins() {

    }

    InitPlugins(){
        for name, plugin in quickz.self.Plugins
        {
            plugin.Init()
            plugin.LoadVimd()
            plugin.LoadMenuZ()
            plugin.LoadGestureZ()
            plugin.LoadVar()
        }
    }

    GenerateInclude() {
        FileEncoding, UTF-8
        if ( FileExist(quickz.self.IncludeFile) ) {
            FileDelete, % quickz.self.IncludeFile
        }
        For name, plugin in quickz.self.Plugins
        {
           FileAppend, % "#Include *i " PathAppend(plugin.dir, plugin.include) "`r`n", % quickz.self.IncludeFile
        }
    }

    SetCommand(actionName, tipString) {
        quickz.self.Actions[actionName] := tipString
        vimd.SetCommand(actionName, tipString)
        menuz.SetCommand(actionName, actionName)
    }

    log(string) {
        if (quickz.self.logLevel < 1) and (string.topic == "debug") {
            return
        }
        FileAppend, % "`n" A_YYYY "/" A_MM "/" A_DD " " A_Hour ":" A_Min ":" A_Sec " [ " string.topic " ] " string.content , % quickz.self.logFile
    }


}
