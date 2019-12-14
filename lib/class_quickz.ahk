class quickz {
    static self := new quickz.instance

    class instance {
        __new() {
            this.Plugins := {}
            this.Actions := {}
            this.UserDir := A_ScriptDir "\User"
            this.IncludeFile := this.UserDir "\include.ahk"
            this.LogFile := this.UserDir "\run.log"
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
            this.commands :=  plugin.plugin.commands
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
            if (this.menu.()) {
                menuz.FromObject(this.YamlToMenu(this.menu))
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


    LoadPlugins() {
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
        ; if (IsObject(string)) {
        ;     string := json.dump(string)
        ; }
        FileAppend, % "`n" A_YYYY "/" A_MM "/" A_DD " " A_Hour ":" A_Min ":" A_Sec " [ " string.topic " ] " string.content , % quickz.self.logFile
    }

    exit() {
        gesturez.exit()
    }
}
