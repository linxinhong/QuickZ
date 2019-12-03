class quickz {
    static self := new quickz.instance

    class instance {
        __new() {
            this.Plugins := {}
            this.Actions := {}
            this.UserDir := A_ScriptDir "\User"
            this.IncludeFile := this.UserDir "\include.ahk"
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
            this.command :=  plugin.plugin.command
            this.vimd    :=  plugin.vimd
            this.menu   :=  plugin.menu
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
                for key , value in this.var
                {
                    menuz.SetVar(key, value)
                }
                menuObject := {}
                menuz.FromObject(this.YamlToMenu(this.menu))
            }
        }

        YamlToMenu(yamlConfig) {
            menuConfig := {}
            Loop % yamlConfig.()
            {
                Item := yamlConfig.(A_Index)
                if IsObject(Item.sub) {
                    Item["Sub"] := YamlToMenu(Item.sub)
                }
                if IsObject(Item.Peer) {
                    Item["Peer"] := YamlToMenu(Item.Peer)
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

    DumpPlugins() {

    }

    InitPlugins(){
        for name, plugin in quickz.self.Plugins
        {
            plugin.Init()
            plugin.LoadVimd()
            plugin.LoadMenuZ()
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

    Comment(actionName, tipString) {
        quickz.self.Actions[actionName] := tipString
        vimd.Comment(actionName, tipString)
        menuz.SetExec(tipString, actionName)
    }
}