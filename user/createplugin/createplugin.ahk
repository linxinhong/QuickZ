createPlugin_init() {
    menuz.SetCommand("createplugin", "createplugin")
    menuz.SetCommand("yml2json", "yml2json")
}

CreatePlugin(env, item) {
    InputBox, pluginName, 新建插件, 指定插件名称
    if (not StrLen(pluginName)) {
      return
    }
    pluginDir := A_ScriptDir "\User\" pluginName 
    ahkFilePath := PluginDir "\" pluginName ".ahk"
    ymlFilePath := PluginDir "\plugin.yml"
    changelogFilePath := PluginDir "\changelog.md"
    readmeFilePath := PluginDir "\README.md"
    winclass := env.winclass
    winexe := env.winexe
    ahk := pluginName "init() {`n`n}`n" pluginName "() {`n`n}"
    yml = 
(
plugin: 
  author: ''
  include: %pluginName%.ahk
  info: ''
  init: %pluginName%_init
  name: %pluginName%
  version: 1.0
  changelog: changelog.md
  readme: readme.md
commands: ''
config: ''
var: 
menu: 
gesture:
vimd: 
  name: %PluginName%
  winclass: %winclass%
  winexe:  %winexe%
  maxCount: 999
  timeOut: 500
  onMap: ''
  onBeforeKey: ''
  onAfterKey: ''
  onBeforAction: ''
  onAfterAction: ''
  onChangeMode: ''
  onShowTip: ''
  onHideTip: ''
  mode: 
    insert: 
      map: ''
    normal: 
      default: true
      mapnum: false
      map: ''
)
    if (not FileExist(PluginDir)) {
        FileCreateDir, %PluginDir%
        FileAppend, %ahk%, %ahkFilePath%
        FileAppend, %yml%, %ymlFilePath%
        FileAppend, %PluginName%, %readmeFilePath%
        FileAppend, 1.0, %changelogFilePath%
        run %PluginDir%
    }
    else {
        msgbox % "插件：" pluginName "已经存在"
    }
}

yml2json(env, item) {
  newJson := {}  
  yml := yaml(env.file.path)
  newJson["plugin"] := yml.plugin
  newJson["commands"] := yml.commands
  newJson["config"] := yml.config
  newJson["vars"] := yml.var
  newJson["vimd"] := yml.vimd
  newJson["gesture"] := yml.gesture
  FileAppend, % json.dump(newJson, 4), % env.file.dir "\" env.file.namenoext ".json"
}