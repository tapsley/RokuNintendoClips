sub init()
    m.top.selectedGame = ""
    m.top.searchRequested = ""
    m.searchTriggerState = false
    m.top.ObserveField("visible", "OnVisibleChanged")
    m.list = m.top.FindNode("gameGrid")
    m.searchButton = m.top.FindNode("searchButton")
    m.searchCircle = m.top.FindNode("searchCircle")
    m.searchGlyph = m.top.FindNode("searchGlyph")
    m.searchText = m.top.FindNode("searchText")
    m.list.observeField("itemSelected", "OnGameSelected")
    m.list.setFocus(true)
    UpdateSearchButtonVisualState()
end sub

sub TriggerSearch()
    ' Flip between two values so the observer fires on every press.
    m.searchTriggerState = not m.searchTriggerState
    if m.searchTriggerState
        m.top.searchRequested = "1"
    else
        m.top.searchRequested = "0"
    end if
end sub

function OnGameSelected()
    gameIndex = m.list.itemSelected 'get the index to find the game
    game = m.list.content.getChild(gameIndex).shortdescriptionline1    
    m.top.selectedGame = LCase(game)
end function

sub OnVisibleChanged()
    UpdateSearchButtonVisualState()
end sub

sub UpdateSearchButtonVisualState()
    if m.searchButton = invalid then return

    isFocused = m.searchButton.HasFocus()
    if isFocused
        if m.searchCircle <> invalid then m.searchCircle.color = "0x0D61D3FF"
        if m.searchGlyph <> invalid then m.searchGlyph.color = "0xFFFFFFFF"
        if m.searchText <> invalid then m.searchText.color = "0xFFFFFFFF"
    else
        if m.searchCircle <> invalid then m.searchCircle.color = "0xFFFFFFFF"
        if m.searchGlyph <> invalid then m.searchGlyph.color = "0x0D61D3FF"
        if m.searchText <> invalid then m.searchText.color = "0x0D61D3FF"
    end if
end sub

function GetFocusedGame() as String
    if m.list = invalid or m.list.content = invalid then return ""

    gameIndex = m.list.itemFocused
    if gameIndex < 0 or gameIndex >= m.list.content.GetChildCount() then return ""

    game = m.list.content.getChild(gameIndex).shortdescriptionline1
    if game = invalid then return ""
    return LCase(game)
end function

function OnKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false

    if key = "left" and m.list.HasFocus() and m.searchButton <> invalid then
        m.searchButton.SetFocus(true)
        UpdateSearchButtonVisualState()
        return true
    else if key = "right" and m.searchButton <> invalid and m.searchButton.HasFocus() then
        m.list.SetFocus(true)
        UpdateSearchButtonVisualState()
        return true
    else if key = "OK" and m.searchButton <> invalid and m.searchButton.HasFocus() then
        TriggerSearch()
        return true
    end if

    return false
end function


