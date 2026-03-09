'This handles all the navigation betweens screens. When a new screen is created,
'it is added to the screen stack, and I add observers to certain fields so I know
'when to run tasks and transition to other screens.
sub InitScreenStack()
    m.screenStack = []
end sub

sub ShowScreen(node as Object)
    prev = m.screenStack.Peek() ' take current screen from screen stack but don't delete it
    if prev <> invalid
        prev.visible = false ' hide current screen if it exist
    end if
    ' show new screen
    m.top.AppendChild(node)
    node.visible = true
    node.SetFocus(true)
    m.screenStack.Push(node) ' add new screen to the screen stack
end sub

sub CloseScreen(node as Object)
    if node = invalid OR (m.screenStack.Peek() <> invalid AND m.screenStack.Peek().IsSameNode(node))
        last = m.screenStack.Pop() ' remove screen from screenStack
        last.visible = false ' hide screen
        m.top.RemoveChild(node) ' remove screen from scene
        
        ' take previous screen and make it visible
        prev = m.screenStack.Peek()
        if prev <> invalid
            prev.visible = true
            ' Move focus into the primary interactive child on the previous screen.
            child = invalid
            child = prev.FindNode("categoryGrid")
            if child = invalid then
                child = prev.FindNode("itemsGrid")
            end if
            if child = invalid then
                child = prev.FindNode("itemsList")
            end if
            if child = invalid then
                child = prev.FindNode("playButton")
            end if
            if child = invalid then
                child = prev.FindNode("gameGrid")
                if child <> invalid and m.selectedIndex <> invalid and m.selectedIndex.Count() > 0 then
                    if child.HasField("jumpToItem") then
                        child.jumpToItem = m.selectedIndex[0]
                    end if
                end if
            end if

            if child <> invalid then
                child.SetFocus(true)
            else
                prev.SetFocus(true)
            end if
        end if
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    handled = false

    if press
        if key = "back" and m.screenStack.Count() > 1
            CloseScreen(m.screenStack.Peek())
            handled = true
        end if
    end if

    return handled
end function



sub OnItemChosen()
    if m.SearchScreen = invalid or m.SearchScreen.content = invalid then return

    selectedIndex = m.SearchScreen.selectedItem
    if selectedIndex < 0 or selectedIndex >= m.SearchScreen.content.GetChildCount() then return

    selectedClip = m.SearchScreen.content.GetChild(selectedIndex)
    if selectedClip = invalid then return

    node = CreateObject("roSGNode", "ContentNode")
    node.Update({ children: [selectedClip.Clone(false)] }, true)
    ShowVideoScreen(node, 0, true)
end sub

sub OnPlayButtonSelected()
    'ShowVideoScreen()
end sub


function GetCurrentScreen()
    return m.screenStack.Peek()
end function