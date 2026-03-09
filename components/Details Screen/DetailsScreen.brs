function Init()
    ' observe "visible" so we can know when DetailsScreen change visibility
    m.top.ObserveField("visible", "OnVisibleChange")
    ' observe "itemFocused" so we can know when another item gets in focus
    m.top.ObserveField("itemFocused", "OnItemFocusedChanged")
    ' save a references to the DetailsScreen child components in the m variable
    ' so we can access them easily from other functions
    m.buttons = m.top.FindNode("buttons")
    m.playButton = m.top.FindNode("playButton")
    m.playAllButton = m.top.FindNode("playAllButton")
    m.allClipsButton = m.top.FindNode("allClipsButton")
    m.poster = m.top.FindNode("poster")
    m.description = m.top.FindNode("descriptionLabel")
    m.description.color = "0x0D61D3"
    m.timeLabel = m.top.FindNode("timeLabel")
    m.titleLabel = m.top.FindNode("titleLabel")
    m.titleLabel.color = "0x0D61D3"
    m.releaseLabel = m.top.FindNode("releaseLabel")

    if m.playButton <> invalid then
        m.playButton.ObserveField("buttonSelected", "OnPlayButtonPressed")
    end if
    if m.playAllButton <> invalid then
        m.playAllButton.ObserveField("buttonSelected", "OnPlayAllButtonPressed")
    end if
    if m.allClipsButton <> invalid then
        m.allClipsButton.ObserveField("buttonSelected", "OnAllClipsButtonPressed")
    end if

    UpdateButtonVisualState()
end function

sub onVisibleChange()' invoked when DetailsScreen visibility is changed
    ' set focus for primary button when DetailsScreen becomes visible
    if m.top.visible = true
        if m.playButton <> invalid then
            m.playButton.SetFocus(true)
            UpdateButtonVisualState()
        end if
    end if
end sub

sub UpdateButtonVisualState()
    if m.playButton <> invalid then
        if m.playButton.HasFocus()
            m.playButton.minWidth = 593
            m.playButton.maxWidth = 593
        else
            m.playButton.minWidth = 560
            m.playButton.maxWidth = 560
        end if
    end if

    if m.playAllButton <> invalid then
        if m.playAllButton.HasFocus()
            m.playAllButton.minWidth = 593
            m.playAllButton.maxWidth = 593
        else
            m.playAllButton.minWidth = 560
            m.playAllButton.maxWidth = 560
        end if
    end if

    if m.allClipsButton <> invalid then
        if m.allClipsButton.HasFocus()
            m.allClipsButton.minWidth = 593
            m.allClipsButton.maxWidth = 593
        else
            m.allClipsButton.minWidth = 560
            m.allClipsButton.maxWidth = 560
        end if
    end if
end sub

sub OnPlayAllButtonPressed(event as Object)
    data = event.GetData()
    if data = invalid or data = true then
        m.top.buttonSelected = 1
    end if
end sub

sub OnPlayButtonPressed(event as Object)
    data = event.GetData()
    if data = invalid or data = true then
        m.top.buttonSelected = 0
    end if
end sub

sub OnAllClipsButtonPressed(event as Object)
    data = event.GetData()
    if data = invalid or data = true then
        m.top.buttonSelected = 2
    end if
end sub

sub SetDetailsContent(content)
    if content = invalid then return

    descriptionText = ""
    if content.description <> invalid then
        descriptionText = content.description
    else if content.shortdescriptionline2 <> invalid then
        descriptionText = content.shortdescriptionline2
    end if

    posterUri = ""
    if content.hdPosterUrl <> invalid then
        posterUri = content.hdPosterUrl
    else if content.hdposterurl <> invalid then
        posterUri = content.hdposterurl
    else if content.hdgridposterurl <> invalid then
        posterUri = content.hdgridposterurl
    end if

    titleText = ""
    if content.title <> invalid then
        titleText = content.title
    else if content.shortdescriptionline1 <> invalid then
        titleText = content.shortdescriptionline1
    end if

    releaseText = ""
    if content.releaseDate <> invalid and content.releaseDate <> "" then
        releaseText = Left(content.releaseDate, 10)
    end if

    ' populate screen components with metadata
    m.description.text = descriptionText
    m.poster.uri = posterUri
    if content.length <> invalid and content.length <> 0
       '  m.timeLabel.text = getTime(content.length)
    end if
    m.titleLabel.text = titleText
end sub

sub OnJumpToItem() ' invoked when jumpToItem field is populated
    content = m.top.content
    ' check if jumpToItem field has valid value
    ' it should be set within interval from 0 to content.Getchildcount()
    if content <> invalid and m.top.jumpToItem >= 0 and content.GetChildCount() > m.top.jumpToItem
        m.top.itemFocused = m.top.jumpToItem
    end if
end sub

sub OnItemFocusedChanged(event as Object)' invoked when another item is focused
    if m.top.content = invalid then return
    focusedItem = event.GetData() ' get position of focused item
    if focusedItem < 0 or focusedItem >= m.top.content.GetChildCount() then return
    content = m.top.content.GetChild(focusedItem) ' get metadata of focused item
    SetDetailsContent(content) ' populate DetailsScreen with item metadata
end sub

' The OnKeyEvent() function receives remote control key events
function OnkeyEvent(key as String, press as Boolean) as Boolean
    result = false
    if press
        if key = "down" and m.playButton <> invalid and m.playButton.HasFocus() and m.playAllButton <> invalid
            m.playAllButton.SetFocus(true)
            UpdateButtonVisualState()
            result = true
        else if key = "down" and m.playAllButton <> invalid and m.playAllButton.HasFocus() and m.allClipsButton <> invalid
            m.allClipsButton.SetFocus(true)
            UpdateButtonVisualState()
            result = true
        else if key = "up" and m.allClipsButton <> invalid and m.allClipsButton.HasFocus() and m.playAllButton <> invalid
            m.playAllButton.SetFocus(true)
            UpdateButtonVisualState()
            result = true
        else if key = "up" and m.playAllButton <> invalid and m.playAllButton.HasFocus() and m.playButton <> invalid
            m.playButton.SetFocus(true)
            UpdateButtonVisualState()
            result = true
        else if key = "OK"
            if m.playButton <> invalid and m.playButton.HasFocus()
                m.top.buttonSelected = 0
                result = true
            else if m.playAllButton <> invalid and m.playAllButton.HasFocus()
                m.top.buttonSelected = 1
                result = true
            else if m.allClipsButton <> invalid and m.allClipsButton.HasFocus()
                m.top.buttonSelected = 2
                result = true
            end if
        end if

        if result then return true

        currentItem = m.top.itemFocused ' position of currently focused item
        ' handle "left" button keypress
        if key = "left"
            ' navigate to the left item in case of "left" keypress
            m.top.jumpToItem = currentItem - 1
            result = true
        ' handle "right" button keypress
        else if key = "right"
            ' navigate to the right item in case of "right" keypress
            m.top.jumpToItem = currentItem + 1
            result = true
        end if
    end if
    return result
end function