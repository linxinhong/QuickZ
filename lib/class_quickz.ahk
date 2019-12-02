class quickz {
    static self := new quickz.instance

    class instance {
        __new() {
            this.Plugins := {}
            this.UserDir := A_ScriptDir "\User"
        }
    }

    class Plugin {
        __new(plugin) {
            this.name := plugin.name
            this.author := plugin.author
            this.version := plugin.version
            this.info := plugin.info
            this.include := plugin.include
            tihs.init := plugin.init
            this.config := plugin.config
            this.vimd := plugin.vimd
            this.menuz := plugin.menuz
        }
    }

    LoadPlugins() {
        Loop Files, % quickz.self.UserDir "\plugin.yml", R
        {
            p := yaml(A_LoopFileFullPath)
            if IsObject(p.plugin) {
                qPlugin := new quickz.Plugin(p.plugin)
                quickz.self.plugins[qPlugin.name] := qPlugin
            }
        }
    }

    DumpPlugins() {

    }

    GenerateInclude() {
        IncludeFiles := ""
    }
}