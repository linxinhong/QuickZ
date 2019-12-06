createPlugin_init() {
    menuz.SetExec("createplugin", "createplugin")
}

CreatePlugin(env, item) {
    InputBox, pluginName, 新建插件, 指定插件名称
    if (not StrLen(pluginName)) {
      return
    }
    pluginDir := A_ScriptDir "\User\" pluginName 
    ahkFilePath := PluginDir "\" pluginName ".ahk"
    ymlFilePath := PluginDir "\plugin.yml"
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
  name: ''
  version: ''
command: ''
config: ''
menu: 
var: 
  %pluginName%: ''
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
    ; yml := yaml_dump({plugin: {name: ""
    ;                , author: ""
    ;                , version: ""
    ;                , info: ""
    ;                , include: pluginName ".ahk"
    ;                , init: pluginName "_init"}
    ;         ,config: ""
    ;         ,command: ""
    ;         ,var: {pluginName: ""}
    ;         ,menu: {}
    ;         ,vimd: {name: pluginName
    ;                ,winclass: env.winclass
    ;                ,winexe: env.winexe
    ;                ,onMap: "" 
    ;                ,onChangeMode: "" 
    ;                ,onBeforeKey: "" 
    ;                ,onAfterKey: "" 
    ;                ,onBeforAction: "" 
    ;                ,onAfterAction: "" 
    ;                ,onShowTip: "" 
    ;                ,onHideTip: "" 
    ;                ,mode: {normal: {mapnum: true
    ;                                ,default: true
    ;                                ,map: ""}
    ;                       ,insert: {map: ""}}}})
    if (not FileExist(PluginDir)) {
        FileCreateDir, %PluginDir%
        FileAppend, %ahk%, %ahkFilePath%
        FileAppend, %yml%, %ymlFilePath%
    }
    else {
        msgbox % "插件：" pluginName "已经存在"
    }
}