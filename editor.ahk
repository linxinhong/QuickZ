#Persistent
#SingleInstance, force
SetBatchLines, -1
FileEncoding, UTF-8
quickz.LoadPlugins()
quickz.GenerateInclude()

QZM.Listen(A_ScriptDir "\ui", 5210)
;Gui Add, ActiveX, x0 y0 w980 h640 vWB, Shell.Explorer 
;Gui Show, w980 h640, QuickZ 配置
;WB.Navigate("http://127.0.0.1:5210/")  
run http://127.0.0.1:5210

return

Class QZM {

    static self := new QZM._instance()

    class _instance {
        __new() {
            this.rootdir := dir
            this.config := A_ScriptDir "\user\config.json"
            this.port := 0
            this.paths := {}
            this.routes := {}
            this.server := {}
        }
    }

    Listen(dir, port:=8000) {
        QZM.self.rootdir := dir
        QZM.self.port := port 
        QZM.self.server := new HttpServer()
        QZM.self.server.LoadMimes(A_ScriptDir . "/lib/mime.types")
        QZM.self.server.serve(port)
        ; 设置路由
        QZM.self.routes.push({path: "/api", func: objBindMethod(QZM, "API")})
        QZM.self.routes.push({path: "/", func: objBindMethod(QZM, "File")})
        QZM.self.server.SetRoutes(QZM.self.routes)
    }

    File(ByRef req, ByRef res, ByRef server) {
        file := QZM.self.rootdir ( req.path == "/" ? "/index.html" : StrReplace(req.path, "/", "\") )
        if (FileExist(file)) {
            server.ServeFile(res, file)
            res.status := 200
        }
        else {
            res.SetBodyText("not found")
            res.status := 404
        }
    }

    /*
        /api/start
        /api/stop
        /api/config
        /api/FileSelectFile
        /api/FileSelectFolder
        /api/generateicon
        /api/getvimddefined
    */

    API(ByRef req, ByRef res, ByRef server) {
        if (req.path == "/api/config") {
            QZM.Config(req, res, server)
        }
        else if (req.path == "/api/fileselectfile") {
            QZM.FileSelectFile(req, res, server)
        }
        else if (req.path == "/api/fileselectfolder") {
            QZM.FileSelectFolder(req, res, server)
        }
        else if (req.path == "/api/generateicon") {
            QZM.GenerateIcon(req, res, server)
        }
        else if (req.path == "/api/generateiconlist") {
            QZM.GenerateIconList(req, res, server)
        }
        else if (req.path == "/api/savefavicon") {
            QZM.SaveFavIcon(req, res, server)
        }
        else {
            res.NotFound()
        }
    }

    FileSelectFile(byRef req, byRef res, byRef server) {
        res.SetBodyText("waiting")
        FileSelectFile, filepath, , % A_ScriptDir, 选择文件
        res.SetBodyText(filePath)
        res.status := 200
    }

    FileSelectFolder(byRef req, byRef res, byRef server) {
        res.SetBodyText("waiting")
        FileSelectFolder, folderPath, , , 选择目录
        res.SetBodyText(folderPath)
        res.status := 200
    }

    GenerateIconList_search_file(iconpath, iconnumber) {
        iconList := {}
        SplitPath, iconpath, , , ext
        if (InStr(",exe,ico,dll,icl,", "," ext ",")) {
            if (not StrLen(iconNumber)) {
                Loop 9999 {
                    iconindex := A_Index - 1
                    DllCall("PrivateExtractIcons", "Str", iconpath, "Int", iconindex, "Int", 16, "Int", 16, "PTR*", Icon, "PTR*", 0, "UInt", 1, "UInt", 0, "Int")
                    if (ErrorLevel) {
                        break
                    }
                    if (icon) {
                        iconList.push(iconpath ":" iconindex)
                    }
                    else {
                        break
                    }
                }
            }
            else {
                DllCall("PrivateExtractIcons", "Str", iconpath, "Int", iconNumber, "Int", 16, "Int", 16, "PTR*", Icon, "PTR*", 0, "UInt", 1, "UInt", 0, "Int")
                if (icon) {
                    iconList.push(iconpath ":" iconNumber)
                }
            }
        }
        else {
            iconList.push(iconpath ":" (iconNumber is integer ? iconNumber : "0" ))
        }
        return iconList
    }

    GenerateIconList(byRef req, byRef res, byRef server) {
        if (req.method == "GET") {
            query := req.queries["query"]
            pos := RegExMatch(query , ":(\d+)$")
            if (pos) {
                filepath := Substr(query, 1, pos-1)
                iconNumber := Substr(query, pos+1)
            }
            else {
                filepath := query
            }
            if (FileExist(filepath)) {
                if InStr(filepath, "*") {
                    iconList := {}
                    Loop, Files, %filepath%, RF
                    {
                        iconlist_once := QZM.GenerateIconList_search_file(A_LoopFileFullPath, "")
                        Loop, % iconlist_once.MaxIndex()
                        {
                            iconList.push(iconlist_once[A_Index])
                        }
                    }
                }
                else {
                    iconList := QZM.GenerateIconList_search_file(filepath, iconNumber)
                }
                res.SetBodyText(json.dump(iconList))
                res.headers["Content-Type"] := "application/json"
                res.status := 200
            }
            else {
                res.SetBodyText("[]")
                res.status := 200
            }
        }
    }

    GenerateIcon(byRef req, byRef res, byRef server) {
        if (req.method == "GET") {
            filepath := req.queries["filepath"]
            IconNumber := req.queries["number"] is integer ? req.queries["number"] : 0
            if (FileExist(filepath)) {
                SplitPath, filePath, , , ext
                gdip_tokent := Gdip_StartUp()
                if (InStr(",exe,ico,dll,icl,png,", "," ext ",")) {
                    pbitmap := Gdip_createBitmapFromFile(filePath, iconNumber, 16)
                }
                else {
                    SHGFI_TYPENAME = 0x000000400
                    SHGFI_DISPLAYNAME = 0x000000200
                    SHGFI_ICON = 0x000000100
                    SHGFI_ATTRIBUTES = 0x000000800
                    MAX_PATH := 260
                    SHFILEINFO := "
                    (
                    INT_PTR hIcon;
                    DWORD   iIcon;
                    DWORD   dwAttributes;
                    WCHAR   szDisplayName[" MAX_PATH "];
                    WCHAR   szTypeName[80];
                    )"
                    SHFO := Struct(SHFILEINFO)
                    DllCall("Shell32\SHGetFileInfo" . (A_IsUnicode ? "W":"A"), "str", FilePath, "uint", 0, "ptr", SHFO[""], "uint", sizeof(SHFILEINFO), "uint", SHGFI_TYPENAME|SHGFI_DISPLAYNAME|SHGFI_ICON|SHGFI_ATTRIBUTES)
                    pBitmap := Gdip_createBitmapFromHICON(SHFO.hIcon)
                    ; Gdip_SaveBitmapToFile(pBitmap, iconFile, 100)
                }
                length := Gdip_SaveBitmapToStream(pbitmap, data)
                res.SetBody(data, length)
                res.headers["Content-Type"] := "image/png"
                Gdip_ShutDown(gdip_tokent)
                res.status := 200
            }
            else {
                res.SetBodyText("")
                res.status := 404
            }
        }
    }

    SaveFavIcon(byRef req, byRef res, byRef server) {
        if (req.method == "GET") {
            filepath := req.queries["filepath"]
            IconNumber := req.queries["number"] is integer ? req.queries["number"] : 0
            savefilepath := A_ScriptDir "\User\icons\" md5(filepath "|" iconNumber) ".png"
            if (FileExist(filepath)) {
                SplitPath, filePath, , , ext
                gdip_tokent := Gdip_StartUp()
                if (InStr(",exe,ico,dll,icl,png,", "," ext ",")) {
                    pbitmap := Gdip_createBitmapFromFile(filePath, iconNumber, 16)
                }
                else {
                    SHGFI_TYPENAME = 0x000000400
                    SHGFI_DISPLAYNAME = 0x000000200
                    SHGFI_ICON = 0x000000100
                    SHGFI_ATTRIBUTES = 0x000000800
                    MAX_PATH := 260
                    SHFILEINFO := "
                    (
                    INT_PTR hIcon;
                    DWORD   iIcon;
                    DWORD   dwAttributes;
                    WCHAR   szDisplayName[" MAX_PATH "];
                    WCHAR   szTypeName[80];
                    )"
                    SHFO := Struct(SHFILEINFO)
                    DllCall("Shell32\SHGetFileInfo" . (A_IsUnicode ? "W":"A"), "str", FilePath, "uint", 0, "ptr", SHFO[""], "uint", sizeof(SHFILEINFO), "uint", SHGFI_TYPENAME|SHGFI_DISPLAYNAME|SHGFI_ICON|SHGFI_ATTRIBUTES)
                    pBitmap := Gdip_createBitmapFromHICON(SHFO.hIcon)
                }
                Gdip_SaveBitmapToFile(pBitmap, savefilepath, 100)
                Gdip_ShutDown(gdip_tokent)
                res.SetBodyText(savefilepath)
                res.status := 200
            }
            else {
                res.status := 200
            }
        }
    }


    Config(byRef req, byRef res, byRef server) {
        if (req.method == "GET") {
            if (not FileExist(QZM.self.config)) {
                body := json.dump({})
                FileAppend, % body , % QZM.self.config
            }
            server.ServeFile(res, QZM.self.config)
            ; res.headers["Content-Type"] = "application/json; charset=utf-8"
            res.status := 200
        }
        else if (req.method == "POST") {
            FileDelete, % QZM.self.config
            FileAppend, % req.body , % QZM.self.config
            quickz.SendWMData("reload")
            res.SetBodyText("ok")
            res.status := 200
        }
        else {
            res.SetBodyText("unknow request method")
            res.status := 404
        }
    }

}

#include, lib\AHKhttp.ahk
#include, lib\AHKsock.ahk
#include, lib\class_json.ahk
#include, lib\class_quickz.ahk
#include, lib\Path_API.ahk
