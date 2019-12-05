#NoEnv 
#SingleInstance, Force
SetBatchLines, -1
SendMode Input
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Screen
SetKeyDelay, -1
SetControlDelay,-1

quickz.LoadPlugins()
quickz.InitPlugins()

menuz.config({cliptimeout: 400
    ,onGetWin: ""
    ,onGetClip: "myGetClip"})
menuz.SetFilter("tt", "texttype")
menuz.setexec("sendtext", "sendtext")
menuz.setexec("sendenter", "sendenter")
menuz.setexec("copynamenoext", "copynamenoext")
menuz.settag("test", "tagtest")
menuz.settag("box", "tagbox")
menuz.setdynamic("firstmenu", objBindMethod(menuz, "firstmenu"))
return


tagtest(env, tag) {
    msgbox % tag ; {test: some}
    msgbox % env.file.name
}

tagbox(env, tag)  {
    if (InStr(tag, "folder")) {
        FileSelectFolder, folderPath, , , 选择文件夹
        return folderPath
    }
}

sendtext(env, item) {
    WinActivate, % "ahk_id " env.winHwnd
    SendRaw % menuz.ReplaceTag(item.param)
}

sendenter(env, item) {
    WinActivate, % "ahk_id " env.winHwnd
    Send {enter}
}

copynamenoext(env, item) {
    clipboard := env.file.namenoext
}


myGetClip(env, event) {
    if (event == "GetClip") {
        if (env.winExe == "gvim.exe") {
            clipBackup := ClipboardAll
            Clipboard := ""
            SendRaw "+y
            ClipWait, % env.config.ClipTimeOut, 1
            env.isWin := ErrorLevel
            clipData := Clipboard
            env.isGetClip := true
            env.isText := true
            env.text := clipData
        }
    }
}

filtertest(env, filter) {
    msgbox filter> %filter%
    return true
}

exectest(env, item) {
    msgbox exec
}


TextType(env, filter) {
    textTypeName := ""
    textRegexList := {url: "(https?|ftp|file)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]"}
    for textType, TypeRegex in textRegexList
    {
        if (RegExMatch(env.text, TypeRegex)) {
            textTypeName := textType
            break
        }
    }
    return env.TestRule(filter, textTypeName)
}

return
; gui, add, edit, w200 h20 , %tomatch%
; gui, add, edit, w200 h20 ,%equation%
; gui, add, button, default gRegex,正则式
; gui, show

; regex:
; GuiControlGet, match, , edit1
; GuiControlGet, string, , edit2
; result := RegExMatch(string, match, m)
; msgbox % result "`n" m
return

!x::reload
CapsLock::menuz.Active()

#include lib\class_vimd.ahk
#include lib\class_menuz.ahk
#include lib\class_quickz.ahk
#include lib\class_json.ahk
#include lib\class_easyini.ahk
#include lib\pum.ahk
#include lib\pum_api.ahk
#include lib\struct.ahk
#include lib\sizeof.ahk
#include lib\yaml.ahk
#include lib\Path_API.ahk
#include *i user\include.ahk