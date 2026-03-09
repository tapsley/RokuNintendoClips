function Init()
    ' observe "visible" so we can know when EpisodesScreen change visibility
    m.top.ObserveField("visible", "onVisibleChange")
    m.keyboard = m.top.FindNode("keyboard")
    m.itemsList = m.top.FindNode("itemsList")
    ' observe "itemSelected" so we can know which episode is selected
    m.itemsList.ObserveField("itemSelected", "OnListItemSelected")
    m.top.ObserveField("content", "OnContentChange")

    if m.keyboard <> invalid then
        m.keyboard.textEditBox.hintText = "Filter clips"
        m.keyboard.textEditBox.textColor = "0x0D61D3"
        m.keyboard.ObserveField("text", "OnFilterTextChanged")
    end if
end function

sub InitSections(content as Object)
    ' save the position of the first episode for each season
    m.firstItemInSection = [0]
    ' save the season index to which the episode belongs
    m.itemToSection = []
    flatItems = []
    sectionCount = 0
    ' goes through seasons and populate "firstItemInSection" and "itemToSection" arrays
    for each section in content.GetChildren(- 1, 0)
        itemsPerSection = section.GetChildCount()
        for each child in section.GetChildren(- 1, 0)
            m.itemToSection.Push(sectionCount)
            flatItems.Push(child.Clone(false))
        end for
        m.firstItemInSection.Push(m.firstItemInSection.Peek() + itemsPerSection)
        sectionCount++
    end for
    m.firstItemInSection.Pop() ' remove last item
    m.flatItems = flatItems
end sub

sub OnJumpToItem(event as Object) ' invoked when "jumpToItem field is changed
    itemIndex = event.GetData()
    m.itemsList.jumpToItem = itemIndex ' navigate to the specified item
end sub

sub OnContentChange() ' invoked when EpisodesScreen content is changed
    content = m.top.content
    InitSections(content) ' populate seasons list

    itemsRoot = CreateObject("roSGNode", "ContentNode")
    if m.flatItems <> invalid
        for each item in m.flatItems
            itemsRoot.AppendChild(item)
        end for
    end if

    m.itemsList.content = itemsRoot ' populate episodes list
end sub

sub OnFilterTextChanged()
    if m.keyboard = invalid then return

    m.top.input = m.keyboard.text
end sub

sub onVisibleChange() ' invoked when Episodes screen becomes visible
    if m.top.visible = true
        if m.itemsList <> invalid then
            m.itemsList.setFocus(true)
        else if m.keyboard <> invalid then
            m.keyboard.setFocus(true)
        end if
    end if
end sub

sub OnListItemSelected(event as Object) ' invoked when episode is selected
    itemSelected = event.GetData() ' index of selected item
    absoluteIndex = itemSelected
    if absoluteIndex < 0 or absoluteIndex >= m.itemToSection.Count() then return

    sectionIndex = m.itemToSection[absoluteIndex] ' season which contains selected episode
    ' OnEpisodesScreenItemSelected method in EpisodesScreenLogic.brs is invoked when selectedItem array is populated
    m.top.selectedItem = [sectionIndex, absoluteIndex - m.firstItemInSection[sectionIndex]]
end sub

' The OnKeyEvent() function receives remote control key events
function OnKeyEvent(key as String, press as Boolean) as Boolean
    handled = false
    if press
        if key = "right" and m.keyboard <> invalid and not m.itemsList.HasFocus()
            m.itemsList.SetFocus(true)
            handled = true
        else if key = "left" and m.keyboard <> invalid and not m.keyboard.HasFocus()
            m.keyboard.SetFocus(true)
            handled = true
        end if
    end if

    return handled
end function