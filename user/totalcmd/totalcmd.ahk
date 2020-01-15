totalcmd_Init() {
    TC_Comments()
    pluginDir := quickz.self.plugins["totalcmd"].dir
    TC.self.ini := class_easyini(pluginDir "\totalcmd.ini")
    TC.self.totalcmdPath := FileExist(tc.self.ini.totalcmd.path) ? tc.self.ini.totalcmd.path : TC.FindPath(TC.self.ini)
    TC.self.totalcmdINI := FileExist(tc.self.ini.totalcmd.ini) ? tc.self.ini.totalcmd.ini : TC.FindINI(TC.self.ini)
}

totalcmd_change_to_insert(){
    vimd.changeMode("totalcmd", "insert")
}

totalcmd_change_to_normal(){
    vimd.changeMode("totalcmd", "normal")
}

totalcmd_onBeforeKey() {
    TC.onBeforekey()
}

totalcmd_esc() {
    vimd.clear("totalcmd")
    totalcmd_change_to_normal()
    send {esc}
}

totalcmd_AZHistory() {
    TC.AZHistory()
}

class TC {
    static self := new TC.Instance

    class Instance {
        __new() {
            this.PostMsgNum := 0
            this.ListCtrlName := "TMyListBox"
            this.TCEditCtrlName := "Edit1"
            this.INI := {}
            this.totalcmdPath := ""
            this.totalcmdINI := ""
            this.history_name_obj := []
        }
    }

    FindPath(ini) {
        tcpath := ""
        Process, Exist, totalcmd.exe
        if (ErrorLevel) {
            WinGet, TCPath32, ProcessPath, ahk_pid %ErrorLevel%
        } 
        Process, Exist, totalcmd64.exe
        if (ErrorLevel) {
            WinGet, TCPath64, ProcessPath, ahk_pid %ErrorLevel%
        }
        tcpath := FileExist(TCPath32) ? TCPath32 : FileExist(TCPath64) ? TCPath64 : false
        if (not tcpath) {
            FileSelectFile, tcpath, S1, , 请选择TC所在的路径,  totalcmd.exe; totalcmd64.exe
        }
        if (FileExist(tcpath)) {
            if (IsObject(ini.totalcmd)) {
                ini.totalcmd.path := tcpath
            }
            else {
                ini.totalcmd := {path: tcpath}
            }
            ini.save()
            return tcpath
        }
    }

    FindINI(ini) {
        tcini := ""
        if (FileExist(tc.self.totalcmdPath)) {
            SplitPath, % tc.self.totalcmdPath, , tcdir
            tcini := tcdir "\wincmd.ini"
        }
        if (not FileExist(tcini)) {
            FileSelectFile, tcini, S1, , 请选择TC的配置文件,  wincmd.ini; *.ini
        }
        if (FileExist(tcini)) {
            if (IsObject(ini.totalcmd)) {
                ini.totalcmd.ini := tcini
            }
            else {
                ini.totalcmd := {ini: tcini}
            }
            ini.save()
            return tcini
        }
    }

    SendPos(Number){
        TC.self.PostMsgNum := Number
        PostMessage 1075, %Number%, 0, , AHK_CLASS TTOTAL_CMD
    }

    onBeforekey() {
        WinGet, MenuID, ID, AHK_CLASS #32768
        if MenuID And (TC.self.PostMsgNum <> 572)
            vimd.SendRaw("totalcmd")
        ControlGetFocus, ctrl, AHK_CLASS TTOTAL_CMD
        if ( not InStr(ctrl, TC.self.ListCtrlName)) {
            vimd.SendRaw("totalcmd")
        }
    }

    LeftRight(){
        location := 0
        ControlGetPos, x1, y1, , , %TCPanel1%, AHK_CLASS TTOTAL_CMD
        if x1 > %y1%
            location += 2
        ControlGetFocus, TLB, ahk_class TTOTAL_CMD
        ControlGetPos, x2, y2, wn, , %TLB%, ahk_class TTOTAL_CMD
        if location{
            if x1 > %x2%
                location += 1
        }else {
            if y1 > %y2%
                location += 1
        }
        return location
    }

    AZHistory() {
        ini := tc.self.ini
        tcpath := tc.self.totalcmdPath
        tcini := tc.self.totalcmdINI
        cm_ConfigSaveDirHistory()
        sleep, 200
        history := ""
        if Mod(TC.LeftRight(), 2) {
            f := ini.redirect.LeftHistory
            if FileExist(f)
                IniRead, history, %f%, LeftHistory
            else
                IniRead, history, %TCINI%, LeftHistory
            if RegExMatch(history, "RedirectSection=(.+)", HistoryRedirect) {
                StringReplace, HistoryRedirect1, HistoryRedirect1, `%COMMANDER_PATH`%, %TCPath%\..
                IniRead, history, %HistoryRedirect1%, LeftHistory
            }
        } else  {
            f := ini.redirect.RightHistory
            if FileExist(f)
                IniRead, history, %f%, RightHistory
            else
                IniRead, history, %TCINI%, RightHistory
            if RegExMatch(history, "RedirectSection=(.+)", HistoryRedirect) {
                StringReplace, HistoryRedirect1, HistoryRedirect1, `%COMMANDER_PATH`%, %TCPath%\..
                IniRead, history, %HistoryRedirect1%, RightHistory
            }
        }
        ;MsgBox, %f%_%TCINI%_%history%
        history_obj := []
        TC.self.history_name_obj := []
        Loop, Parse, history, `n
            max := A_index
        Loop, Parse, history, `n
        {
            idx := RegExReplace(A_LoopField, "=.*$")
            value := RegExReplace(A_LoopField, "^\d\d?=")
            ;避免&被识别成快捷键
            name := StrReplace(value, "&", ":＆:")
            ;~ name := "(&"  chr(idx+65) ")  " . name
            if RegExMatch(Value, "::\{20D04FE0\-3AEA\-1069\-A2D8\-08002B30309D\}\|")  {
                name  := RegExReplace(Value, "::\{20D04FE0\-3AEA\-1069\-A2D8\-08002B30309D\}\|")
                value := 2122
            }
            if RegExMatch(Value, "::\|") {
                name  := RegExReplace(Value, "::\|")
                value := 2121
            }
            if RegExMatch(Value, "::\{21EC2020\-3AEA\-1069\-A2DD\-08002B30309D\}\\::\{2227A280\-3AEA\-1069\-A2DE\-08002B30309D\}\|")  {
                name  :=  RegExReplace(Value, "::\{21EC2020\-3AEA\-1069\-A2DD\-08002B30309D\}\\::\{2227A280\-3AEA\-1069\-A2DE\-08002B30309D\}\|")
                value := 2126
            }
            if RegExMatch(Value, "::\{208D2C60\-3AEA\-1069\-A2D7\-08002B30309D\}\|") { ;NothingIsBig的是XP系统，网上邻居是这个调整
                name := RegExReplace(Value, "::\{208D2C60\-3AEA\-1069\-A2D7\-08002B30309D\}\|")
                value := 2125
            }
            if RegExMatch(Value, "::\{F02C1A0D\-BE21\-4350\-88B0\-7367FC96EF3C\}\|"){
                name := RegExReplace(Value, "::\{F02C1A0D\-BE21\-4350\-88B0\-7367FC96EF3C\}\|")
                value := 2125
            }
            if RegExMatch(Value, "::\{26EE0668\-A00A\-44D7\-9371\-BEB064C98683\}\\0\|"){
                name := RegExReplace(Value, "::\{26EE0668\-A00A\-44D7\-9371\-BEB064C98683\}\\0\|")
                value := 2123
            }
            if RegExMatch(Value, "::\{645FF040\-5081\-101B\-9F08\-00AA002F954E\}\|"){
                name := RegExReplace(Value, "::\{645FF040\-5081\-101B\-9F08\-00AA002F954E\}\|")
                value := 2127
            }
            name .= A_Tab "[&"  chr(idx+65) "]"
            history_obj[idx] := name
            TC.self.history_name_obj[name] := value
        }
        Menu, az, UseErrorLevel
        Menu, az, add
        Menu, az, deleteall
        size := TCConfig.GetValue("TotalCommander_Config", "MenuIconSize")
        if not size
            size := 20
        Loop, %max%
        {
            idx := A_Index - 1
            name := history_obj[idx]
            Menu, az, Add, %name%, TC_MenuHalder_azHistorySelect
            Menu, az, icon, %name%, %A_ScriptDir%\Lib\a-zhistory.icl, %A_Index%, %size%
        }
        ControlGetFocus, TLB, ahk_class TTOTAL_CMD
        ControlGetPos, xn, yn, wn, , %TLB%, ahk_class TTOTAL_CMD
        Menu, az, show, %xn%, %yn%
        return
        
        TC_MenuHalder_azHistorySelect:
            ;~ TC_azHistorySelect()
            TCEdit := TC.self.TCEditCtrlName
            if ( TC.self.history_name_obj[A_ThisMenuItem] = 2122 ) or RegExMatch(A_ThisMenuItem, "::\{20D04FE0\-3AEA\-1069\-A2D8\-08002B30309D\}")
                cm_OpenDrives()
            else if ( TC.self.history_name_obj[A_ThisMenuItem] = 2121 ) or RegExMatch(A_ThisMenuItem, "::(?!\{)")
                cm_OpenDesktop()
            else if ( TC.self.history_name_obj[A_ThisMenuItem] = 2126 ) or RegExMatch(A_ThisMenuItem, "::\{21EC2020\-3AEA\-1069\-A2DD\-08002B30309D\}\\::\{2227A280\-3AEA\-1069\-A2DE\-08002B30309D\}")
                cm_OpenPrinters()
            else if ( TC.self.history_name_obj[A_ThisMenuItem] = 2125 ) or RegExMatch(A_ThisMenuItem, "::\{F02C1A0D\-BE21\-4350\-88B0\-7367FC96EF3C\}") or RegExMatch(A_ThisMenuItem, "::\{208D2C60\-3AEA\-1069\-A2D7\-08002B30309D\}\|") ;NothingIsBig的是XP系统，网上邻居是这个调整
                cm_OpenNetwork()
            else if ( TC.self.history_name_obj[A_ThisMenuItem] = 2123 ) or RegExMatch(A_ThisMenuItem, "::\{26EE0668\-A00A\-44D7\-9371\-BEB064C98683\}\\0")
                cm_OpenControls()
            else if ( TC.self.history_name_obj[A_ThisMenuItem] = 2127 ) or RegExMatch(A_ThisMenuItem, "::\{645FF040\-5081\-101B\-9F08\-00AA002F954E\}")
                cm_OpenRecycled()
            else {
                ThisMenuItem := RegExReplace(A_ThisMenuItem, "\t.*$")
                ThisMenuItem := StrReplace(ThisMenuItem, ":＆:", "&")            
                ControlSetText, %TCEdit%, cd %ThisMenuItem%, ahk_class TTOTAL_CMD
                ControlSend, %TCEdit%, {enter}, ahk_class TTOTAL_CMD
                ControlGetFocus, Ctrl, AHK_CLASS TTOTAL_CMD
                Postmessage, 0x19E, 1, 1, %Ctrl%, AHK_CLASS TTOTAL_CMD
            }
        return
    }
}


