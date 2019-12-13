everything_init() {
    quickz.SetCommand("everything_change_to_insert", "切换到Insert模式")
    quickz.SetCommand("everything_change_to_normal", "切换到Noraml模式")
    quickz.SetCommand("everything_filter_all", "筛选器-所有")
    quickz.SetCommand("everything_filter_music", "筛选器-音频")
    quickz.SetCommand("everything_filter_compress", "筛选器-压缩文件")
    quickz.SetCommand("everything_filter_document", "筛选器-文档")
    quickz.SetCommand("everything_filter_exec", "筛选器-可执行文件")
    quickz.SetCommand("everything_filter_folder", "筛选器-文件夹")
    quickz.SetCommand("everything_filter_image", "筛选器-图片")
    quickz.SetCommand("everything_filter_video", "筛选器-视频")
}

everything_filter_all() {
    everything_filter("所有")
}
everything_filter_music() {
    everything_filter("音频")
}
everything_filter_compress() {
    everything_filter("压缩文件")
}
everything_filter_document() {
    everything_filter("文档")
}
everything_filter_exec() {
    everything_filter("可执行文件")
}
everything_filter_folder() {
    everything_filter("文件夹")
}
everything_filter_image() {
    everything_filter("图片")
}
everything_filter_video() {
    everything_filter("视频")
}

everything_filter(string) {
    Control, ChooseString, % string, ComboBox1, ahk_class EVERYTHING
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
        vimd.SendRaw("everything")
    }
    ControlGetFocus, focusCtrl, A
    if (focusCtrl == "Edit1") {
        vimd.SendRaw("everything")
    }
}

everything_rename() {
    send {f2}
    everything_change_to_insert()
}