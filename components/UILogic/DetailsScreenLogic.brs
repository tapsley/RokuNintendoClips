sub ShowDetailsScreen()
    ' create new instance of details screen
    detailsScreen = CreateObject("roSGNode", "DetailsScreen")
    m.DetailsScreen = detailsScreen
    'detailsScreen.content = content
    'detailsScreen.jumpToItem = selectedItem ' set index of item which should be focused
    detailsScreen.ObserveField("visible", "OnDetailsScreenVisibilityChanged")
    detailsScreen.ObserveField("buttonSelected", "OnButtonSelected")
    ShowScreen(detailsScreen)
end sub

sub OnDetailsScreenVisibilityChanged(event as Object) ' invoked when DetailsScreen "visible" field is changed
    visible = event.GetData()
    detailsScreen = event.GetRoSGNode()
    currentScreen = GetCurrentScreen()
    screenType = currentScreen.SubType()
    if visible = false
        if screenType = "GridScreen"
            ' update GridScreen's focus when navigate back from DetailsScreen
            currentScreen.jumpToRowItem = [m.selectedIndex[0], detailsScreen.itemFocused]
        else if screenType = "EpisodesScreen"
            ' update EpisodesScreen's focus when navigate back from DetailsScreen
            content = detailsScreen.content.GetChild(detailsScreen.itemFocused)
            currentScreen.jumpToItem = content.numEpisodes
        end if
    end if
end sub

sub OnButtonSelected(event as Object) ' invoked when button in DetailsScreen is pressed
    details = event.GetRoSGNode()
    if details = invalid then return

    content = details.content
    if content = invalid or content.GetChildCount() = 0 then return

    buttonIndex = event.getData() ' index of selected button
    if buttonIndex = invalid or buttonIndex < 0 then return

    selectedItem = details.itemFocused
    if buttonIndex = 0 ' check if "Play" button is pressed
        ' create Video node and start playback
        HandlePlayButton(content, selectedItem)
    else if buttonIndex = 1 ' check if "Play all" button is pressed
        ShowVideoScreen(content, 0)
        m.selectedIndex[1] = 0
    else if buttonIndex = 2 ' check if "See all clips" button is pressed
        ' create EpisodesScreen instance and show full clip list
        ShowEpisodesScreen(content, selectedItem)
    end if
end sub

sub HandlePlayButton(content as Object, selectedItem as Integer)
    if content = invalid or content.GetChildCount() = 0 then return

    if selectedItem < 0 or selectedItem >= content.GetChildCount() then return

    itemContent = content.GetChild(selectedItem)
    ' if content child is serial with seasons
    ' we will set all episodes of serial to playlist
    if itemContent.mediaType = "series"
        children = []
        ' clone all episodes of easch season
        for each season in itemContent.getChildren(-1, 0)
            children.Append(CloneChildren(season))
        end for
        ' create new node and set all episodes of serial
        node = CreateObject("roSGNode", "ContentNode")
        node.Update({ children: children }, true)
        ' create a Video node and start playback
        ShowVideoScreen(node, 0, true)
    else
        ' Play only the currently focused clip.
        clipNode = CreateObject("roSGNode", "ContentNode")
        clipNode.Update({ children: [itemContent.Clone(false)] }, true)
        ShowVideoScreen(clipNode, 0, true)
    end if
    m.selectedIndex[1] = selectedItem
end sub