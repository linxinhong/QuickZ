class quickz {
    static self := new quickz.instance

    class instance {
        __new() {
            this.Plugins := {}
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
            this.vimd    :=  plugin.vimd
            this.menuz   :=  plugin.menuz
            this.dir :=  ""
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
            if IsFunc(plugin.init) {
                Func(plugin.init).call()
            }
            else {
                msgbox  % "插件: " plugin.name "`n`n初始化函数: " plugin.init " 无法加载"
            }
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

}