TC_Comments() {
    quickz.SetCommand("totalcmd_change_to_normal", "TC_VIM: 返回正常模式")
    quickz.SetCommand("totalcmd_change_to_insert", "TC_VIM: 进入插入模式")
    ; quickz.SetCommand("TC_ToggleTC", "TC_VIM: 打开/激活TC")
    ; quickz.SetCommand("TC_FocusTCCmd", "TC_VIM: 激活TC，定位到命令行")
    quickz.SetCommand("totalcmd_azHistory", "TC_VIM: a-z历史导航")
    ; quickz.SetCommand("TC_DownSelect", "TC_VIM: 向下选择")
    ; quickz.SetCommand("TC_UpSelect", "TC_VIM: 向上选择")
    ; quickz.SetCommand("TC_Mark", "TC_VIM: 标记功能")
    ; quickz.SetCommand("TC_ForceDelete", "TC_VIM: 强制删除")
    ; quickz.SetCommand("TC_ListMark", "TC_VIM: 显示标记")
    ; quickz.SetCommand("TC_Toggle_50_100Percent", "TC_VIM: 切换当前窗口显示状态50%~100%")
    ; quickz.SetCommand("TC_Toggle_50_100Percent_V", "TC_VIM: 切换当前（纵向）窗口显示状态50%~100%")
    ; quickz.SetCommand("TC_WinMaxLeft", "TC_VIM: 最大化左侧窗口")
    ; quickz.SetCommand("TC_WinMaxRight", "TC_VIM: 最大化右侧窗口")
    ; quickz.SetCommand("TC_GoLastTab", "TC_VIM: 切换到最后一个标签")
    ; quickz.SetCommand("TC_CopyNameOnly", "TC_VIM: 只复制文件名，不含扩展名")
    ; quickz.SetCommand("TC_GotoLine", "TC_VIM: 移动到(count]行，默认第一行")
    ; quickz.SetCommand("TC_LastLine", "TC_VIM: 移动到(count]行，默认最后一行")
    ; quickz.SetCommand("TC_Half", "TC_VIM: 移动到窗口中间行")
    ; quickz.SetCommand("TC_CreateNewFile", "TC_VIM: 文件模板")
    ; quickz.SetCommand("TC_GoToParentEx", "TC_VIM: 返回到上层文件夹，可返回到我的电脑")
    ; quickz.SetCommand("TC_AlwayOnTop", "TC_VIM: 设置TC顶置")
    ; quickz.SetCommand("TC_OpenDriveThis", "TC_VIM: 打开驱动器列表:本侧")
    ; quickz.SetCommand("TC_OpenDriveThat", "TC_VIM: 打开驱动器列表:另侧")
    ; quickz.SetCommand("TC_MoveDirectoryHotlist", "TC_VIM: 移动到常用文件夹")
    ; quickz.SetCommand("TC_CopyDirectoryHotlist", "TC_VIM: 复制到常用文件夹")
    ; quickz.SetCommand("TC_GotoPreviousDirOther", "TC_VIM: 后退另一侧")
    ; quickz.SetCommand("TC_GotoNextDirOther", "TC_VIM: 前进另一侧")
    ; quickz.SetCommand("TC_SearchMode", "TC_VIM: 连续搜索")
    ; quickz.SetCommand("TC_CopyUseQueues", "TC_VIM: 无需确认，使用队列拷贝文件至另一窗口")
    ; quickz.SetCommand("TC_MoveUseQueues", "TC_VIM: 无需确认，使用队列移动文件至另一窗口")
    ; quickz.SetCommand("TC_ViewFileUnderCursor", "TC_VIM: 使用查看器打开光标所在文件(shift+f3")
    ; quickz.SetCommand("TC_OpenWithAlternateViewer", "TC_VIM: 使用外部查看器打开(alt+f3")
    ; quickz.SetCommand("TC_ToggleShowInfo", "TC_VIM: 显示/隐藏 按键提示")
    ; quickz.SetCommand("TC_ToggleMenu", "TC_VIM: 显示/隐藏: 菜单栏")
    ; quickz.SetCommand("TC_SuperReturn", "TC_VIM: 同回车键，但定位到第一个文件")
    ; quickz.SetCommand("TC_FileCopyForBak", "TC_VIM: 将当前光标下的文件复制一份作为作为备份")
    ; quickz.SetCommand("TC_FileMoveForBak", "TC_VIM: 将当前光标下的文件重命名为备份")
    ; quickz.SetCommand("TC_MultiFilePersistOpen", "TC_VIM: 多个文件一次性连续打开")
    ; quickz.SetCommand("TC_CopyFileContents", "TC_VIM: 不打开文件就复制文件内容")
    ; quickz.SetCommand("TC_OpenDirAndPaste", "TC_VIM: 不打开目录，直接把复制的文件贴进去")
    ; quickz.SetCommand("TC_MoveSelectedFilesToPrevFolder", "TC_VIM: 将当前文件夹下的选定文件移动到上层目录中")
    ; quickz.SetCommand("TC_MoveAllFilesToPrevFolder", "TC_VIM: 将当前文件夹下的全部文件移动到上层目录中")
    ; quickz.SetCommand("TC_SrcQuickViewAndTab", "TC_VIM: 预览文件时,光标自动移到对侧窗口里")
    ; quickz.SetCommand("TC_CreateFileShortcut", "TC_VIM: 创建当前光标下文件的快捷方式")
    ; quickz.SetCommand("TC_CreateFileShortcutToDesktop", "TC_VIM: 创建当前光标下文件的快捷方式并发送到桌面")
    ; quickz.SetCommand("TC_CreateFileShortcutToStartup", "TC_VIM: 创建当前光标下文件的快捷方式并发送到启动文件里")
    ; quickz.SetCommand("TC_FilterSearchFNsuffix_exe", "TC_VIM: 在当前目录里快速过滤exe扩展名的文件")
    ; quickz.SetCommand("TC_TwoFileExchangeName", "TC_VIM: 两个文件互换文件名")
    ; quickz.SetCommand("TC_SelectCmd", "TC_VIM: 选择命令来执行")
    ; quickz.SetCommand("TC_MarkFile", "TC_VIM: 标记文件，将文件注释改成m")
    ; quickz.SetCommand("TC_UnMarkFile", "TC_VIM: 取消文件标记，将文件注释清空")
    ; quickz.SetCommand("TC_ClearTitle", "TC_VIM: 将TC标题栏字符串设置为空")
    ; quickz.SetCommand("TC_ReOpenTab", "TC_VIM: 重新打开之前关闭的标签页")
    ; quickz.SetCommand("TC_OpenDirsInFile", "TC_VIM: 将光标所在的文件内容中的文件夹在新标签页依次打开")
    ; quickz.SetCommand("TC_CreateBlankFile", "TC_VIM: 创建空文件")
    ; quickz.SetCommand("TC_PasteFileEx", "TC_VIM: 粘贴文件，如果光标下为目录则粘贴进该目录")
    quickz.SetCommand("cm_SrcComments", "TC_来源窗口: 显示文件备注")
    quickz.SetCommand("cm_SrcShort", "TC_来源窗口: 列表")
    quickz.SetCommand("cm_SrcLong", "TC_来源窗口: 详细信息")
    quickz.SetCommand("cm_SrcTree", "TC_来源窗口: 文件夹树")
    quickz.SetCommand("cm_SrcQuickview", "TC_来源窗口: 快速查看")
    quickz.SetCommand("cm_VerticalPanels", "TC_来源窗口: 纵向/横向排列")
    quickz.SetCommand("cm_SrcQuickInternalOnly", "TC_来源窗口: 快速查看(不用插件")
    quickz.SetCommand("cm_SrcHideQuickview", "TC_来源窗口: 关闭快速查看窗口")
    quickz.SetCommand("cm_SrcExecs", "TC_来源窗口: 可执行文件")
    quickz.SetCommand("cm_SrcAllFiles", "TC_来源窗口: 所有文件")
    quickz.SetCommand("cm_SrcUserSpec", "TC_来源窗口: 上次选中的文件")
    quickz.SetCommand("cm_SrcUserDef", "TC_来源窗口: 自定义类型")
    quickz.SetCommand("cm_SrcByName", "TC_来源窗口: 按文件名排序")
    quickz.SetCommand("cm_SrcByExt", "TC_来源窗口: 按扩展名排序")
    quickz.SetCommand("cm_SrcBySize", "TC_来源窗口: 按大小排序")
    quickz.SetCommand("cm_SrcByDateTime", "TC_来源窗口: 按日期时间排序")
    quickz.SetCommand("cm_SrcUnsorted", "TC_来源窗口: 不排序")
    quickz.SetCommand("cm_SrcNegOrder", "TC_来源窗口: 反向排序")
    quickz.SetCommand("cm_SrcOpenDrives", "TC_来源窗口: 打开驱动器列表")
    quickz.SetCommand("cm_SrcThumbs", "TC_来源窗口: 缩略图")
    quickz.SetCommand("cm_SrcCustomViewMenu", "TC_来源窗口: 自定义视图菜单")
    quickz.SetCommand("cm_SrcPathFocus", "TC_来源窗口: 焦点置于路径上")
    quickz.SetCommand("cm_LeftComments", "TC_左窗口: 显示文件备注")
    quickz.SetCommand("cm_LeftShort", "TC_左窗口: 列表")
    quickz.SetCommand("cm_LeftLong", "TC_左窗口: 详细信息")
    quickz.SetCommand("cm_LeftTree", "TC_左窗口: 文件夹树")
    quickz.SetCommand("cm_LeftQuickview", "TC_左窗口: 快速查看")
    quickz.SetCommand("cm_LeftQuickInternalOnly", "TC_左窗口: 快速查看(不用插件")
    quickz.SetCommand("cm_LeftHideQuickview", "TC_左窗口: 关闭快速查看窗口")
    quickz.SetCommand("cm_LeftExecs", "TC_左窗口: 可执行文件")
    quickz.SetCommand("cm_LeftAllFiles", "TC_左窗口: 所有文件")
    quickz.SetCommand("cm_LeftUserSpec", "TC_左窗口: 上次选中的文件")
    quickz.SetCommand("cm_LeftUserDef", "TC_左窗口: 自定义类型")
    quickz.SetCommand("cm_LeftByName", "TC_左窗口: 按文件名排序")
    quickz.SetCommand("cm_LeftByExt", "TC_左窗口: 按扩展名排序")
    quickz.SetCommand("cm_LeftBySize", "TC_左窗口: 按大小排序")
    quickz.SetCommand("cm_LeftByDateTime", "TC_左窗口: 按日期时间排序")
    quickz.SetCommand("cm_LeftUnsorted", "TC_左窗口: 不排序")
    quickz.SetCommand("cm_LeftNegOrder", "TC_左窗口: 反向排序")
    quickz.SetCommand("cm_LeftOpenDrives", "TC_左窗口: 打开驱动器列表")
    quickz.SetCommand("cm_LeftPathFocus", "TC_左窗口: 焦点置于路径上")
    quickz.SetCommand("cm_LeftDirBranch", "TC_左窗口: 展开所有文件夹")
    quickz.SetCommand("cm_LeftDirBranchSel", "TC_左窗口: 只展开选中的文件夹")
    quickz.SetCommand("cm_LeftThumbs", "TC_窗口: 缩略图")
    quickz.SetCommand("cm_LeftCustomViewMenu", "TC_窗口: 自定义视图菜单")
    quickz.SetCommand("cm_RightComments", "TC_右窗口: 显示文件备注")
    quickz.SetCommand("cm_RightShort", "TC_右窗口: 列表")
    quickz.SetCommand("cm_RightLong", "TC_右窗口: 详细信息")
    quickz.SetCommand("cm_RightTree", "TC_右窗口: 文件夹树")
    quickz.SetCommand("cm_RightQuickvie", "TC_右窗口: 快速查看")
    quickz.SetCommand("cm_RightQuickInternalOnl", "TC_右窗口: 快速查看(不用插件")
    quickz.SetCommand("cm_RightHideQuickvie", "TC_右窗口: 关闭快速查看窗口")
    quickz.SetCommand("cm_RightExec", "TC_右窗口: 可执行文件")
    quickz.SetCommand("cm_RightAllFile", "TC_右窗口: 所有文件")
    quickz.SetCommand("cm_RightUserSpe", "TC_右窗口: 上次选中的文件")
    quickz.SetCommand("cm_RightUserDe", "TC_右窗口: 自定义类型")
    quickz.SetCommand("cm_RightByNam", "TC_右窗口: 按文件名排序")
    quickz.SetCommand("cm_RightByEx", "TC_右窗口: 按扩展名排序")
    quickz.SetCommand("cm_RightBySiz", "TC_右窗口: 按大小排序")
    quickz.SetCommand("cm_RightByDateTim", "TC_右窗口: 按日期时间排序")
    quickz.SetCommand("cm_RightUnsorte", "TC_右窗口: 不排序")
    quickz.SetCommand("cm_RightNegOrde", "TC_右窗口: 反向排序")
    quickz.SetCommand("cm_RightOpenDrives", "TC_右窗口: 打开驱动器列表")
    quickz.SetCommand("cm_RightPathFocu", "TC_右窗口: 焦点置于路径上")
    quickz.SetCommand("cm_RightDirBranch", "TC_右窗口: 展开所有文件夹")
    quickz.SetCommand("cm_RightDirBranchSel", "TC_右窗口: 只展开选中的文件夹")
    quickz.SetCommand("cm_RightThumb", "TC_右窗口: 缩略图")
    quickz.SetCommand("cm_RightCustomViewMen", "TC_右窗口: 自定义视图菜单")
    quickz.SetCommand("cm_List", "TC_文件操作: 查看(用查看程序")
    quickz.SetCommand("cm_ListInternalOnly", "TC_文件操作: 查看(用查看程序, 但不用插件/多媒体")
    quickz.SetCommand("cm_Edit", "TC_文件操作: 编辑")
    quickz.SetCommand("cm_Copy", "TC_文件操作: 复制")
    quickz.SetCommand("cm_CopySamepanel", "TC_文件操作: 复制到当前窗口")
    quickz.SetCommand("cm_CopyOtherpanel", "TC_文件操作: 复制到另一窗口(F5")
    quickz.SetCommand("cm_RenMov", "TC_文件操作: 重命名/移动")
    quickz.SetCommand("cm_MkDir", "TC_文件操作: 新建文件夹")
    quickz.SetCommand("cm_Delete", "TC_文件操作: 删除")
    quickz.SetCommand("cm_TestArchive", "TC_文件操作: 测试压缩包")
    quickz.SetCommand("cm_PackFiles", "TC_文件操作: 压缩文件")
    quickz.SetCommand("cm_UnpackFiles", "TC_文件操作: 解压文件")
    quickz.SetCommand("cm_RenameOnly", "TC_文件操作: 重命名(Shift+F6")
    quickz.SetCommand("cm_RenameSingleFile", "TC_文件操作: 重命名当前文件")
    quickz.SetCommand("cm_MoveOnly", "TC_文件操作: 移动到另一个窗口(F6")
    quickz.SetCommand("cm_Properties", "TC_文件操作: 显示属性")
    quickz.SetCommand("cm_CreateShortcut", "TC_文件操作: 创建快捷方式")
    quickz.SetCommand("cm_Return", "TC_文件操作: 模仿按 ENTER 键")
    quickz.SetCommand("cm_OpenAsUser", "TC_文件操作: 以其他用户身份运行光标处的程序")
    quickz.SetCommand("cm_Split", "TC_文件操作: 分割文件")
    quickz.SetCommand("cm_Combine", "TC_文件操作: 合并文件")
    quickz.SetCommand("cm_Encode", "TC_文件操作: 编码文件(MIME/UUE/XXE 格式")
    quickz.SetCommand("cm_Decode", "TC_文件操作: 解码文件(MIME/UUE/XXE/BinHex 格式")
    quickz.SetCommand("cm_CRCcreate", "TC_文件操作: 创建校验文件")
    quickz.SetCommand("cm_CRCcheck", "TC_文件操作: 验证校验和")
    quickz.SetCommand("cm_SetAttrib", "TC_文件操作: 更改属性")
    quickz.SetCommand("cm_Config", "TC_配置: 布局")
    quickz.SetCommand("cm_DisplayConfig", "TC_配置: 显示")
    quickz.SetCommand("cm_IconConfig", "TC_配置: 图标")
    quickz.SetCommand("cm_FontConfig", "TC_配置: 字体")
    quickz.SetCommand("cm_ColorConfig", "TC_配置: 颜色")
    quickz.SetCommand("cm_ConfTabChange", "TC_配置: 制表符")
    quickz.SetCommand("cm_DirTabsConfig", "TC_配置: 文件夹标签")
    quickz.SetCommand("cm_CustomColumnConfig", "TC_配置: 自定义列")
    quickz.SetCommand("cm_CustomColumnDlg", "TC_配置: 更改当前自定义列")
    quickz.SetCommand("cm_LanguageConfig", "TC_配置: 语言")
    quickz.SetCommand("cm_Config2", "TC_配置: 操作方式")
    quickz.SetCommand("cm_EditConfig", "TC_配置: 编辑/查看")
    quickz.SetCommand("cm_CopyConfig", "TC_配置: 复制/删除")
    quickz.SetCommand("cm_RefreshConfig", "TC_配置: 刷新")
    quickz.SetCommand("cm_QuickSearchConfig", "TC_配置: 快速搜索")
    quickz.SetCommand("cm_FtpConfig", "TC_配置: FTP")
    quickz.SetCommand("cm_PluginsConfig", "TC_配置: 插件")
    quickz.SetCommand("cm_ThumbnailsConfig", "TC_配置: 缩略图")
    quickz.SetCommand("cm_LogConfig", "TC_配置: 日志文件")
    quickz.SetCommand("cm_IgnoreConfig", "TC_配置: 隐藏文件")
    quickz.SetCommand("cm_PackerConfig", "TC_配置: 压缩程序")
    quickz.SetCommand("cm_ZipPackerConfig", "TC_配置: ZIP 压缩程序")
    quickz.SetCommand("cm_Confirmation", "TC_配置: 其他/确认")
    quickz.SetCommand("cm_ConfigSavePos", "TC_配置: 保存位置")
    quickz.SetCommand("cm_ButtonConfig", "TC_配置: 更改工具栏")
    quickz.SetCommand("cm_ConfigSaveSettings", "TC_配置: 保存设置")
    quickz.SetCommand("cm_ConfigChangeIniFiles", "TC_配置: 直接修改配置文件")
    quickz.SetCommand("cm_ConfigSaveDirHistory", "TC_配置: 保存文件夹历史记录")
    quickz.SetCommand("cm_ChangeStartMenu", "TC_配置: 更改开始菜单")
    quickz.SetCommand("cm_NetConnect", "TC_网络: 映射网络驱动器")
    quickz.SetCommand("cm_NetDisconnect", "TC_网络: 断开网络驱动器")
    quickz.SetCommand("cm_NetShareDir", "TC_网络: 共享当前文件夹")
    quickz.SetCommand("cm_NetUnshareDir", "TC_网络: 取消文件夹共享")
    quickz.SetCommand("cm_AdministerServer", "TC_网络: 显示系统共享文件夹")
    quickz.SetCommand("cm_ShowFileUser", "TC_网络: 显示本地文件的远程用户")
    quickz.SetCommand("cm_GetFileSpace", "TC_其他: 计算占用空间")
    quickz.SetCommand("cm_VolumeId", "TC_其他: 设置卷标")
    quickz.SetCommand("cm_VersionInfo", "TC_其他: 版本信息")
    quickz.SetCommand("cm_ExecuteDOS", "TC_其他: 打开命令提示符窗口")
    quickz.SetCommand("cm_CompareDirs", "TC_其他: 比较文件夹")
    quickz.SetCommand("cm_CompareDirsWithSubdirs", "TC_其他: 比较文件夹(同时标出另一窗口没有的子文件夹")
    quickz.SetCommand("cm_ContextMenu", "TC_其他: 显示快捷菜单")
    quickz.SetCommand("cm_ContextMenuInternal", "TC_其他: 显示快捷菜单(内部关联")
    quickz.SetCommand("cm_ContextMenuInternalCursor", "TC_其他: 显示光标处文件的内部关联快捷菜单")
    quickz.SetCommand("cm_ShowRemoteMenu", "TC_其他: 媒体中心遥控器播放/暂停键快捷菜单")
    quickz.SetCommand("cm_SyncChangeDir", "TC_其他: 两边窗口同步更改文件夹")
    quickz.SetCommand("cm_EditComment", "TC_其他: 编辑文件备注")
    quickz.SetCommand("cm_FocusLeft", "TC_其他: 光标置于左窗口")
    quickz.SetCommand("cm_FocusRight", "TC_其他: 光标置于右窗口")
    quickz.SetCommand("cm_FocusCmdLine", "TC_其他: 光标置于命令行")
    quickz.SetCommand("cm_FocusButtonBar", "TC_其他: 光标置于工具栏")
    quickz.SetCommand("cm_CountDirContent", "TC_其他: 计算所有文件夹占用的空间")
    quickz.SetCommand("cm_UnloadPlugins", "TC_其他: 卸载所有插件")
    quickz.SetCommand("cm_DirMatch", "TC_其他: 标出新文件, 隐藏相同者")
    quickz.SetCommand("cm_Exchange", "TC_其他: 交换左右窗口")
    quickz.SetCommand("cm_MatchSrc", "TC_其他: 目标 = 来源")
    quickz.SetCommand("cm_ReloadSelThumbs", "TC_其他: 刷新选中文件的缩略图")
    quickz.SetCommand("cm_DirectCableConnect", "TC_并口: 直接电缆连接")
    quickz.SetCommand("cm_NTinstallDriver", "TC_并口: 加载 NT 并口驱动程序")
    quickz.SetCommand("cm_NTremoveDriver", "TC_并口: 卸载 NT 并口驱动程序")
    quickz.SetCommand("cm_PrintDir", "TC_打印: 打印文件列表")
    quickz.SetCommand("cm_PrintDirSub", "TC_打印: 打印文件列表(含子文件夹")
    quickz.SetCommand("cm_PrintFile", "TC_打印: 打印文件内容")
    quickz.SetCommand("cm_SpreadSelection", "TC_选择: 选择一组文件")
    quickz.SetCommand("cm_SelectBoth", "TC_选择: 选择一组: 文件和文件夹")
    quickz.SetCommand("cm_SelectFiles", "TC_选择: 选择一组: 仅文件")
    quickz.SetCommand("cm_SelectFolders", "TC_选择: 选择一组: 仅文件夹")
    quickz.SetCommand("cm_ShrinkSelection", "TC_选择: 不选一组文件")
    quickz.SetCommand("cm_ClearFiles", "TC_选择: 不选一组: 仅文件")
    quickz.SetCommand("cm_ClearFolders", "TC_选择: 不选一组: 仅文件夹")
    quickz.SetCommand("cm_ClearSelCfg", "TC_选择: 不选一组: 文件和/或文件夹(视配置而定")
    quickz.SetCommand("cm_SelectAll", "TC_选择: 全部选择: 文件和/或文件夹(视配置而定")
    quickz.SetCommand("cm_SelectAllBoth", "TC_选择: 全部选择: 文件和文件夹")
    quickz.SetCommand("cm_SelectAllFiles", "TC_选择: 全部选择: 仅文件")
    quickz.SetCommand("cm_SelectAllFolders", "TC_选择: 全部选择: 仅文件夹")
    quickz.SetCommand("cm_ClearAll", "TC_选择: 全部取消: 文件和文件夹")
    quickz.SetCommand("cm_ClearAllFiles", "TC_选择: 全部取消: 仅文件")
    quickz.SetCommand("cm_ClearAllFolders", "TC_选择: 全部取消: 仅文件夹")
    quickz.SetCommand("cm_ClearAllCfg", "TC_选择: 全部取消: 文件和/或文件夹(视配置而定")
    quickz.SetCommand("cm_ExchangeSelection", "TC_选择: 反向选择")
    quickz.SetCommand("cm_ExchangeSelBoth", "TC_选择: 反向选择: 文件和文件夹")
    quickz.SetCommand("cm_ExchangeSelFiles", "TC_选择: 反向选择: 仅文件")
    quickz.SetCommand("cm_ExchangeSelFolders", "TC_选择: 反向选择: 仅文件夹")
    quickz.SetCommand("cm_SelectCurrentExtension", "TC_选择: 选择扩展名相同的文件")
    quickz.SetCommand("cm_UnselectCurrentExtension", "TC_选择: 不选扩展名相同的文件")
    quickz.SetCommand("cm_SelectCurrentName", "TC_选择: 选择文件名相同的文件")
    quickz.SetCommand("cm_UnselectCurrentName", "TC_选择: 不选文件名相同的文件")
    quickz.SetCommand("cm_SelectCurrentNameExt", "TC_选择: 选择文件名和扩展名相同的文件")
    quickz.SetCommand("cm_UnselectCurrentNameExt", "TC_选择: 不选文件名和扩展名相同的文件")
    quickz.SetCommand("cm_SelectCurrentPath", "TC_选择: 选择同一路径下的文件(展开文件夹+搜索文件")
    quickz.SetCommand("cm_UnselectCurrentPath", "TC_选择: 不选同一路径下的文件(展开文件夹+搜索文件")
    quickz.SetCommand("cm_RestoreSelection", "TC_选择: 恢复选择列表")
    quickz.SetCommand("cm_SaveSelection", "TC_选择: 保存选择列表")
    quickz.SetCommand("cm_SaveSelectionToFile", "TC_选择: 导出选择列表")
    quickz.SetCommand("cm_SaveSelectionToFileA", "TC_选择: 导出选择列表(ANSI")
    quickz.SetCommand("cm_SaveSelectionToFileW", "TC_选择: 导出选择列表(Unicode")
    quickz.SetCommand("cm_SaveDetailsToFile", "TC_选择: 导出详细信息")
    quickz.SetCommand("cm_SaveDetailsToFileA", "TC_选择: 导出详细信息(ANSI")
    quickz.SetCommand("cm_SaveDetailsToFileW", "TC_选择: 导出详细信息(Unicode")
    quickz.SetCommand("cm_LoadSelectionFromFile", "TC_选择: 导入选择列表(从文件")
    quickz.SetCommand("cm_LoadSelectionFromClip", "TC_选择: 导入选择列表(从剪贴板")
    quickz.SetCommand("cm_EditPermissionInfo", "TC_安全: 设置权限(NTFS")
    quickz.SetCommand("cm_EditAuditInfo", "TC_安全: 审核文件(NTFS")
    quickz.SetCommand("cm_EditOwnerInfo", "TC_安全: 获取所有权(NTFS")
    quickz.SetCommand("cm_CutToClipboard", "TC_剪贴板: 剪切选中的文件到剪贴板")
    quickz.SetCommand("cm_CopyToClipboard", "TC_剪贴板: 复制选中的文件到剪贴板")
    quickz.SetCommand("cm_PasteFromClipboard", "TC_剪贴板: 从剪贴板粘贴到当前文件夹")
    quickz.SetCommand("cm_CopyNamesToClip", "TC_剪贴板: 复制文件名")
    quickz.SetCommand("cm_CopyFullNamesToClip", "TC_剪贴板: 复制文件名及完整路径")
    quickz.SetCommand("cm_CopyNetNamesToClip", "TC_剪贴板: 复制文件名及网络路径")
    quickz.SetCommand("cm_CopySrcPathToClip", "TC_剪贴板: 复制来源路径")
    quickz.SetCommand("cm_CopyTrgPathToClip", "TC_剪贴板: 复制目标路径")
    quickz.SetCommand("cm_CopyFileDetailsToClip", "TC_剪贴板: 复制文件详细信息")
    quickz.SetCommand("cm_CopyFpFileDetailsToClip", "TC_剪贴板: 复制文件详细信息及完整路径")
    quickz.SetCommand("cm_CopyNetFileDetailsToClip", "TC_剪贴板: 复制文件详细信息及网络路径")
    quickz.SetCommand("cm_FtpConnect", "TC_FTP: FTP 连接")
    quickz.SetCommand("cm_FtpNew", "TC_FTP: 新建 FTP 连接")
    quickz.SetCommand("cm_FtpDisconnect", "TC_FTP: 断开 FTP 连接")
    quickz.SetCommand("cm_FtpHiddenFiles", "TC_FTP: 显示隐藏的FTP文件")
    quickz.SetCommand("cm_FtpAbort", "TC_FTP: 中止当前 FTP 命令")
    quickz.SetCommand("cm_FtpResumeDownload", "TC_FTP: 续传")
    quickz.SetCommand("cm_FtpSelectTransferMode", "TC_FTP: 选择传输模式")
    quickz.SetCommand("cm_FtpAddToList", "TC_FTP: 添加到下载列表")
    quickz.SetCommand("cm_FtpDownloadList", "TC_FTP: 按列表下载")
    quickz.SetCommand("cm_GotoPreviousDir", "TC_FTP: 后退")
    quickz.SetCommand("cm_GotoNextDir", "TC_导航: 前进")
    quickz.SetCommand("cm_DirectoryHistory", "TC_导航: 文件夹历史记录")
    quickz.SetCommand("cm_GotoPreviousLocalDir", "TC_导航: 后退(非 FTP")
    quickz.SetCommand("cm_GotoNextLocalDir", "TC_导航: 前进(非 FTP")
    quickz.SetCommand("cm_DirectoryHotlist", "TC_导航: 常用文件夹")
    quickz.SetCommand("cm_GoToRoot", "TC_导航: 转到根文件夹")
    quickz.SetCommand("cm_GoToParent", "TC_导航: 转到上层文件夹")
    quickz.SetCommand("cm_GoToDir", "TC_导航: 打开光标处的文件夹或压缩包")
    quickz.SetCommand("cm_OpenDesktop", "TC_导航: 桌面")
    quickz.SetCommand("cm_OpenDrives", "TC_导航: 我的电脑")
    quickz.SetCommand("cm_OpenControls", "TC_导航: 控制面板")
    quickz.SetCommand("cm_OpenFonts", "TC_导航: 字体")
    quickz.SetCommand("cm_OpenNetwork", "TC_导航: 网上邻居")
    quickz.SetCommand("cm_OpenPrinters", "TC_导航: 打印机")
    quickz.SetCommand("cm_OpenRecycled", "TC_导航: 回收站")
    quickz.SetCommand("cm_CDtree", "TC_导航: 更改文件夹")
    quickz.SetCommand("cm_TransferLeft", "TC_导航: 在左窗口打开光标处的文件夹或压缩包")
    quickz.SetCommand("cm_TransferRight", "TC_导航: 在右窗口打开光标处的文件夹或压缩包")
    quickz.SetCommand("cm_EditPath", "TC_导航: 编辑来源窗口的路径")
    quickz.SetCommand("cm_GoToFirstFile", "TC_导航: 光标移到列表中的第一个文件")
    quickz.SetCommand("cm_GotoNextDrive", "TC_导航: 转到下一个驱动器")
    quickz.SetCommand("cm_GotoPreviousDrive", "TC_导航: 转到上一个驱动器")
    quickz.SetCommand("cm_GotoNextSelected", "TC_导航: 转到下一个选中的文件")
    quickz.SetCommand("cm_GotoPrevSelected", "TC_导航: 转到上一个选中的文件")
    quickz.SetCommand("cm_GotoDriveA", "TC_导航: 转到驱动器 A")
    quickz.SetCommand("cm_GotoDriveC", "TC_导航: 转到驱动器 C")
    quickz.SetCommand("cm_GotoDriveD", "TC_导航: 转到驱动器 D")
    quickz.SetCommand("cm_GotoDriveE", "TC_导航: 转到驱动器 E")
    quickz.SetCommand("cm_GotoDriveF", "TC_导航: 可自定义其他驱动器")
    quickz.SetCommand("cm_GotoDriveZ", "TC_导航: 最多 26 个")
    quickz.SetCommand("cm_HelpIndex", "TC_帮助: 帮助索引")
    quickz.SetCommand("cm_Keyboard", "TC_帮助: 快捷键列表")
    quickz.SetCommand("cm_Register", "TC_帮助: 注册信息")
    quickz.SetCommand("cm_VisitHomepage", "TC_帮助: 访问 Totalcmd 网站")
    quickz.SetCommand("cm_About", "TC_帮助: 关于 Total Commander")
    quickz.SetCommand("cm_Exit", "TC_窗口: 退出 Total Commander")
    quickz.SetCommand("cm_Minimize", "TC_窗口: 最小化 Total Commander")
    quickz.SetCommand("cm_Maximize", "TC_窗口: 最大化 Total Commander")
    quickz.SetCommand("cm_Restore", "TC_窗口: 恢复正常大小")
    quickz.SetCommand("cm_ClearCmdLine", "TC_命令行: 清除命令行")
    quickz.SetCommand("cm_NextCommand", "TC_命令行: 下一条命令")
    quickz.SetCommand("cm_PrevCommand", "TC_命令行: 上一条命令")
    quickz.SetCommand("cm_AddPathToCmdline", "TC_命令行: 将路径复制到命令行")
    quickz.SetCommand("cm_MultiRenameFiles", "TC_工具: 批量重命名")
    quickz.SetCommand("cm_SysInfo", "TC_工具: 系统信息")
    quickz.SetCommand("cm_OpenTransferManager", "TC_工具: 后台传输管理器")
    quickz.SetCommand("cm_SearchFor", "TC_工具: 搜索文件")
    quickz.SetCommand("cm_SearchStandalone", "TC_工具: 在单独进程搜索文件")
    quickz.SetCommand("cm_FileSync", "TC_工具: 同步文件夹")
    quickz.SetCommand("cm_Associate", "TC_工具: 文件关联")
    quickz.SetCommand("cm_InternalAssociate", "TC_工具: 定义内部关联")
    quickz.SetCommand("cm_CompareFilesByContent", "TC_工具: 比较文件内容")
    quickz.SetCommand("cm_IntCompareFilesByContent", "TC_工具: 使用内部比较程序")
    quickz.SetCommand("cm_CommandBrowser", "TC_工具: 浏览内部命令")
    quickz.SetCommand("cm_VisButtonbar", "TC_视图: 显示/隐藏: 工具栏")
    quickz.SetCommand("cm_VisDriveButtons", "TC_视图: 显示/隐藏: 驱动器按钮")
    quickz.SetCommand("cm_VisTwoDriveButtons", "TC_视图: 显示/隐藏: 两个驱动器按钮栏")
    quickz.SetCommand("cm_VisFlatDriveButtons", "TC_视图: 切换: 平坦/立体驱动器按钮")
    quickz.SetCommand("cm_VisFlatInterface", "TC_视图: 切换: 平坦/立体用户界面")
    quickz.SetCommand("cm_VisDriveCombo", "TC_视图: 显示/隐藏: 驱动器列表")
    quickz.SetCommand("cm_VisCurDir", "TC_视图: 显示/隐藏: 当前文件夹")
    quickz.SetCommand("cm_VisBreadCrumbs", "TC_视图: 显示/隐藏: 路径导航栏")
    quickz.SetCommand("cm_VisTabHeader", "TC_视图: 显示/隐藏: 排序制表符")
    quickz.SetCommand("cm_VisStatusbar", "TC_视图: 显示/隐藏: 状态栏")
    quickz.SetCommand("cm_VisCmdLine", "TC_视图: 显示/隐藏: 命令行")
    quickz.SetCommand("cm_VisKeyButtons", "TC_视图: 显示/隐藏: 功能键按钮")
    quickz.SetCommand("cm_ShowHint", "TC_视图: 显示文件提示")
    quickz.SetCommand("cm_ShowQuickSearch", "TC_视图: 显示快速搜索窗口")
    quickz.SetCommand("cm_SwitchLongNames", "TC_视图: 开启/关闭: 长文件名显示")
    quickz.SetCommand("cm_RereadSource", "TC_视图: 刷新来源窗口")
    quickz.SetCommand("cm_ShowOnlySelected", "TC_视图: 仅显示选中的文件")
    quickz.SetCommand("cm_SwitchHidSys", "TC_视图: 开启/关闭: 隐藏或系统文件显示")
    quickz.SetCommand("cm_Switch83Names", "TC_视图: 开启/关闭: 8.3 式文件名小写显示")
    quickz.SetCommand("cm_SwitchDirSort", "TC_视图: 开启/关闭: 文件夹按名称排序")
    quickz.SetCommand("cm_DirBranch", "TC_视图: 展开所有文件夹")
    quickz.SetCommand("cm_DirBranchSel", "TC_视图: 只展开选中的文件夹")
    quickz.SetCommand("cm_50Percent", "TC_视图: 窗口分隔栏位于 50%")
    quickz.SetCommand("cm_100Percent", "TC_视图: 窗口分隔栏位于 100% TC 8.0+")
    quickz.SetCommand("cm_VisDirTabs", "TC_视图: 显示/隐藏: 文件夹标签")
    quickz.SetCommand("cm_VisXPThemeBackground", "TC_视图: 显示/隐藏: XP 主题背景")
    quickz.SetCommand("cm_SwitchOverlayIcons", "TC_视图: 开启/关闭: 叠置图标显示")
    quickz.SetCommand("cm_VisHistHotButtons", "TC_视图: 显示/隐藏: 文件夹历史记录和常用文件夹按钮")
    quickz.SetCommand("cm_SwitchWatchDirs", "TC_视图: 启用/禁用: 文件夹自动刷新")
    quickz.SetCommand("cm_SwitchIgnoreList", "TC_视图: 启用/禁用: 自定义隐藏文件")
    quickz.SetCommand("cm_SwitchX64Redirection", "TC_视图: 开启/关闭: 32 位 system32 目录重定向(64 位 Windows")
    quickz.SetCommand("cm_SeparateTreeOff", "TC_视图: 关闭独立文件夹树面板")
    quickz.SetCommand("cm_SeparateTree1", "TC_视图: 一个独立文件夹树面板")
    quickz.SetCommand("cm_SeparateTree2", "TC_视图: 两个独立文件夹树面板")
    quickz.SetCommand("cm_SwitchSeparateTree", "TC_视图: 切换独立文件夹树面板状态")
    quickz.SetCommand("cm_ToggleSeparateTree1", "TC_视图: 开启/关闭: 一个独立文件夹树面板")
    quickz.SetCommand("cm_ToggleSeparateTree2", "TC_视图: 开启/关闭: 两个独立文件夹树面板")
    quickz.SetCommand("cm_UserMenu1", "TC_用户: 用户菜单 1")
    quickz.SetCommand("cm_UserMenu2", "TC_用户: 用户菜单 2")
    quickz.SetCommand("cm_UserMenu3", "TC_用户: 用户菜单 3")
    quickz.SetCommand("cm_UserMenu4", "TC_用户: 用户菜单 4")
    quickz.SetCommand("cm_UserMenu5", "TC_用户: 用户菜单 5")
    quickz.SetCommand("cm_UserMenu6", "TC_用户: 用户菜单 6")
    quickz.SetCommand("cm_UserMenu7", "TC_用户: 用户菜单 7")
    quickz.SetCommand("cm_UserMenu8", "TC_用户: 用户菜单 8")
    quickz.SetCommand("cm_UserMenu9", "TC_用户: 用户菜单 9")
    quickz.SetCommand("cm_UserMenu10", "TC_用户: 可定义其他用户菜单")
    quickz.SetCommand("cm_OpenNewTab", "TC_标签: 新建标签")
    quickz.SetCommand("cm_OpenNewTabBg", "TC_标签: 新建标签(在后台")
    quickz.SetCommand("cm_OpenDirInNewTab", "TC_标签: 新建标签(并打开光标处的文件夹")
    quickz.SetCommand("cm_OpenDirInNewTabOther", "TC_标签: 新建标签(在另一窗口打开文件夹")
    quickz.SetCommand("cm_SwitchToNextTab", "TC_标签: 下一个标签(Ctrl+Tab")
    quickz.SetCommand("cm_SwitchToPreviousTab", "TC_标签: 上一个标签(Ctrl+Shift+Tab")
    quickz.SetCommand("cm_CloseCurrentTab", "TC_标签: 关闭当前标签")
    quickz.SetCommand("cm_CloseAllTabs", "TC_标签: 关闭所有标签")
    quickz.SetCommand("cm_DirTabsShowMenu", "TC_标签: 显示标签菜单")
    quickz.SetCommand("cm_ToggleLockCurrentTab", "TC_标签: 锁定/解锁当前标签")
    quickz.SetCommand("cm_ToggleLockDcaCurrentTab", "TC_标签: 锁定/解锁当前标签(可更改文件夹")
    quickz.SetCommand("cm_ExchangeWithTabs", "TC_标签: 交换左右窗口及其标签")
    quickz.SetCommand("cm_GoToLockedDir", "TC_标签: 转到锁定标签的根文件夹")
    quickz.SetCommand("cm_SrcActivateTab1", "TC_标签: 来源窗口: 激活标签 1")
    quickz.SetCommand("cm_SrcActivateTab2", "TC_标签: 来源窗口: 激活标签 2")
    quickz.SetCommand("cm_SrcActivateTab3", "TC_标签: 来源窗口: 激活标签 3")
    quickz.SetCommand("cm_SrcActivateTab4", "TC_标签: 来源窗口: 激活标签 4")
    quickz.SetCommand("cm_SrcActivateTab5", "TC_标签: 来源窗口: 激活标签 5")
    quickz.SetCommand("cm_SrcActivateTab6", "TC_标签: 来源窗口: 激活标签 6")
    quickz.SetCommand("cm_SrcActivateTab7", "TC_标签: 来源窗口: 激活标签 7")
    quickz.SetCommand("cm_SrcActivateTab8", "TC_标签: 来源窗口: 激活标签 8")
    quickz.SetCommand("cm_SrcActivateTab9", "TC_标签: 来源窗口: 激活标签 9")
    quickz.SetCommand("cm_SrcActivateTab10", "TC_标签: 来源窗口: 激活标签 10")
    quickz.SetCommand("cm_TrgActivateTab1", "TC_标签: 目标窗口: 激活标签 1")
    quickz.SetCommand("cm_TrgActivateTab2", "TC_标签: 目标窗口: 激活标签 2")
    quickz.SetCommand("cm_TrgActivateTab3", "TC_标签: 目标窗口: 激活标签 3")
    quickz.SetCommand("cm_TrgActivateTab4", "TC_标签: 目标窗口: 激活标签 4")
    quickz.SetCommand("cm_TrgActivateTab5", "TC_标签: 目标窗口: 激活标签 5")
    quickz.SetCommand("cm_TrgActivateTab6", "TC_标签: 目标窗口: 激活标签 6")
    quickz.SetCommand("cm_TrgActivateTab7", "TC_标签: 目标窗口: 激活标签 7")
    quickz.SetCommand("cm_TrgActivateTab8", "TC_标签: 目标窗口: 激活标签 8")
    quickz.SetCommand("cm_TrgActivateTab9", "TC_标签: 目标窗口: 激活标签 9")
    quickz.SetCommand("cm_TrgActivateTab10", "TC_标签: 目标窗口: 激活标签 10")
    quickz.SetCommand("cm_LeftActivateTab1", "TC_标签: 左窗口: 激活标签 1")
    quickz.SetCommand("cm_LeftActivateTab2", "TC_标签: 左窗口: 激活标签 2")
    quickz.SetCommand("cm_LeftActivateTab3", "TC_标签: 左窗口: 激活标签 3")
    quickz.SetCommand("cm_LeftActivateTab4", "TC_标签: 左窗口: 激活标签 4")
    quickz.SetCommand("cm_LeftActivateTab5", "TC_标签: 左窗口: 激活标签 5")
    quickz.SetCommand("cm_LeftActivateTab6", "TC_标签: 左窗口: 激活标签 6")
    quickz.SetCommand("cm_LeftActivateTab7", "TC_标签: 左窗口: 激活标签 7")
    quickz.SetCommand("cm_LeftActivateTab8", "TC_标签: 左窗口: 激活标签 8")
    quickz.SetCommand("cm_LeftActivateTab9", "TC_标签: 左窗口: 激活标签 9")
    quickz.SetCommand("cm_LeftActivateTab10", "TC_标签: 左窗口: 激活标签 10")
    quickz.SetCommand("cm_RightActivateTab1", "TC_标签: 右窗口: 激活标签 1")
    quickz.SetCommand("cm_RightActivateTab2", "TC_标签: 右窗口: 激活标签 2")
    quickz.SetCommand("cm_RightActivateTab3", "TC_标签: 右窗口: 激活标签 3")
    quickz.SetCommand("cm_RightActivateTab4", "TC_标签: 右窗口: 激活标签 4")
    quickz.SetCommand("cm_RightActivateTab5", "TC_标签: 右窗口: 激活标签 5")
    quickz.SetCommand("cm_RightActivateTab6", "TC_标签: 右窗口: 激活标签 6")
    quickz.SetCommand("cm_RightActivateTab7", "TC_标签: 右窗口: 激活标签 7")
    quickz.SetCommand("cm_RightActivateTab8", "TC_标签: 右窗口: 激活标签 8")
    quickz.SetCommand("cm_RightActivateTab9", "TC_标签: 右窗口: 激活标签 9")
    quickz.SetCommand("cm_RightActivateTab10", "TC_标签: 右窗口: 激活标签 10")
    quickz.SetCommand("cm_SrcSortByCol1", "TC_排序: 来源窗口: 按第 1 列排序")
    quickz.SetCommand("cm_SrcSortByCol2", "TC_排序: 来源窗口: 按第 2 列排序")
    quickz.SetCommand("cm_SrcSortByCol3", "TC_排序: 来源窗口: 按第 3 列排序")
    quickz.SetCommand("cm_SrcSortByCol4", "TC_排序: 来源窗口: 按第 4 列排序")
    quickz.SetCommand("cm_SrcSortByCol5", "TC_排序: 来源窗口: 按第 5 列排序")
    quickz.SetCommand("cm_SrcSortByCol6", "TC_排序: 来源窗口: 按第 6 列排序")
    quickz.SetCommand("cm_SrcSortByCol7", "TC_排序: 来源窗口: 按第 7 列排序")
    quickz.SetCommand("cm_SrcSortByCol8", "TC_排序: 来源窗口: 按第 8 列排序")
    quickz.SetCommand("cm_SrcSortByCol9", "TC_排序: 来源窗口: 按第 9 列排序")
    quickz.SetCommand("cm_SrcSortByCol10", "TC_排序: 来源窗口: 按第 10 列排序")
    quickz.SetCommand("cm_TrgSortByCol1", "TC_排序: 目标窗口: 按第 1 列排序")
    quickz.SetCommand("cm_TrgSortByCol2", "TC_排序: 目标窗口: 按第 2 列排序")
    quickz.SetCommand("cm_TrgSortByCol3", "TC_排序: 目标窗口: 按第 3 列排序")
    quickz.SetCommand("cm_TrgSortByCol4", "TC_排序: 目标窗口: 按第 4 列排序")
    quickz.SetCommand("cm_TrgSortByCol5", "TC_排序: 目标窗口: 按第 5 列排序")
    quickz.SetCommand("cm_TrgSortByCol6", "TC_排序: 目标窗口: 按第 6 列排序")
    quickz.SetCommand("cm_TrgSortByCol7", "TC_排序: 目标窗口: 按第 7 列排序")
    quickz.SetCommand("cm_TrgSortByCol8", "TC_排序: 目标窗口: 按第 8 列排序")
    quickz.SetCommand("cm_TrgSortByCol9", "TC_排序: 目标窗口: 按第 9 列排序")
    quickz.SetCommand("cm_TrgSortByCol10", "TC_排序: 目标窗口: 按第 10 列排序")
    quickz.SetCommand("cm_LeftSortByCol1", "TC_排序: 左窗口: 按第 1 列排序")
    quickz.SetCommand("cm_LeftSortByCol2", "TC_排序: 左窗口: 按第 2 列排序")
    quickz.SetCommand("cm_LeftSortByCol3", "TC_排序: 左窗口: 按第 3 列排序")
    quickz.SetCommand("cm_LeftSortByCol4", "TC_排序: 左窗口: 按第 4 列排序")
    quickz.SetCommand("cm_LeftSortByCol5", "TC_排序: 左窗口: 按第 5 列排序")
    quickz.SetCommand("cm_LeftSortByCol6", "TC_排序: 左窗口: 按第 6 列排序")
    quickz.SetCommand("cm_LeftSortByCol7", "TC_排序: 左窗口: 按第 7 列排序")
    quickz.SetCommand("cm_LeftSortByCol8", "TC_排序: 左窗口: 按第 8 列排序")
    quickz.SetCommand("cm_LeftSortByCol9", "TC_排序: 左窗口: 按第 9 列排序")
    quickz.SetCommand("cm_LeftSortByCol10", "TC_排序: 左窗口: 按第 10 列排序")
    quickz.SetCommand("cm_RightSortByCol1", "TC_排序: 右窗口: 按第 1 列排序")
    quickz.SetCommand("cm_RightSortByCol2", "TC_排序: 右窗口: 按第 2 列排序")
    quickz.SetCommand("cm_RightSortByCol3", "TC_排序: 右窗口: 按第 3 列排序")
    quickz.SetCommand("cm_RightSortByCol4", "TC_排序: 右窗口: 按第 4 列排序")
    quickz.SetCommand("cm_RightSortByCol5", "TC_排序: 右窗口: 按第 5 列排序")
    quickz.SetCommand("cm_RightSortByCol6", "TC_排序: 右窗口: 按第 6 列排序")
    quickz.SetCommand("cm_RightSortByCol7", "TC_排序: 右窗口: 按第 7 列排序")
    quickz.SetCommand("cm_RightSortByCol8", "TC_排序: 右窗口: 按第 8 列排序")
    quickz.SetCommand("cm_RightSortByCol9", "TC_排序: 右窗口: 按第 9 列排序")
    quickz.SetCommand("cm_RightSortByCol10", "TC_排序: 右窗口: 按第 10 列排序")
    quickz.SetCommand("cm_SrcCustomView1", "TC_自定义列视图: 来源窗口: 自定义列视图 1")
    quickz.SetCommand("cm_SrcCustomView2", "TC_自定义列视图: 来源窗口: 自定义列视图 2")
    quickz.SetCommand("cm_SrcCustomView3", "TC_自定义列视图: 来源窗口: 自定义列视图 3")
    quickz.SetCommand("cm_SrcCustomView4", "TC_自定义列视图: 来源窗口: 自定义列视图 4")
    quickz.SetCommand("cm_SrcCustomView5", "TC_自定义列视图: 来源窗口: 自定义列视图 5")
    quickz.SetCommand("cm_SrcCustomView6", "TC_自定义列视图: 来源窗口: 自定义列视图 6")
    quickz.SetCommand("cm_SrcCustomView7", "TC_自定义列视图: 来源窗口: 自定义列视图 7")
    quickz.SetCommand("cm_SrcCustomView8", "TC_自定义列视图: 来源窗口: 自定义列视图 8")
    quickz.SetCommand("cm_SrcCustomView9", "TC_自定义列视图: 来源窗口: 自定义列视图 9")
    quickz.SetCommand("cm_LeftCustomView1", "TC_自定义列视图: 左窗口: 自定义列视图 1")
    quickz.SetCommand("cm_LeftCustomView2", "TC_自定义列视图: 左窗口: 自定义列视图 2")
    quickz.SetCommand("cm_LeftCustomView3", "TC_自定义列视图: 左窗口: 自定义列视图 3")
    quickz.SetCommand("cm_LeftCustomView4", "TC_自定义列视图: 左窗口: 自定义列视图 4")
    quickz.SetCommand("cm_LeftCustomView5", "TC_自定义列视图: 左窗口: 自定义列视图 5")
    quickz.SetCommand("cm_LeftCustomView6", "TC_自定义列视图: 左窗口: 自定义列视图 6")
    quickz.SetCommand("cm_LeftCustomView7", "TC_自定义列视图: 左窗口: 自定义列视图 7")
    quickz.SetCommand("cm_LeftCustomView8", "TC_自定义列视图: 左窗口: 自定义列视图 8")
    quickz.SetCommand("cm_LeftCustomView9", "TC_自定义列视图: 左窗口: 自定义列视图 9")
    quickz.SetCommand("cm_RightCustomView1", "TC_自定义列视图: 右窗口: 自定义列视图 1")
    quickz.SetCommand("cm_RightCustomView2", "TC_自定义列视图: 右窗口: 自定义列视图 2")
    quickz.SetCommand("cm_RightCustomView3", "TC_自定义列视图: 右窗口: 自定义列视图 3")
    quickz.SetCommand("cm_RightCustomView4", "TC_自定义列视图: 右窗口: 自定义列视图 4")
    quickz.SetCommand("cm_RightCustomView5", "TC_自定义列视图: 右窗口: 自定义列视图 5")
    quickz.SetCommand("cm_RightCustomView6", "TC_自定义列视图: 右窗口: 自定义列视图 6")
    quickz.SetCommand("cm_RightCustomView7", "TC_自定义列视图: 右窗口: 自定义列视图 7")
    quickz.SetCommand("cm_RightCustomView8", "TC_自定义列视图: 右窗口: 自定义列视图 8")
    quickz.SetCommand("cm_RightCustomView9", "TC_自定义列视图: 右窗口: 自定义列视图 9")
    quickz.SetCommand("cm_SrcNextCustomView", "TC_自定义列视图: 来源窗口: 下一个自定义视图")
    quickz.SetCommand("cm_SrcPrevCustomView", "TC_自定义列视图: 来源窗口: 上一个自定义视图")
    quickz.SetCommand("cm_TrgNextCustomView", "TC_自定义列视图: 目标窗口: 下一个自定义视图")
    quickz.SetCommand("cm_TrgPrevCustomView", "TC_自定义列视图: 目标窗口: 上一个自定义视图")
    quickz.SetCommand("cm_LeftNextCustomView", "TC_自定义列视图: 左窗口: 下一个自定义视图")
    quickz.SetCommand("cm_LeftPrevCustomView", "TC_自定义列视图: 左窗口: 上一个自定义视图")
    quickz.SetCommand("cm_RightNextCustomView", "TC_自定义列视图: 右窗口: 下一个自定义视图")
    quickz.SetCommand("cm_RightPrevCustomView", "TC_自定义列视图: 右窗口: 上一个自定义视图")
    quickz.SetCommand("cm_LoadAllOnDemandFields", "TC_自定义列视图: 所有文件都按需加载备注")
    quickz.SetCommand("cm_LoadSelOnDemandFields", "TC_自定义列视图: 仅选中的文件按需加载备注")
    quickz.SetCommand("cm_ContentStopLoadFields", "TC_自定义列视图: 停止后台加载备注")

}



