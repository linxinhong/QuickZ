general_init() {
    vimd.action("donw", "向下移动")
    vimd.action("up", "向上移动")
    vimd.action("left", "向左移动")
    vimd.action("right", "向右移动")
    vimd.action("menuActive", "选择并激活菜单")
    vimd.action("repeat", "重复上一次操作")
}

repeat() {
    vimd.repeat()
}

menuActive() {
    menuz.Active()
}

down() {
    send {down}
}

up() {
    send {up}
}

left() {
    send {left}
}

right() {
    send {right}
}