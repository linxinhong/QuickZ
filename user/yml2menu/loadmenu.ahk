yml2menu_init() {
    yamlObject := yaml(quickz.self.plugins["yml2menu"].dir "\menu.yml", true)
    For key, value in yamlObject.var
    {
        menuz.SetVar(key, value)
    }
    For key, value in yamlObject.color
    {
        menuz.SetVar(key, value)
    }
    For key, value in yamlObject.filter
    {
        menuz.SetVar(key, value)
    }
    menuz.FromObject(YamlToMenu(yamlObject))
}

YamlToMenu(yamlConfig) {
    menuConfig := {}
    Loop % yamlConfig.()
    {
        Item := yamlConfig.(A_Index)
        if IsObject(Item.sub) {
            Item["Sub"] := YamlToMenu(Item.sub)
        }
        if IsObject(Item.Peer) {
            Item["Peer"] := YamlToMenu(Item.Peer)
        }
        menuConfig.push(Item)
    }
    return menuConfig
}