;来源窗口 =========================================
cm_SrcComments(){  ;来源窗口: 显示文件备注
    TC.SendPos(300)
}

cm_SrcShort(){  ;来源窗口: 列表
    TC.SendPos(301)
}

cm_SrcLong(){  ;来源窗口: 详细信息
    TC.SendPos(302)
}

cm_SrcTree(){  ;来源窗口: 文件夹树
    TC.SendPos(303)
}

cm_SrcQuickview(){  ;来源窗口: 快速查看
    TC.SendPos(304)
}

cm_VerticalPanels(){  ;来源窗口: 纵向排列
    TC.SendPos(305)
}

cm_SrcQuickInternalOnly(){  ;来源窗口: 快速查看(不用插件)
    TC.SendPos(306)
}

cm_SrcHideQuickview(){  ;来源窗口: 关闭快速查看窗口
    TC.SendPos(307)
}

cm_SrcExecs(){  ;来源窗口: 可执行文件
    TC.SendPos(311)
}

cm_SrcAllFiles(){  ;来源窗口: 所有文件
    TC.SendPos(312)
}

cm_SrcUserSpec(){  ;来源窗口: 上次选中的文件
    TC.SendPos(313)
}

cm_SrcUserDef(){  ;来源窗口: 自定义类型
    TC.SendPos(314)
}

