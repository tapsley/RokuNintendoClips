sub init()
    m.top.selectedGame = ""
    m.top.searchRequested = ""
    m.top.randomRequested = ""
    m.searchTriggerState = false
    m.randomTriggerState = false
    m.top.ObserveField("visible", "OnVisibleChanged")
    m.list = m.top.FindNode("gameGrid")
    m.searchButton = m.top.FindNode("searchButton")
    m.randomButton = m.top.FindNode("randomButton")
    m.searchCircle = m.top.FindNode("searchCircle")
    m.searchIcon = m.top.FindNode("searchIcon")
    m.searchText = m.top.FindNode("searchText")
    m.randomCircle = m.top.FindNode("randomCircle")
    m.randomIcon = m.top.FindNode("randomIcon")
    m.randomText = m.top.FindNode("randomText")
    m.list.observeField("itemSelected", "OnGameSelected")

    ' HomeScreen.xml may use Poster nodes directly for buttons.
    if m.searchIcon = invalid then m.searchIcon = m.searchButton
    if m.randomIcon = invalid then m.randomIcon = m.randomButton

    m.list.setFocus(true)
    UpdateSearchButtonVisualState()
end sub

sub TriggerRandom()
    ' Flip between two values so the observer fires on every press.
    m.randomTriggerState = not m.randomTriggerState
    if m.randomTriggerState
        m.top.randomRequested = "1"
    else
        m.top.randomRequested = "0"
    end if
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
    if m.searchButton <> invalid and m.searchButton.HasFocus()
        if m.searchCircle <> invalid then m.searchCircle.color = "0x0D61D3FF"
        if m.searchIcon <> invalid then m.searchIcon.uri = "pkg:/images/search_icon_selected.png"
        if m.searchText <> invalid then m.searchText.color = "0xFFFFFFFF"
    else
        if m.searchCircle <> invalid then m.searchCircle.color = "0xFFFFFFFF"
        if m.searchIcon <> invalid then m.searchIcon.uri = "pkg:/images/search_icon.png"
        if m.searchText <> invalid then m.searchText.color = "0x0D61D3FF"
    end if

    if m.randomButton <> invalid and m.randomButton.HasFocus()
        if m.randomCircle <> invalid then m.randomCircle.color = "0x0D61D3FF"
        if m.randomIcon <> invalid then m.randomIcon.uri = "pkg:/images/random_icon_selected.png"
        if m.randomText <> invalid then m.randomText.color = "0xFFFFFFFF"
    else
        if m.randomCircle <> invalid then m.randomCircle.color = "0xFFFFFFFF"
        if m.randomIcon <> invalid then m.randomIcon.uri = "pkg:/images/random_icon.png"
        if m.randomText <> invalid then m.randomText.color = "0x0D61D3FF"
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
    else if key = "right" and m.randomButton <> invalid and m.randomButton.HasFocus() then
        m.list.SetFocus(true)
        UpdateSearchButtonVisualState()
        return true
    else if key = "down" and m.searchButton <> invalid and m.searchButton.HasFocus() and m.randomButton <> invalid then
        m.randomButton.SetFocus(true)
        UpdateSearchButtonVisualState()
        return true
    else if key = "up" and m.randomButton <> invalid and m.randomButton.HasFocus() and m.searchButton <> invalid then
        m.searchButton.SetFocus(true)
        UpdateSearchButtonVisualState()
        return true
    else if key = "OK" and m.searchButton <> invalid and m.searchButton.HasFocus() then
        TriggerSearch()
        return true
    else if key = "OK" and m.randomButton <> invalid and m.randomButton.HasFocus() then
        TriggerRandom()
        return true
    end if

    return false
end function


