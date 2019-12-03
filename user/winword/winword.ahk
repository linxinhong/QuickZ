winword_init(){
    vimd.setWin("winword", {winExe: "winword.exe"
                                    ,maxCount: 999
                                    ,timeOut: 500})
    vimd.mapNum("winword", "normal")
    vimd.map("winword", "normal", "j", "down")
    vimd.map("winword", "normal", "k", "up")
    vimd.map("winword", "normal", "h", "left")
    vimd.map("winword", "normal", "l", "right")
    vimd.map("winword", "normal", "u", "winword_undo")
    vimd.map("winword", "normal", "i", "winword_change_to_insert")
    vimd.map("winword", "normal", "I", "winword_change_to_insert_LineHeader")
    vimd.map("winword", "normal", "A", "winword_change_to_insert_LineEnd")
    vimd.map("winword", "insert", "<esc>", "winword_change_to_normal")
    vimd.changeMode("winword", "normal")
}

winword_change_to_insert() {
    vimd.changeMode("winword", "insert")
}

winword_change_to_insert_lineHeader() {
    vimd.changeMode("winword", "insert")
    sendinput {HOME}
}

winword_change_to_insert_lineEnd() {
    vimd.changeMode("winword", "insert")
    sendinput {End}
}

winword_change_to_normal() {
    vimd.changeMode("winword", "normal")
}

winword_undo() {
    send ^z
}