cm_SrcByName(){  ;来源窗口: 按文件名排序
    TC.SendPos(321)
}

cm_SrcByExt(){  ;来源窗口: 按扩展名排序
    TC.SendPos(322)
}

cm_SrcBySize(){  ;来源窗口: 按大小排序
    TC.SendPos(323)
}

cm_SrcByDateTime(){  ;来源窗口: 按日期时间排序
    TC.SendPos(324)
}

cm_SrcUnsorted(){  ;来源窗口: 不排序
    TC.SendPos(325)
}

cm_SrcNegOrder(){  ;来源窗口: 反向排序
    TC.SendPos(330)
}

cm_SrcOpenDrives(){  ;来源窗口: 打开驱动器列表
    TC.SendPos(331)
}

cm_SrcThumbs(){  ;来源窗口: 缩略图
    TC.SendPos(269)
}

cm_SrcCustomViewMenu(){  ;来源窗口: 自定义视图菜单
    TC.SendPos(270)
}

cm_SrcPathFocus(){  ;来源窗口: 焦点置于路径上
    TC.SendPos(332)
}

;左窗口 =========================================
cm_LeftComments(){  ;左窗口: 显示文件备注
    TC.SendPos(100)
}

cm_LeftShort(){  ;左窗口: 列表
    TC.SendPos(101)
}

