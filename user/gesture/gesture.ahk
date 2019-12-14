gesture_init() {
}

gesture() {

}

WinMinimize() {
  WinMinimize, A
}
WinClose() {
  WinClose, A
}
WinMaximize() {
  WinMaximize, A
}

calc() {
  run calc
}

copy() {
  send ^c
}

paste() {
  send ^v
}
tess_sendnum() {
  send {enter}
  send {tab}
  send {tab}
  sleep 50
  send ^a
  send 0
  send {enter}
  send {tab}
  sleep 50
  send ^a
  send 0
  send {enter}
  send {tab}
  sleep 50
  send ^a
  send 16
  send {enter}
  send {tab}
  sleep 50
  send ^a
  send 16
  send {enter}
  send ^s
}

ctrla() {
  send ^a
  sleep 50
  send ^c
}