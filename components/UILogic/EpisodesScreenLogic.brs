sub ShowEpisodesScreen(content as Object, selectedItem as Integer)
    if content = invalid then return

    ' create instance of the EpisodesScreen
    episodesScreen = CreateObject("roSGNode", "EpisodesScreen")
    m.EpisodesScreen = episodesScreen
    ' observe selectedItem field so we can know which episode is selected
    episodesScreen.ObserveField("selectedItem", "OnEpisodesScreenItemSelected")
    episodesScreen.ObserveField("input", "OnEpisodesFilterChanged")

    itemCount = content.GetChildCount()
    if itemCount <= 0 then return

    if selectedItem < 0 then
        selectedItem = 0
    else if selectedItem >= itemCount then
        selectedItem = itemCount - 1
    end if

    selectedNode = content.GetChild(selectedItem)
    if selectedNode <> invalid and selectedNode.GetChildCount() > 0 then
        ' Legacy series structure: selected item already contains sections/episodes.
        episodesScreen.content = selectedNode
        ShowScreen(episodesScreen)
        episodesScreen.jumpToItem = 0
        return
    end if

    ' Flat game clips: wrap all clips into one section so EpisodesScreen can render a list.
    wrappedRoot = CreateObject("roSGNode", "ContentNode")
    section = wrappedRoot.CreateChild("ContentNode")
    section.title = "All Clips"
    for each clip in content.GetChildren(-1, 0)
        section.AppendChild(clip.Clone(false))
    end for

    episodesScreen.content = wrappedRoot
    ShowScreen(episodesScreen)
    episodesScreen.jumpToItem = selectedItem
end sub

sub OnEpisodesFilterChanged()
    if m.EpisodesScreen = invalid then return

    category = ""
    if m.currentGame <> invalid then
        category = m.currentGame
    end if
    input = m.EpisodesScreen.input
    RunContentTask(category, input)
end sub

sub OnEpisodesScreenItemSelected(event as Object)
    episodesScreen = event.GetRoSGNode()
    ' extract the row and column indexes of the item the user selected
    selectedIndex = event.GetData()
    ' the entire row from the EpisodesScreen
    rowContent = episodesScreen.content.GetChild(selectedIndex[0])

    if rowContent = invalid or rowContent.GetChildCount() <= selectedIndex[1] then return

    ' Build single-item content so only the selected clip plays.
    node = CreateObject("roSGNode", "ContentNode")
    node.Update({ children: [rowContent.GetChild(selectedIndex[1]).Clone(false)] }, true)

    ' Store absolute episode index so focus can be restored when playback closes.
    absoluteItemIndex = selectedIndex[1]
    itemsList = episodesScreen.FindNode("itemsList")
    if itemsList <> invalid and itemsList.itemSelected <> invalid then
        absoluteItemIndex = itemsList.itemSelected
    end if
    m.selectedIndex[1] = absoluteItemIndex

    ShowVideoScreen(node, 0, true)
end sub