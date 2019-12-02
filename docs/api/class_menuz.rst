
.. highlight:: autohotkey

Class_MenuZ
===========

处理快速菜单的核心API

.. attribute:: menuz.self

    clsas menuz 拥有一个静态的属性 *self*, 保存 menuz 的核心属性

    .. code-block:: ahk

        menuz.self := new menuz._self()

.. class:: self

    .. attribute:: self.onGetClip 

        获取环境信息时，默认使用 *Ctrl + C / Ctrl + Insert* 的方式进行复制，然后获取选中的信息，此属性可以指定函数，当复制之前执行一次此函数，用于自定义获取选中信息。

        执行函数时，会传入两个参数，分别是当前环境对象 Env 和事件 GetClip / GetWin

        .. code-block:: ahk

            menuz.self.onGetClip := "myGetClip"

            myGetClip(env, event) {
                if (event == "GetClip") {
                    if (env.winExe == "gvim.exe") {
                        clipBackup := ClipboardAll
                        Clipboard := ""
                        SendRaw "+y
                        ClipWait, % env.config.ClipTimeOut, 1
                        env.isWin := ErrorLevel
                        clipData := Clipboard

                        ; 告知 MenuZ 已经获取好选中信息
                        env.isGetClip := true

                        env.isText := true
                        env.text := clipData
                    }
                }
            }

    .. attribute:: self.onGetWin

        与 onGetClip 类似，此属性用于获取当前的 Win 环境，默认是使用 *WinGet** 系列函数获取。
        
        需要自定义获取窗口信息时，请指定此属性。

    .. attribute:: self.ClipUseInsert

        False : 使用 *Ctrl + C* 进行复制获取选中信息

        True  ：使用 *Ctrl + Insert* 进行复制

        默认值为 False

    .. attribute:: self.ClipTimeOut

        复制的超时时间，单位为毫秒，默认为 400 毫秒。

.. method:: config(cnf)

    传入对象，配置 MenuZ 的选项，和直接指定 menuz.self 一样的效果。

    .. code-block:: ahk

        menuz.config({ClipTimeOut: 400
            ,ClipUseInsert: false
            ,onGetWin: ""
            ,onGetClip: "myGetClip"})
    
.. method:: Active( )

    激活 MenuZ 获取当前环境信息，保存到 Env 对象，并根据环境信息生成菜单

    .. code-block:: ahk

        !q:: menuz.Active()
