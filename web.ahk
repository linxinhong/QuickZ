#Persistent
#SingleInstance, force
SetBatchLines, -1

QZM.Listen(A_ScriptDir "\ui", 5210)

return

Class QZM {

    static _instance := new QZM.instance()

    class instance {
        __new() {
            this.rootdir := dir
            this.config := A_ScriptDir "\user\config.json"
            this.port := 0
            this.paths := {}
            this.server := {}
        }
    }

    Listen(dir, port:=8000) {
        QZM._instance.rootdir := dir
        QZM._instance.port := port 
        QZM._instance.server := new HttpServer()
        QZM._instance.server.LoadMimes(A_ScriptDir . "/lib/mime.types")
        QZM._instance.server.serve(port)
        QZM.LoadFiles()
        QZM.LoadAPI()
        QZM._instance.server.SetPaths(QZM._instance.paths)
    }

    LoadFiles() {
        Loop Files, % QZM._instance.rootdir "\*", R 
        {
            QZM._instance.paths[StrReplace(SubStr(PathRelativeTo(A_LoopFileFullPath, QZM._instance.rootdir), 2), "\", "/")] := objBindMethod(QZM, "File")
        }
    }

    File(ByRef req, ByRef res, ByRef server) {
        file := QZM._instance.rootdir StrReplace(req.path, "/", "\")
        if (FileExist(file)) {
            server.ServeFile(res, file)
            res.status := 200
        }
        else {
            res.SetBodyText("not found")
            res.status := 404
        }
    }

    LoadAPI() {
        QZM._instance.paths["/api/config"] := objBindMethod(QZM, "API")
    }

    /*
        /api/manager/start
        /api/manager/stop
        /api/config
    */

    API(ByRef req, ByRef res, ByRef server) {
        if (req.path == "/api/config") {
            if (req.method == "GET") {
                if (not FileExist(QZM._instance.config)) {
                    body := json.dump({})
                    FileAppend, % body , % QZM._instance.config
                }
                else {
                    FileRead, body, % QZM._instance.config
                }
                res.SetBodyText(body)
                res.status := 200
            }
            else if (req.method == "POST") {
                FileDelete, % QZM._instance.config
                FileAppend, % req.body , % QZM._instance.config
                res.status := 200
            }
        }
    }

}

!z::reload

#include, lib\AHKhttp.ahk
#include, lib\AHKsock.ahk
#include, lib\Path_API.ahk
#include, lib\class_json.ahk