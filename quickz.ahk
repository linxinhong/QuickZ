#NoEnv 
#SingleInstance, Force
SetBatchLines, -1
SendMode Input
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Screen
SetKeyDelay, -1
SetControlDelay,-1

vimd.setWin("et", { winClass: "EVERYTHING"
                                ,winExe: "everything.exe"
                                ,onBeforeKey: "et_BeforeKey"
                                ,maxCount: 999
                                ,timeOut: 500})
vimd.mapNum("et", "normal")
vimd.map("et", "normal", "j", "down")
vimd.map("et", "normal", "k", "up")
vimd.map("et", "normal", "w", objBindMethod(menuz, "Active"))
vimd.map("et", "normal", "v1", "et_filter", "所有")
vimd.map("et", "normal", "v2", "et_filter", "音频")
vimd.map("et", "normal", "v3", "et_filter", "压缩文件")
vimd.map("et", "normal", "v4", "et_filter", "文档")
vimd.map("et", "normal", "v5", "et_filter", "可执行文件")
vimd.map("et", "normal", "v6", "et_filter", "文件夹")
vimd.map("et", "normal", "v7", "et_filter", "图片")
vimd.map("et", "normal", "v8", "et_filter", "视频")
vimd.map("et", "insert", "<esc>", "np_change_to_normal")
vimd.changeMode("et", "normal")

et_filter(win) {
    Control, Choose, % win.keyLast, ComboBox1, A
}

et_BeforeKey() {
    WinGet, MenuID, ID, AHK_CLASS #32768
    if (MenuID) {
        vimd.SendRaw("et")
    }
    ControlGetFocus, focusCtrl, A
    if (focusCtrl == "Edit1") {
        vimd.SendRaw("et")
    }
}


down() {
    send {down}
}

up() {
    send {up}
}


menuz.config({cliptimeout: 400
    ,onGetWin: ""
    ,onGetClip: "checktc"})
; menuz.SetFilter("ext", "filtertest")
; menuz.Setexec("gvim", "exectest")
menuz.settag("test", "tagtest")
menuz.setvar("gvim", "D:\Program Files (x86)\Vim\vim81\gvim.exe")
menuz.setvar("chrome", "C:\chrmoe.exe")
menuz.setvar("vscode", "D:\Program Files\Microsoft VS Code\Code.exe")
menuz.setvar("black", 0x232323)
menuz.setdynamic("firstmenu", objBindMethod(menuz, "firstmenu"))
tagtest(env, tag) {
    msgbox % tag ; {test: some}
    msgbox % env.file.name
}

checktc(env) {
    ; env.BreakGetClip()
}
filtertest(env, filter) {
    msgbox filter> %filter%
    return true
}
exectest(env, item) {
    msgbox exec
}

myMenu :=   [{name: "<firstmenu>"}
        ,{name: "gvim>>"
            ,icon: "%gvim%:0"
            ,tcolor: 0xffff
            ,bgcolor: "%black%"
            ,exec: "%gvim%"
            ,param: """{file:path}"""
            ,workdir: """{file:dir}"""
            ,filter: "{ext:=ahk, js, py}, {only:file}"}
        ,{name: "quickz-ui"
            ,icon: "%vscode%:0"
            ,exec: "%vscode%"
            ,param: """D:\git\ahk\quickz-ui"""}
        ,{name: "quickz-design"
            ,icon: "%vscode%:0"
            ,exec: "%vscode%"
            ,param: """D:\git\ahk\quickz-design"""}
        ,{ name: "父菜单1"
                ,sub:   [{name: "1"
                                ,sub: [{name: "1.1"}]}
                    ,{name: "2"}]}
        ,{ name: "父菜单2"
                ,sub:   [{name: "2.1"}]}]
menuz.FromObject(myMenu)
; msgbox % json.dump(menuz._instance.menuStructure, 2)
return
; gui, add, edit, w200 h20 , %tomatch%
; gui, add, edit, w200 h20 ,%equation%
; gui, add, button, default gRegex,正则式
; gui, show

regex:
GuiControlGet, match, , edit1
GuiControlGet, string, , edit2
result := RegExMatch(string, match, m)
msgbox % result "`n" m
return

!x::reload
!r::menuz.Active()

#include lib\class_vimd.ahk
#include lib\class_menuz.ahk
#include lib\class_json.ahk
#include lib\pum.ahk
#include lib\pum_api.ahk
#include lib\struct.ahk
#include lib\sizeof.ahk