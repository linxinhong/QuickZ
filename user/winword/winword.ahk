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
