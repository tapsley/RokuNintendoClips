sub ShowDetailsScreen()
    ' Create a new DetailsScreen instance.
    detailsScreen = CreateObject("roSGNode", "DetailsScreen")
    m.DetailsScreen = detailsScreen
    detailsScreen.ObserveField("visible", "OnDetailsScreenVisibilityChanged")
    detailsScreen.ObserveField("buttonSelected", "OnButtonSelected")
    ShowScreen(detailsScreen)
end sub

sub OnDetailsScreenVisibilityChanged(event as Object)
    visible = event.GetData()
    detailsScreen = event.GetRoSGNode()
    currentScreen = GetCurrentScreen()
    screenType = currentScreen.SubType()
    if visible = false
        if screenType = "GridScreen"
            ' Restore grid focus when returning from DetailsScreen.
            currentScreen.jumpToRowItem = [m.selectedIndex[0], detailsScreen.itemFocused]
        else if screenType = "EpisodesScreen"
            ' Restore episodes focus when returning from DetailsScreen.
            content = detailsScreen.content.GetChild(detailsScreen.itemFocused)
            currentScreen.jumpToItem = content.numEpisodes
        end if
    end if
end sub

sub OnButtonSelected(event as Object)
    details = event.GetRoSGNode()
    if details = invalid then return

    content = details.content
    if content = invalid or content.GetChildCount() = 0 then return

    buttonIndex = event.getData() ' index of selected button
    if buttonIndex = invalid or buttonIndex < 0 then return

    selectedItem = details.itemFocused
    if buttonIndex = 0
        HandlePlayButton(content, selectedItem)
    else if buttonIndex = 1
        ShowVideoScreen(content, 0)
        m.selectedIndex[1] = 0
    else if buttonIndex = 2
        ShowEpisodesScreen(content, selectedItem)
    end if
end sub

sub HandlePlayButton(content as Object, selectedItem as Integer)
    if content = invalid or content.GetChildCount() = 0 then return

    if selectedItem < 0 or selectedItem >= content.GetChildCount() then return

    itemContent = content.GetChild(selectedItem)
    ' Series entries are flattened into one playlist.
    if itemContent.mediaType = "series"
        children = []
        ' Clone all episodes from each season.
        for each season in itemContent.getChildren(-1, 0)
            children.Append(CloneChildren(season))
        end for
        ' Build playlist content node for playback.
        node = CreateObject("roSGNode", "ContentNode")
        node.Update({ children: children }, true)
        ShowVideoScreen(node, 0, true)
    else
        ' Play only the currently focused clip.
        clipNode = CreateObject("roSGNode", "ContentNode")
        clipNode.Update({ children: [itemContent.Clone(false)] }, true)
        ShowVideoScreen(clipNode, 0, true)
    end if
    m.selectedIndex[1] = selectedItem
end sub