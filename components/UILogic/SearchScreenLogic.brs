sub ShowSearchScreen()
    m.SearchScreen = CreateObject("roSGNode", "SearchScreen")
    m.SearchScreen.ObserveField("input", "OnSearchTextChanged")
    m.SearchScreen.ObserveField("selectedItem", "OnItemChosen")
    ShowScreen(m.SearchScreen) ' show SearchScreen
    RunContentTask("", "")
end sub


sub OnSearchTextChanged()
    input = m.SearchScreen.input
    RunContentTask("", input)
end sub
