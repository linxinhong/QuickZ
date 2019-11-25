#Persistent
#SingleInstance, force
SetBatchLines, -1

QZM.Listen(A_ScriptDir "\ui", 8001)

return

Class QZM {

    static _instance := new QZM()

    Listen(dir, port:=8000) {
        QZM._instance.rootdir := dir
        QZM._instance.port := port 
        QZM._instance.server := new HttpServer()
        QZM._instance.server.LoadMimes(A_ScriptDir . "/lib/mime.types")
        QZM._instance.server.serve(port)
        QZM.LoadAPI()
        QZM.LoadFiles()
        QZM._instance.server.SetPaths(QZM._instance.paths)
    }

    LoadAPI() {
        QZM._instance.paths["/API/"] := objBindMethod(QZM, "API")
    }

    LoadFiles() {
        Loop Files, % QZM._instance.rootdir "\*", R 
        {
            QZM._instance.paths[StrReplace(SubStr(PathRelativeTo(A_LoopFileFullPath, QZM._instance.rootdir), 2), "\", "/")] := objBindMethod(QZM, "File")
        }
    }

    API(ByRef req, ByRef res, ByRef server) {
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

    class instance {
        __new() {
            this.rootdir := dir
            this.port := 0
            this.paths := {}
            this.server := {}
        }
    }
}

!z::reload

#include, lib\AHKhttp.ahk
#include, lib\AHKsock.ahk
#include, lib\Path_API.ahk
#include, lib\class_json.ahk