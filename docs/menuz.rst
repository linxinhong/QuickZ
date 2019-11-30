MenuZ 介绍
----------------

MenuZ 模块的最基本工作流程：

1. 鼠标移动至需要选择的内容，可以是资源管理器中的某个文件，也可以是一段文字。

2. 按下快捷键（默认是 *Alt + Q*)

3. 菜单根据选中的内容进行处理，显示出匹配 "选中内容" 的菜单项

4. 点击执行菜单预定义的功能。

使用 MenuZ 需要进行菜单项的定义，包括菜单名称和样式，菜单项在什么条件下出现，以及执行哪些功能。

为了方便定义菜单项，MenuZ 的定义语法沿用了 Candy 的一些语法，所以你会看到类似于这样的标签:

.. code-block::

    {file:path}

    {ext:= txt, ini, json}

不要担心，这个语法并不难，因为经常用的标签就几个。当你需要复杂场景的时候，再查询可用标签即可。

.. tip::

    QuickZ 鼓励你在遇到某个重复操作时并大量花费时间的情况下进行配置，而不是设想场景然后配置用不到的功能。

.. attention::

    接下来你需要了解：

    1. MenuZ能够选中哪些内容？

    2. 怎样定义一个菜单？

    3. 怎样让菜单根据选择的内容来决定是否显示？

选中内容
----------------

MenuZ 模块会将选中的内容保存一个环境信息( env )

这个环境信息 ( env ) 保存的内容如下：

.. image:: ./_static/menuz-select-type.png

鼠标焦点选中了内容，MenuZ 会自动将选中的内容进行分析

文件
^^^^^

标记当前选中了文件，然后进一步分析出文件全路径、文件名、文件后缀名等。


.. note:: 

    选中文件示例：

    .. code-block:: 

        C:\\dir\\quickz.txt

    MenuZ 模块的处理如下：

    .. code-block::

        env.isFile          标记是否选中文件       True
        env.isFileMulti     标记是否选中多个文件   False
        env.file.path       文件路径              C:\dir\quickz.txt
        env.file.name       文件名                quickz.txt
        env.file.dir        文件目录              C:\dir
        env.file.ext        文件后缀              txt
        env.file.namenoext  文件路径              quickz
        env.file.drive      驱动器名              C


文本
^^^^^

标记当前选中了文本，并获取纯文本内容。

.. note::

    选择示例:

    .. code-block:: 

        abcdefg 中文

    MenuZ 模块的处理如下：

    .. code-block:: 

        env.isText          标记当前选中文本     True
        env.text            文本                abcdefg 中文

窗口
^^^^^^

无论是否选中内容，窗口信息都会被获取。

.. note:: 

    当 Notepad 记事本程序上获取窗口信息

    MenuZ 模块的处理如下：

    .. code-block::

        env.isWin     标记当前选中文本            True
        env.x         当前鼠标的 x 座标           324    
        env.y         当前鼠标的 y 座标           230
        env.winHwnd   当前的 Hwnd 值              0xf3d38028
        env.winClass  当前的 Class 值,区分大小写   Notepad
        env.winExe    当前的程序名                notepad.exe
        env.winExeFullPath  完整程序名            C:\windows\notepad.exe
        env.winControl  当前控件名                Edit1
        env.winTitle   当前程序标题名             无标题 - 记事本


菜单项
----------------

名称 (name)
^^^^^^^^^^^

菜单的名称，名称无特殊限制。

如需要指定菜单项的快捷键，请通过添加 ``&`` 字符实现。例如:

``&Notepad`` 显示出的结果是 ``Notepad`` ，并支持 ``N`` 键激活

如果需要对齐菜单名称，请通过添加 ``>>`` 实现，例如：

``记事本>>(&N)`` 显示出的名称为 ``记事本              (&N)``

图标 (icon)
^^^^^^^^^^^

.. image:: ./_static/menuz-item-icon.png

为了方便标识菜单，菜单项支持添加图标展示。

图标值由图标资源文件 + 图标编号组成，图标编号需要添加，写法如下：

``C:\windows\notepad.exe:0``

图标资源文件支持多种格式，包括：

``.ico``  ``.exe`` ``.dll`` ``.icl``

图标值支持使用变量。


文字颜色 (tcolor)
^^^^^^^^^^^^^^^^^


背景颜色 (bgcolor)
^^^^^^^^^^^^^^^^^

运行程序
^^^^^^^^
exec

运行参数
^^^^^^^^
param

工作目录
^^^^^^^^
workdir

筛选器
^^^^^^^^
filter

子菜单
^^^^^^^^
sub

变量
----------------


筛选器列表
----------------
{only}

{ext}

{filename}

{dirname}

{text}

{winclass}

{winexe}

{wintitle}

{winctrl}

{pos}

自定义筛选器

标签列表
----------------
{file}

{file:path}

{file:name}

{file:ext}

{file:dir}

{file:namenoext}

{file:drive}

{list}

{list: [path]}

{list: [name]}

{list: [ext]}

{list: [dir]}

{list: [namenoext]}

{list: [drive]}

{list: [cr]}

{list: [tab]}

{list: [idnex]}

{text}

{win}

{win:hwnd}

{win:clsas}

{win.exe}

{win:exefullpath}

{win:control}

{win:title}

自定义标签