cm_LeftLong(){  ;左窗口: 详细信息
    TC.SendPos(102)
}

cm_LeftTree(){  ;左窗口: 文件夹树
    TC.SendPos(103)
}

cm_LeftQuickview(){  ;左窗口: 快速查看
    TC.SendPos(104)
}

cm_LeftQuickInternalOnly(){  ;左窗口: 快速查看(不用插件)
    TC.SendPos(106)
}

cm_LeftHideQuickview(){  ;左窗口: 关闭快速查看窗口
    TC.SendPos(107)
}

cm_LeftExecs(){  ;左窗口: 可执行文件
    TC.SendPos(111)
}

cm_LeftAllFiles(){  ;左窗口: 所有文件
    TC.SendPos(112)
}

cm_LeftUserSpec(){  ;左窗口: 上次选中的文件
    TC.SendPos(113)
}

cm_LeftUserDef(){  ;左窗口: 自定义类型
    TC.SendPos(114)
}

cm_LeftByName(){  ;左窗口: 按文件名排序
    TC.SendPos(121)
}

cm_LeftByExt(){  ;左窗口: 按扩展名排序
    TC.SendPos(122)
}

cm_LeftBySize(){  ;左窗口: 按大小排序
    TC.SendPos(123)
}

cm_LeftByDateTime(){  ;左窗口: 按日期时间排序
    TC.SendPos(124)
}

cm_LeftUnsorted(){  ;左窗口: 不排序
    TC.SendPos(125)
}

cm_LeftNegOrder(){  ;左窗口: 反向排序
    TC.SendPos(130)
}

cm_LeftOpenDrives(){  ;左窗口: 打开驱动器列表
    TC.SendPos(131)
}

cm_LeftPathFocus(){  ;左窗口: 焦点置于路径上
    TC.SendPos(132)
}

cm_LeftDirBranch(){  ;左窗口: 展开所有文件夹
    TC.SendPos(2034)
}

cm_LeftDirBranchSel(){  ;左窗口: 只展开选中的文件夹
    TC.SendPos(2047)
}

cm_LeftThumbs(){  ;窗口: 缩略图
    TC.SendPos(69)
}

cm_LeftCustomViewMenu(){  ;窗口: 自定义视图菜单
    TC.SendPos(70)
}

;右窗口 =========================================
cm_RightComments(){  ;右窗口: 显示文件备注
    TC.SendPos(200)
}

cm_RightShort(){  ;右窗口: 列表
    TC.SendPos(201)
}

cm_RightLong(){  ; 右窗口: 详细信息
    TC.SendPos(202)
}

cm_RightTree(){  ;右窗口: 文件夹树
    TC.SendPos(203)
}

cm_RightQuickvie(){  ;右窗口: 快速查看
    TC.SendPos(204)
}

cm_RightQuickInternalOnl(){  ;右窗口: 快速查看(不用插件)
    TC.SendPos(206)
}

cm_RightHideQuickvie(){  ;右窗口: 关闭快速查看窗口
    TC.SendPos(207)
}

cm_RightExec(){  ;右窗口: 可执行文件
    TC.SendPos(211)
}

