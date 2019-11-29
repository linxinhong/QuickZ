everything_init() {
    vimd.action("everything_change_to_insert", "切换到Insert模式")
    vimd.action("everything_change_to_normal", "切换到Noraml模式")
    vimd.action("everything_filter_video", "筛选器-视频")
    vimd.action("everything_filter_all", "筛选器-所有")
    vimd.action("everything_filter_music", "筛选器-音频")
    vimd.action("everything_filter_compress", "筛选器-压缩文件")
    vimd.action("everything_filter_document", "筛选器-文档")
    vimd.action("everything_filter_exec", "筛选器-可执行文件")
    vimd.action("everything_filter_folder", "筛选器-文件夹")
    vimd.action("everything_filter_image", "筛选器-图片")
    vimd.action("everything_filter_video", "筛选器-视频")
}

everything_filter_all() {
    everything_filter("所有") {
}

everything_filter(string) {
    ; quickz.plugins.everything.config.language
    Control, ChooseString, % string, ComboBox1, A
}

everything_change_to_insert() {
    vimd.changeMode("everything", "insert")
}

everything_change_to_normal() {
    vimd.changeMode("everything", "normal")
}

everything_BeforeKey() {
    WinGet, MenuID, ID, AHK_CLASS #32768
    if (MenuID) {
        vimd.SendRaw("et")
    }
    ControlGetFocus, focusCtrl, A
    if (focusCtrl == "Edit1") {
        vimd.SendRaw("et")
    }
}