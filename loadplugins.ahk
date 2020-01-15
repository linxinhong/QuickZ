#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

quickz.LoadPlugins()
quickz.GenerateInclude()
; quickz.InitPlugins()

exitApp

#include lib\class_quickz.ahk
#include lib\Path_API.ahk
#include lib\class_json.ahk