cm_RightAllFile(){  ;右窗口: 所有文件
    TC.SendPos(212)
}

cm_RightUserSpe(){  ;右窗口: 上次选中的文件
    TC.SendPos(213)
}

cm_RightUserDe(){  ;右窗口: 自定义类型
    TC.SendPos(214)
}

cm_RightByNam(){  ;右窗口: 按文件名排序
    TC.SendPos(221)
}

cm_RightByEx(){  ;右窗口: 按扩展名排序
    TC.SendPos(222)
}

cm_RightBySiz(){  ;右窗口: 按大小排序
    TC.SendPos(223)
}

cm_RightByDateTim(){  ;右窗口: 按日期时间排序
    TC.SendPos(224)
}

cm_RightUnsorte(){  ;右窗口: 不排序
    TC.SendPos(225)
}

cm_RightNegOrde(){  ;右窗口: 反向排序
    TC.SendPos(230)
}

cm_RightOpenDrives(){  ;右窗口: 打开驱动器列表
    TC.SendPos(231)
}

cm_RightPathFocu(){  ;右窗口: 焦点置于路径上
    TC.SendPos(232)
}

cm_RightDirBranch(){  ;右窗口: 展开所有文件夹
    TC.SendPos(2035)
}

cm_RightDirBranchSel(){  ;右窗口: 只展开选中的文件夹
    TC.SendPos(2048)
}

cm_RightThumb(){  ;右窗口: 缩略图
    TC.SendPos(169)
}

cm_RightCustomViewMen(){  ;右窗口: 自定义视图菜单
    TC.SendPos(170)
}

;文件操作 =========================================
cm_List(){  ;文件操作: 查看(用查看程序)
    TC.SendPos(903)
}

cm_ListInternalOnly(){  ;文件操作: 查看(用查看程序, 但不用插件/多媒体)
    TC.SendPos(1006)
}

cm_Edit(){  ;文件操作: 编辑
    TC.SendPos(904)
}

cm_Copy(){  ;文件操作: 复制
    TC.SendPos(905)
}

cm_CopySamepanel(){  ;文件操作: 复制到当前窗口(Shift+F5)
    TC.SendPos(3100)
}

cm_CopyOtherpanel(){  ;文件操作: 复制到另一窗口(F5)
    TC.SendPos(3101)
}

cm_RenMov(){  ;文件操作: 重命名/移动
    TC.SendPos(906)
}


cm_MkDir(){  ;文件操作: 新建文件夹
    TC.SendPos(907)
}

cm_Delete(){  ;文件操作: 删除
    TC.SendPos(908)
}

cm_TestArchive(){  ;文件操作: 测试压缩包
    TC.SendPos(518)
}

cm_PackFiles(){  ;文件操作: 压缩文件
    TC.SendPos(508)
}

cm_UnpackFiles(){  ;文件操作: 解压文件
    TC.SendPos(509)
}

cm_RenameOnly(){  ;文件操作: 重命名(Shift+F6)
    TC.SendPos(1002)
}

cm_RenameSingleFile(){  ;文件操作: 重命名当前文件
    TC.SendPos(1007)
}

cm_MoveOnly(){  ;文件操作: 移动到另一个窗口(F6)
    TC.SendPos(1005)
}

cm_Properties(){  ;文件操作: 显示属性
    TC.SendPos(1003)
}

cm_CreateShortcut(){  ;文件操作: 创建快捷方式
    TC.SendPos(1004)
}

cm_Return(){  ;文件操作: 模仿按 ENTER 键
    TC.SendPos(1001)
}

cm_OpenAsUser(){  ;文件操作: 以其他用户身份运行光标处的程序
    TC.SendPos(2800)
}

cm_Split(){  ;文件操作: 分割文件
    TC.SendPos(560)
}

cm_Combine(){  ;文件操作: 合并文件
    TC.SendPos(561)
}

cm_Encode(){  ;文件操作: 编码文件(MIME/UUE/XXE 格式)
    TC.SendPos(562)
}

cm_Decode(){  ;文件操作: 解码文件(MIME/UUE/XXE/BinHex 格式)
    TC.SendPos(563)
}

cm_CRCcreate(){  ;文件操作: 创建校验文件
    TC.SendPos(564)
}

cm_CRCcheck(){  ;文件操作: 验证校验和
    TC.SendPos(565)
}

cm_SetAttrib(){  ;文件操作: 更改属性
    TC.SendPos(502)
}

;配置 =========================================
cm_Config(){  ;配置: 布局
    TC.SendPos(490)
}

cm_DisplayConfig(){  ;配置: 显示
    TC.SendPos(486)
}

cm_IconConfig(){  ;配置: 图标
    TC.SendPos(477)
}

cm_FontConfig(){  ;配置: 字体
    TC.SendPos(492)
}

cm_ColorConfig(){  ;配置: 颜色
    TC.SendPos(494)
}

cm_ConfTabChange(){  ;配置: 制表符
    TC.SendPos(497)
}

cm_DirTabsConfig(){  ;配置: 文件夹标签
    TC.SendPos(488)
}

cm_CustomColumnConfig(){  ;配置: 自定义列
    TC.SendPos(483)
}

cm_CustomColumnDlg(){  ;配置: 更改当前自定义列
    TC.SendPos(2920)
}

cm_LanguageConfig(){  ;配置: 语言
    TC.SendPos(499)
}

cm_Config2(){  ;配置: 操作方式
    TC.SendPos(516)
}

cm_EditConfig(){  ;配置: 编辑/查看
    TC.SendPos(496)
}

cm_CopyConfig(){  ;配置: 复制/删除
    TC.SendPos(487)
}

cm_RefreshConfig(){  ;配置: 刷新
    TC.SendPos(478)
}

cm_QuickSearchConfig(){  ;配置: 快速搜索
    TC.SendPos(479)
}

cm_FtpConfig(){  ;配置: FTP
    TC.SendPos(489)
}

cm_PluginsConfig(){  ;配置: 插件
    TC.SendPos(484)
}

cm_ThumbnailsConfig(){  ;配置: 缩略图
    TC.SendPos(482)
}

cm_LogConfig(){  ;配置: 日志文件
    TC.SendPos(481)
}

cm_IgnoreConfig(){  ;配置: 隐藏文件
    TC.SendPos(480)
}

cm_PackerConfig(){  ;配置: 压缩程序
    TC.SendPos(491)
}

cm_ZipPackerConfig(){  ;配置: ZIP 压缩程序
    TC.SendPos(485)
}

cm_Confirmation(){  ;配置: 其他/确认
    TC.SendPos(495)
}

cm_ConfigSavePos(){  ;配置: 保存位置
    TC.SendPos(493)
}

cm_ButtonConfig(){  ;配置: 更改工具栏
    TC.SendPos(498)
}

cm_ConfigSaveSettings(){  ;配置: 保存设置
    TC.SendPos(580)
}

cm_ConfigChangeIniFiles(){  ;配置: 直接修改配置文件
    TC.SendPos(581)
}

cm_ConfigSaveDirHistory(){  ;配置: 保存文件夹历史记录
    TC.SendPos(582)
}

cm_ChangeStartMenu(){  ;配置: 更改开始菜单
    TC.SendPos(700)
}

;网络 =========================================
cm_NetConnect(){  ;网络: 映射网络驱动器
    TC.SendPos(512)
}

cm_NetDisconnect(){  ;网络: 断开网络驱动器
    TC.SendPos(513)
}

cm_NetShareDir(){  ;网络: 共享当前文件夹
    TC.SendPos(514)
}

cm_NetUnshareDir(){  ;网络: 取消文件夹共享
    TC.SendPos(515)
}

cm_AdministerServer(){  ;网络: 显示系统共享文件夹
    TC.SendPos(2204)
}

cm_ShowFileUser(){  ;网络: 显示本地文件的远程用户
    TC.SendPos(2203)
}

;其他 =========================================
cm_GetFileSpace(){  ;其他: 计算占用空间
    TC.SendPos(503)
}

cm_VolumeId(){  ;其他: 设置卷标
    TC.SendPos(505)
}

cm_VersionInfo(){  ;其他: 版本信息
    TC.SendPos(510)
}

cm_ExecuteDOS(){  ;其他: 打开命令提示符窗口
    TC.SendPos(511)
}

cm_CompareDirs(){  ;其他: 比较文件夹
    TC.SendPos(533)
}

cm_CompareDirsWithSubdirs(){  ;其他: 比较文件夹(同时标出另一窗口没有的子文件夹)
    TC.SendPos(536)
}

cm_ContextMenu(){  ;其他: 显示快捷菜单
    TC.SendPos(2500)
}

cm_ContextMenuInternal(){  ;其他: 显示快捷菜单(内部关联)
    TC.SendPos(2927)
}

cm_ContextMenuInternalCursor(){  ;其他: 显示光标处文件的内部关联快捷菜单
    TC.SendPos(2928)
}

cm_ShowRemoteMenu(){  ;其他: 媒体中心遥控器播放/暂停键快捷菜单
    TC.SendPos(2930)
}

cm_SyncChangeDir(){  ;其他: 两边窗口同步更改文件夹
    TC.SendPos(2600)
}

cm_EditComment(){  ;其他: 编辑文件备注
    TC.SendPos(2700)
}

cm_FocusLeft(){  ;其他: 光标置于左窗口
    TC.SendPos(4001)
}

cm_FocusRight(){  ;其他: 光标置于右窗口
    TC.SendPos(4002)
}

cm_FocusCmdLine(){  ;其他: 光标置于命令行
    TC.SendPos(4003)
}

cm_FocusButtonBar(){  ;其他: 光标置于工具栏
    TC.SendPos(4004)
}

cm_CountDirContent(){  ;其他: 计算所有文件夹占用的空间
    TC.SendPos(2014)
}

cm_UnloadPlugins(){  ;其他: 卸载所有插件
    TC.SendPos(2913)
}

cm_DirMatch(){  ;其他: 标出新文件, 隐藏相同者
    TC.SendPos(534)
}

cm_Exchange(){  ;其他: 交换左右窗口
    TC.SendPos(531)
}

cm_MatchSrc(){  ;其他: 目标 = 来源
    TC.SendPos(532)
}

cm_ReloadSelThumbs(){  ;其他: 刷新选中文件的缩略图
    TC.SendPos(2918)
}

;并口 =========================================
cm_DirectCableConnect(){  ;并口: 直接电缆连接
    TC.SendPos(2300)
}

cm_NTinstallDriver(){  ;并口: 加载 NT 并口驱动程序
    TC.SendPos(2301)
}

cm_NTremoveDriver(){  ;并口: 卸载 NT 并口驱动程序
    TC.SendPos(2302)
}

;打印 =========================================
cm_PrintDir(){  ;打印: 打印文件列表
    TC.SendPos(2027)
}

cm_PrintDirSub(){  ;打印: 打印文件列表(含子文件夹)
    TC.SendPos(2028)
}

cm_PrintFile(){  ;打印: 打印文件内容
    TC.SendPos(504)
}

;选择 =========================================
cm_SpreadSelection(){  ;选择: 选择一组文件
    TC.SendPos(521)
}

cm_SelectBoth(){  ;选择: 选择一组: 文件和文件夹
    TC.SendPos(3311)
}

cm_SelectFiles(){  ;选择: 选择一组: 仅文件
    TC.SendPos(3312)
}

cm_SelectFolders(){  ;选择: 选择一组: 仅文件夹
    TC.SendPos(3313)
}

cm_ShrinkSelection(){  ;选择: 不选一组文件
    TC.SendPos(522)
}

cm_ClearFiles(){  ;选择: 不选一组: 仅文件
    TC.SendPos(3314)
}

cm_ClearFolders(){  ;选择: 不选一组: 仅文件夹
    TC.SendPos(3315)
}

cm_ClearSelCfg(){  ;选择: 不选一组: 文件和/或文件夹(视配置而定)
    TC.SendPos(3316)
}

cm_SelectAll(){  ;选择: 全部选择: 文件和/或文件夹(视配置而定)
    TC.SendPos(523)
}

cm_SelectAllBoth(){  ;选择: 全部选择: 文件和文件夹
    TC.SendPos(3301)
}

cm_SelectAllFiles(){  ;选择: 全部选择: 仅文件
    TC.SendPos(3302)
}

cm_SelectAllFolders(){  ;选择: 全部选择: 仅文件夹
    TC.SendPos(3303)
}

cm_ClearAll(){  ;选择: 全部取消: 文件和文件夹
    TC.SendPos(524)
}

cm_ClearAllFiles(){  ;选择: 全部取消: 仅文件
    TC.SendPos(3304)
}

cm_ClearAllFolders(){  ;选择: 全部取消: 仅文件夹
    TC.SendPos(3305)
}

cm_ClearAllCfg(){  ;选择: 全部取消: 文件和/或文件夹(视配置而定)
    TC.SendPos(3306)
}

cm_ExchangeSelection(){  ;选择: 反向选择
    TC.SendPos(525)
}

cm_ExchangeSelBoth(){  ;选择: 反向选择: 文件和文件夹
    TC.SendPos(3321)
}

cm_ExchangeSelFiles(){  ;选择: 反向选择: 仅文件
    TC.SendPos(3322)
}

cm_ExchangeSelFolders(){  ;选择: 反向选择: 仅文件夹
    TC.SendPos(3323)
}

cm_SelectCurrentExtension(){  ;选择: 选择扩展名相同的文件
    TC.SendPos(527)
}

cm_UnselectCurrentExtension(){  ;选择: 不选扩展名相同的文件
    TC.SendPos(528)
}

cm_SelectCurrentName(){  ;选择: 选择文件名相同的文件
    TC.SendPos(541)
}

cm_UnselectCurrentName(){  ;选择: 不选文件名相同的文件
    TC.SendPos(542)
}

cm_SelectCurrentNameExt(){  ;选择: 选择文件名和扩展名相同的文件
    TC.SendPos(543)
}

cm_UnselectCurrentNameExt(){  ;选择: 不选文件名和扩展名相同的文件
    TC.SendPos(544)
}

cm_SelectCurrentPath(){  ;选择: 选择同一路径下的文件(展开文件夹+搜索文件)
    TC.SendPos(537)
}

cm_UnselectCurrentPath(){  ;选择: 不选同一路径下的文件(展开文件夹+搜索文件)
    TC.SendPos(538)
}

cm_RestoreSelection(){  ;选择: 恢复选择列表
    TC.SendPos(529)
}

cm_SaveSelection(){  ;选择: 保存选择列表
    TC.SendPos(530)
}

cm_SaveSelectionToFile(){  ;选择: 导出选择列表
    TC.SendPos(2031)
}

cm_SaveSelectionToFileA(){  ;选择: 导出选择列表(ANSI)
    TC.SendPos(2041)
}

cm_SaveSelectionToFileW(){  ;选择: 导出选择列表(Unicode)
    TC.SendPos(2042)
}

cm_SaveDetailsToFile(){  ;选择: 导出详细信息
    TC.SendPos(2039)
}

cm_SaveDetailsToFileA(){  ;选择: 导出详细信息(ANSI)
    TC.SendPos(2043)
}

cm_SaveDetailsToFileW(){  ;选择: 导出详细信息(Unicode)
    TC.SendPos(2044)
}

cm_LoadSelectionFromFile(){  ;选择: 导入选择列表(从文件)
    TC.SendPos(2032)
}

cm_LoadSelectionFromClip(){  ;选择: 导入选择列表(从剪贴板)
    TC.SendPos(2033)
}

;安全 =========================================
cm_EditPermissionInfo(){  ;安全: 设置权限(NTFS)
    TC.SendPos(2200)
}

cm_EditAuditInfo(){  ;安全: 审核文件(NTFS)
    TC.SendPos(2201)
}

cm_EditOwnerInfo(){  ;安全: 获取所有权(NTFS)
    TC.SendPos(2202)
}

;剪贴板 =========================================
cm_CutToClipboard(){  ;剪贴板: 剪切选中的文件到剪贴板
    TC.SendPos(2007)
}

cm_CopyToClipboard(){  ;剪贴板: 复制选中的文件到剪贴板
    TC.SendPos(2008)
}

cm_PasteFromClipboard(){  ;剪贴板: 从剪贴板粘贴到当前文件夹
    TC.SendPos(2009)
}

cm_CopyNamesToClip(){  ;剪贴板: 复制文件名
    TC.SendPos(2017)
}

cm_CopyFullNamesToClip(){  ;剪贴板: 复制文件名及完整路径
    TC.SendPos(2018)
}

cm_CopyNetNamesToClip(){  ;剪贴板: 复制文件名及网络路径
    TC.SendPos(2021)
}

cm_CopySrcPathToClip(){  ;剪贴板: 复制来源路径
    TC.SendPos(2029)
}

cm_CopyTrgPathToClip(){  ;剪贴板: 复制目标路径
    TC.SendPos(2030)
}

cm_CopyFileDetailsToClip(){  ;剪贴板: 复制文件详细信息
    TC.SendPos(2036)
}

cm_CopyFpFileDetailsToClip(){  ;剪贴板: 复制文件详细信息及完整路径
    TC.SendPos(2037)
}

cm_CopyNetFileDetailsToClip(){  ;剪贴板: 复制文件详细信息及网络路径
    TC.SendPos(2038)
}

;FTP =========================================
cm_FtpConnect(){  ;FTP: FTP 连接
    TC.SendPos(550)
}

cm_FtpNew(){  ;FTP: 新建 FTP 连接
    TC.SendPos(551)
}

cm_FtpDisconnect(){  ;FTP: 断开 FTP 连接
    TC.SendPos(552)
}

cm_FtpHiddenFiles(){  ;FTP: 显示隐藏的FTP文件
    TC.SendPos(553)
}

cm_FtpAbort(){  ;FTP: 中止当前 FTP 命令
    TC.SendPos(554)
}

cm_FtpResumeDownload(){  ;FTP: 续传
    TC.SendPos(555)
}

cm_FtpSelectTransferMode(){  ;FTP: 选择传输模式
    TC.SendPos(556)
}

cm_FtpAddToList(){  ;FTP: 添加到下载列表
    TC.SendPos(557)
}

cm_FtpDownloadList(){  ;FTP: 按列表下载
    TC.SendPos(558)
}

;导航 =========================================
cm_GotoPreviousDir(){  ;导航: 后退
    TC.SendPos(570)
}

cm_GotoNextDir(){  ;导航: 前进
    TC.SendPos(571)
}

cm_DirectoryHistory(){  ;导航: 文件夹历史记录
    Vim_HotkeyCount := 0
    TC.SendPos(572)
}

cm_GotoPreviousLocalDir(){  ;导航: 后退(非 FTP)
    TC.SendPos(573)
}

cm_GotoNextLocalDir(){  ;导航: 前进(非 FTP)
    TC.SendPos(574)
}

cm_DirectoryHotlist(){  ;导航: 常用文件夹
    TC.SendPos(526)
}

cm_GoToRoot(){  ;导航: 转到根文件夹
    TC.SendPos(2001)
}

cm_GoToParent(){  ;导航: 转到上层文件夹
    TC.SendPos(2002)
}

cm_GoToDir(){  ;导航: 打开光标处的文件夹或压缩包
    TC.SendPos(2003)
}

cm_OpenDesktop(){  ;导航: 桌面
    TC.SendPos(2121)
}

cm_OpenDrives(){  ;导航: 我的电脑
    TC.SendPos(2122)
}

cm_OpenControls(){  ;导航: 控制面板
    TC.SendPos(2123)
}

cm_OpenFonts(){  ;导航: 字体
    TC.SendPos(2124)
}

cm_OpenNetwork(){  ;导航: 网上邻居
    TC.SendPos(2125)
}

cm_OpenPrinters(){  ;导航: 打印机
    TC.SendPos(2126)
}

cm_OpenRecycled(){  ;导航: 回收站
    TC.SendPos(2127)
}

cm_CDtree(){  ;导航: 更改文件夹
    TC.SendPos(500)
}

cm_TransferLeft(){  ;导航: 在左窗口打开光标处的文件夹或压缩包
    TC.SendPos(2024)
}

cm_TransferRight(){  ;导航: 在右窗口打开光标处的文件夹或压缩包
    TC.SendPos(2025)
}

cm_EditPath(){  ;导航: 编辑来源窗口的路径
    TC.SendPos(2912)
}

cm_GoToFirstFile(){  ;导航: 光标移到列表中的第一个文件
    TC.SendPos(2050)
}

cm_GotoNextDrive(){  ;导航: 转到下一个驱动器
    TC.SendPos(2051)
}

cm_GotoPreviousDrive(){  ;导航: 转到上一个驱动器
    TC.SendPos(2052)
}

cm_GotoNextSelected(){  ;导航: 转到下一个选中的文件
    TC.SendPos(2053)
}

cm_GotoPrevSelected(){  ;导航: 转到上一个选中的文件
    TC.SendPos(2054)
}

cm_GotoDriveA(){  ;导航: 转到驱动器 A
    TC.SendPos(2061)
}

cm_GotoDriveC(){  ;导航: 转到驱动器 C
    TC.SendPos(2063)
}

cm_GotoDriveD(){  ;导航: 转到驱动器 D
    TC.SendPos(2064)
}

cm_GotoDriveE(){  ;导航: 转到驱动器 E
    TC.SendPos(2065)
}

cm_GotoDriveF(){  ;导航: 可自定义其他驱动器
    TC.SendPos(2066)
}

cm_GotoDriveZ(){  ;导航: 最多 26 个
    TC.SendPos(2086)
}

;帮助 =========================================
cm_HelpIndex(){  ;帮助: 帮助索引
    TC.SendPos(610)
}

cm_Keyboard(){  ;帮助: 快捷键列表
    TC.SendPos(620)
}

cm_Register(){  ;帮助: 注册信息
    TC.SendPos(630)
}

cm_VisitHomepage(){  ;帮助: 访问 Totalcmd 网站
    TC.SendPos(640)
}

cm_About(){  ;帮助: 关于 Total Commander
    TC.SendPos(690)
}

;窗口 =========================================
cm_Exit(){  ;窗口: 退出 Total Commander
    TC.SendPos(24340)
}

cm_Minimize(){  ;窗口: 最小化 Total Commander
    TC.SendPos(2000)
}

cm_Maximize(){  ;窗口: 最大化 Total Commander
    TC.SendPos(2015)
}

cm_Restore(){  ;窗口: 恢复正常大小
    TC.SendPos(2016)
}

;命令行 =========================================
cm_ClearCmdLine(){  ;命令行: 清除命令行
    TC.SendPos(2004)
}

cm_NextCommand(){  ;命令行: 下一条命令
    TC.SendPos(2005)
}

cm_PrevCommand(){  ;命令行: 上一条命令
    TC.SendPos(2006)
}

cm_AddPathToCmdline(){  ;命令行: 将路径复制到命令行
    TC.SendPos(2019)
}

;工具 =========================================
cm_MultiRenameFiles(){  ;工具: 批量重命名
    TC.SendPos(2400)
}

cm_SysInfo(){  ;工具: 系统信息
    TC.SendPos(506)
}

cm_OpenTransferManager(){  ;工具: 后台传输管理器
    TC.SendPos(559)
}

cm_SearchFor(){  ;工具: 搜索文件
    TC.SendPos(501)
}

cm_SearchStandalone(){  ;工具: 在单独进程搜索文件
    TC.SendPos(545)
}

cm_FileSync(){  ;工具: 同步文件夹
    TC.SendPos(2020)
}

cm_Associate(){  ;工具: 文件关联
    TC.SendPos(507)
}

cm_InternalAssociate(){  ;工具: 定义内部关联
    TC.SendPos(519)
}

cm_CompareFilesByContent(){  ;工具: 比较文件内容
    TC.SendPos(2022)
}

cm_IntCompareFilesByContent(){  ;工具: 使用内部比较程序
    TC.SendPos(2040)
}

cm_CommandBrowser(){  ;工具: 浏览内部命令
    TC.SendPos(2924)
}

;视图 =========================================
cm_VisButtonbar(){  ;视图: 显示/隐藏: 工具栏
    TC.SendPos(2901)
}

cm_VisDriveButtons(){  ;视图: 显示/隐藏: 驱动器按钮
    TC.SendPos(2902)
}

cm_VisTwoDriveButtons(){  ;视图: 显示/隐藏: 两个驱动器按钮栏
    TC.SendPos(2903)
}

cm_VisFlatDriveButtons(){  ;视图: 切换: 平坦/立体驱动器按钮
    TC.SendPos(2904)
}

cm_VisFlatInterface(){  ;视图: 切换: 平坦/立体用户界面
    TC.SendPos(2905)
}

cm_VisDriveCombo(){  ;视图: 显示/隐藏: 驱动器列表
    TC.SendPos(2906)
}

cm_VisCurDir(){  ;视图: 显示/隐藏: 当前文件夹
    TC.SendPos(2907)
}

cm_VisBreadCrumbs(){  ;视图: 显示/隐藏: 路径导航栏
    TC.SendPos(2926)
}

cm_VisTabHeader(){  ;视图: 显示/隐藏: 排序制表符
    TC.SendPos(2908)
}

cm_VisStatusbar(){  ;视图: 显示/隐藏: 状态栏
    TC.SendPos(2909)
}

cm_VisCmdLine(){  ;视图: 显示/隐藏: 命令行
    TC.SendPos(2910)
}

cm_VisKeyButtons(){  ;视图: 显示/隐藏: 功能键按钮
    TC.SendPos(2911)
}

cm_ShowHint(){  ;视图: 显示文件提示
    TC.SendPos(2914)
}

cm_ShowQuickSearch(){  ;视图: 显示快速搜索窗口
    TC.SendPos(2915)
}

cm_SwitchLongNames(){  ;视图: 开启/关闭: 长文件名显示
    TC.SendPos(2010)
}

cm_RereadSource(){  ;视图: 刷新来源窗口
    TC.SendPos(540)
}

cm_ShowOnlySelected(){  ;视图: 仅显示选中的文件
    TC.SendPos(2023)
}

cm_SwitchHidSys(){  ;视图: 开启/关闭: 隐藏或系统文件显示
    TC.SendPos(2011)
}

cm_Switch83Names(){  ;视图: 开启/关闭: 8.3 式文件名小写显示
    TC.SendPos(2013)
}

cm_SwitchDirSort(){  ;视图: 开启/关闭: 文件夹按名称排序
    TC.SendPos(2012)
}

cm_DirBranch(){  ;视图: 展开所有文件夹
    TC.SendPos(2026)
}

cm_DirBranchSel(){  ;视图: 只展开选中的文件夹
    TC.SendPos(2046)
}

cm_50Percent(){  ;视图: 窗口分隔栏位于 50%
    TC.SendPos(909)
}

cm_100Percent(){  ;视图: 窗口分隔栏位于 100%
    TC.SendPos(910)
}

cm_VisDirTabs(){  ;视图: 显示/隐藏: 文件夹标签
    TC.SendPos(2916)
}

cm_VisXPThemeBackground(){  ;视图: 显示/隐藏: XP 主题背景
    TC.SendPos(2923)
}

cm_SwitchOverlayIcons(){  ;视图: 开启/关闭: 叠置图标显示
    TC.SendPos(2917)
}

cm_VisHistHotButtons(){  ;视图: 显示/隐藏: 文件夹历史记录和常用文件夹按钮
    TC.SendPos(2919)
}

cm_SwitchWatchDirs(){  ;视图: 启用/禁用: 文件夹自动刷新
    TC.SendPos(2921)
}

cm_SwitchIgnoreList(){  ;视图: 启用/禁用: 自定义隐藏文件
    TC.SendPos(2922)
}

cm_SwitchX64Redirection(){  ;视图: 开启/关闭: 32 位 system32 目录重定向(64 位 Windows)
    TC.SendPos(2925)
}

cm_SeparateTreeOff(){  ;视图: 关闭独立文件夹树面板
    TC.SendPos(3200)
}

cm_SeparateTree1(){  ;视图: 一个独立文件夹树面板
    TC.SendPos(3201)
}

cm_SeparateTree2(){  ;视图: 两个独立文件夹树面板
    TC.SendPos(3202)
}

cm_SwitchSeparateTree(){  ;视图: 切换独立文件夹树面板状态
    TC.SendPos(3203)
}

cm_ToggleSeparateTree1(){  ;视图: 开启/关闭: 一个独立文件夹树面板
    TC.SendPos(3204)
}

cm_ToggleSeparateTree2(){  ;视图: 开启/关闭: 两个独立文件夹树面板
    TC.SendPos(3205)
}

;用户 =========================================
cm_UserMenu1(){  ;用户: 用户菜单 1
    TC.SendPos(701)
}

cm_UserMenu2(){  ;用户: 用户菜单 2
    TC.SendPos(702)
}

cm_UserMenu3(){  ;用户: 用户菜单 3
    TC.SendPos(703)
}

cm_UserMenu4(){  ;用户: 用户菜单 4
    TC.SendPos(704)
}

cm_UserMenu5(){  ;用户: 用户菜单5
    TC.SendPos(705)
}

cm_UserMenu6(){  ;用户: 用户菜单6
    TC.SendPos(706)
}

cm_UserMenu7(){  ;用户: 用户菜单7
    TC.SendPos(707)
}

cm_UserMenu8(){  ;用户: 用户菜单8
    TC.SendPos(708)
}

cm_UserMenu9(){  ;用户: 用户菜单9
    TC.SendPos(709)
}

cm_UserMenu10(){  ;用户: 可定义其他用户菜单
    TC.SendPos(710)
}

;标签 =========================================
cm_OpenNewTab(){  ;标签: 新建标签
    TC.SendPos(3001)
}

cm_OpenNewTabBg(){  ;标签: 新建标签(在后台)
    TC.SendPos(3002)
}

cm_OpenDirInNewTab(){  ;标签: 新建标签(并打开光标处的文件夹)
    TC.SendPos(3003)
}

cm_OpenDirInNewTabOther(){  ;标签: 新建标签(在另一窗口打开文件夹)
    TC.SendPos(3004)
}

cm_SwitchToNextTab(){  ;标签: 下一个标签(Ctrl+Tab)
    TC.SendPos(3005)
}

cm_SwitchToPreviousTab(){  ;标签: 上一个标签(Ctrl+Shift+Tab)
    TC.SendPos(3006)
}

cm_CloseCurrentTab(){  ;标签: 关闭当前标签
    TC.SendPos(3007)
}

cm_CloseAllTabs(){  ;标签: 关闭所有标签
    TC.SendPos(3008)
    SetTimer TC_Timer_WaitMenuPop_CloseAllTabs
    return
    
    TC_Timer_WaitMenuPop_CloseAllTabs:
        winget, menupop, , ahk_class #32770
        if menupop{
            SetTimer, TC_Timer_WaitMenuPop_CloseAllTabs , Off
            send,{enter}
        }
    return
}

cm_DirTabsShowMenu(){  ;标签: 显示标签菜单
    TC.SendPos(3009)
}

cm_ToggleLockCurrentTab(){  ;标签: 锁定/解锁当前标签
    TC.SendPos(3010)
}

cm_ToggleLockDcaCurrentTab(){  ;标签: 锁定/解锁当前标签(可更改文件夹)
    TC.SendPos(3012)
}

cm_ExchangeWithTabs(){  ;标签: 交换左右窗口及其标签
    TC.SendPos(535)
}

cm_GoToLockedDir(){  ;标签: 转到锁定标签的根文件夹
    TC.SendPos(3011)
}

cm_SrcActivateTab1(){  ;标签: 来源窗口: 激活标签 1
    TC.SendPos(5001)
}

cm_SrcActivateTab2(){  ;标签: 来源窗口: 激活标签 2
    TC.SendPos(5002)
}

cm_SrcActivateTab3(){  ;标签: ...
    TC.SendPos(5003)
}

cm_SrcActivateTab4(){  ;标签: 最多 99 个
    TC.SendPos(5004)
}

cm_SrcActivateTab5(){  ;标签: 5
    TC.SendPos(5005)
}

cm_SrcActivateTab6(){  ;标签: 6
    TC.SendPos(5006)
}

cm_SrcActivateTab7(){  ;标签: 7
    TC.SendPos(5007)
}

cm_SrcActivateTab8(){  ;标签: 8
    TC.SendPos(5008)
}

cm_SrcActivateTab9(){  ;标签: 9
    TC.SendPos(5009)
}

cm_SrcActivateTab10(){  ;标签: 0
    TC.SendPos(5010)
}

cm_TrgActivateTab1(){  ;标签: 目标窗口: 激活标签 1
    TC.SendPos(5101)
}

cm_TrgActivateTab2(){  ;标签: 目标窗口: 激活标签 2
    TC.SendPos(5102)
}

cm_TrgActivateTab3(){  ;标签: ...
    TC.SendPos(5103)
}

cm_TrgActivateTab4(){  ;标签: 最多 99 个
    TC.SendPos(5104)
}

cm_TrgActivateTab5(){  ;标签: 5
    TC.SendPos(5105)
}

cm_TrgActivateTab6(){  ;标签: 6
    TC.SendPos(5106)
}

cm_TrgActivateTab7(){  ;标签: 7
    TC.SendPos(5107)
}

cm_TrgActivateTab8(){  ;标签: 8
    TC.SendPos(5108)
}

cm_TrgActivateTab9(){  ;标签: 9
    TC.SendPos(5109)
}

cm_TrgActivateTab10(){  ;标签: 0
    TC.SendPos(5110)
}

cm_LeftActivateTab1(){  ;标签: 左窗口: 激活标签 1
    TC.SendPos(5201)
}

cm_LeftActivateTab2(){  ;标签: 左窗口: 激活标签 2
    TC.SendPos(5202)
}

cm_LeftActivateTab3(){  ;标签: ...
    TC.SendPos(5203)
}

cm_LeftActivateTab4(){  ;标签: 最多 99 个
    TC.SendPos(5204)
}

cm_LeftActivateTab5(){  ;标签: 5
    TC.SendPos(5205)
}

cm_LeftActivateTab6(){  ;标签: 6
    TC.SendPos(5206)
}

cm_LeftActivateTab7(){  ;标签: 7
    TC.SendPos(5207)
}

cm_LeftActivateTab8(){  ;标签: 8
    TC.SendPos(5208)
}

cm_LeftActivateTab9(){  ;标签: 9
    TC.SendPos(5209)
}

cm_LeftActivateTab10(){  ;0
    TC.SendPos(5210)
}

cm_RightActivateTab1(){  ;右窗口: 激活标签 1
    TC.SendPos(5301)
}

cm_RightActivateTab2(){  ;右窗口: 激活标签 2
    TC.SendPos(5302)
}

cm_RightActivateTab3(){  ;...
    TC.SendPos(5303)
}

cm_RightActivateTab4(){  ;最多 99 个
    TC.SendPos(5304)
}

cm_RightActivateTab5(){  ;5
    TC.SendPos(5305)
}

cm_RightActivateTab6(){  ;6
    TC.SendPos(5306)
}

cm_RightActivateTab7(){  ;7
    TC.SendPos(5307)
}

cm_RightActivateTab8(){  ;8
    TC.SendPos(5308)
}

cm_RightActivateTab9(){  ;9
    TC.SendPos(5309)
}

cm_RightActivateTab10(){  ;0
    TC.SendPos(5310)
}

;排序 =========================================
cm_SrcSortByCol1(){  ;来源窗口: 按第 1 列排序
    TC.SendPos(6001)
}

cm_SrcSortByCol2(){  ;来源窗口: 按第 2 列排序
    TC.SendPos(6002)
}

cm_SrcSortByCol3(){  ;...
    TC.SendPos(6003)
}

cm_SrcSortByCol4(){  ;最多 99 列
    TC.SendPos(6004)
}

cm_SrcSortByCol5(){  ;5
    TC.SendPos(6005)
}

cm_SrcSortByCol6(){  ;6
    TC.SendPos(6006)
}

cm_SrcSortByCol7(){  ;7
    TC.SendPos(6007)
}

cm_SrcSortByCol8(){  ;8
    TC.SendPos(6008)
}

cm_SrcSortByCol9(){  ;9
    TC.SendPos(6009)
}

cm_SrcSortByCol10(){  ;0
    TC.SendPos(6010)
}

cm_SrcSortByCol99(){  ;9
    TC.SendPos(6099)
}

cm_TrgSortByCol1(){  ;目标窗口: 按第 1 列排序
    TC.SendPos(6101)
}

cm_TrgSortByCol2(){  ;目标窗口: 按第 2 列排序
    TC.SendPos(6102)
}

cm_TrgSortByCol3(){  ;...
    TC.SendPos(6103)
}

cm_TrgSortByCol4(){  ;最多 99 列
    TC.SendPos(6104)
}

cm_TrgSortByCol5(){  ;5
    TC.SendPos(6105)
}

cm_TrgSortByCol6(){  ;6
    TC.SendPos(6106)
}

cm_TrgSortByCol7(){  ;7
    TC.SendPos(6107)
}

cm_TrgSortByCol8(){  ;8
    TC.SendPos(6108)
}

cm_TrgSortByCol9(){  ;9
    TC.SendPos(6109)
}

cm_TrgSortByCol10(){  ;0
    TC.SendPos(6110)
}

cm_TrgSortByCol99(){  ;9
    TC.SendPos(6199)
}

cm_LeftSortByCol1(){  ;左窗口: 按第 1 列排序
    TC.SendPos(6201)
}

cm_LeftSortByCol2(){  ;左窗口: 按第 2 列排序
    TC.SendPos(6202)
}

cm_LeftSortByCol3(){  ;...
    TC.SendPos(6203)
}

cm_LeftSortByCol4(){  ;最多 99 列
    TC.SendPos(6204)
}

cm_LeftSortByCol5(){  ;5
    TC.SendPos(6205)
}

cm_LeftSortByCol6(){  ;6
    TC.SendPos(6206)
}

cm_LeftSortByCol7(){  ;7
    TC.SendPos(6207)
}

cm_LeftSortByCol8(){  ;8
    TC.SendPos(6208)
}

cm_LeftSortByCol9(){  ;9
    TC.SendPos(6209)
}

cm_LeftSortByCol10(){  ;0
    TC.SendPos(6210)
}

cm_LeftSortByCol99(){  ;9
    TC.SendPos(6299)
}

cm_RightSortByCol1(){  ;右窗口: 按第 1 列排序
    TC.SendPos(6301)
}

cm_RightSortByCol2(){  ;右窗口: 按第 2 列排序
    TC.SendPos(6302)
}

cm_RightSortByCol3(){  ;...
    TC.SendPos(6303)
}

cm_RightSortByCol4(){  ;最多 99 列
    TC.SendPos(6304)
}

cm_RightSortByCol5(){  ;5
    TC.SendPos(6305)
}

cm_RightSortByCol6(){  ;6
    TC.SendPos(6306)
}

cm_RightSortByCol7(){  ;7
    TC.SendPos(6307)
}

cm_RightSortByCol8(){  ;8
    TC.SendPos(6308)
}

cm_RightSortByCol9(){  ;9
    TC.SendPos(6309)
}

cm_RightSortByCol10(){  ;0
    TC.SendPos(6310)
}

cm_RightSortByCol99(){  ;9
    TC.SendPos(6399)
}

;自定义列视图 =========================================
cm_SrcCustomView1(){  ;来源窗口: 自定义列视图 1
    TC.SendPos(271)
}

cm_SrcCustomView2(){  ;来源窗口: 自定义列视图 2
    TC.SendPos(272)
}

cm_SrcCustomView3(){  ;...
    TC.SendPos(273)
}

cm_SrcCustomView4(){  ;最多 29 个
    TC.SendPos(274)
}

cm_SrcCustomView5(){  ;5
    TC.SendPos(275)
}

cm_SrcCustomView6(){  ;6
    TC.SendPos(276)
}

cm_SrcCustomView7(){  ;7
    TC.SendPos(277)
}

cm_SrcCustomView8(){  ;8
    TC.SendPos(278)
}

cm_SrcCustomView9(){  ;9
    TC.SendPos(279)
}

cm_LeftCustomView1(){  ;左窗口: 自定义列视图 1
    TC.SendPos(710)
}

cm_LeftCustomView2(){  ;左窗口: 自定义列视图 2
    TC.SendPos(72)
}

cm_LeftCustomView3(){  ;...
    TC.SendPos(73)
}

cm_LeftCustomView4(){  ;最多 29 个
    TC.SendPos(74)
}

cm_LeftCustomView5(){  ;5
    TC.SendPos(75)
}

cm_LeftCustomView6(){  ;6
    TC.SendPos(76)
}

cm_LeftCustomView7(){  ;7
    TC.SendPos(77)
}

cm_LeftCustomView8(){  ;8
    TC.SendPos(78)
}

cm_LeftCustomView9(){  ;9
    TC.SendPos(79)
}

cm_RightCustomView1(){  ;右窗口: 自定义列视图 1
    TC.SendPos(171)
}

cm_RightCustomView2(){  ;右窗口: 自定义列视图 2
    TC.SendPos(172)
}

cm_RightCustomView3(){  ;...
    TC.SendPos(173)
}

cm_RightCustomView4(){  ;最多 29 个
    TC.SendPos(174)
}

cm_RightCustomView5(){  ;5
    TC.SendPos(175)
}

cm_RightCustomView6(){  ;6
    TC.SendPos(176)
}

cm_RightCustomView7(){  ;7
    TC.SendPos(177)
}

cm_RightCustomView8(){  ;8
    TC.SendPos(178)
}

cm_RightCustomView9(){  ;9
    TC.SendPos(179)
}

cm_SrcNextCustomView(){  ;来源窗口: 下一个自定义视图
    TC.SendPos(5501)
}

cm_SrcPrevCustomView(){  ;来源窗口: 上一个自定义视图
    TC.SendPos(5502)
}

cm_TrgNextCustomView(){  ;目标窗口: 下一个自定义视图
    TC.SendPos(5503)
}

cm_TrgPrevCustomView(){  ;目标窗口: 上一个自定义视图
    TC.SendPos(5504)
}

cm_LeftNextCustomView(){  ;左窗口: 下一个自定义视图
    TC.SendPos(5505)
}

cm_LeftPrevCustomView(){  ;左窗口: 上一个自定义视图
    TC.SendPos(5506)
}

cm_RightNextCustomView(){  ;右窗口: 下一个自定义视图
    TC.SendPos(5507)
}

cm_RightPrevCustomView(){  ;右窗口: 上一个自定义视图
    TC.SendPos(5508)
}

cm_LoadAllOnDemandFields(){  ;所有文件都按需加载备注
    TC.SendPos(5512)
}

cm_LoadSelOnDemandFields(){  ;仅选中的文件按需加载备注
    TC.SendPos(5513)
}

cm_ContentStopLoadFields(){  ;停止后台加载备注
    TC.SendPos(5514)
}
