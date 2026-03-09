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
            ' Try to move focus into a known interactive child so the cursor/selection is visible
            child = invalid
            child = prev.FindNode("categoryGrid")
            if child = invalid then
                child = prev.FindNode("itemsGrid")
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

sub ShowCategoryScreen()
    m.CategoryScreen = CreateObject("roSGNode", "CategoryScreen")
    m.CategoryScreen.ObserveField("selectedCategory", "OnCategoryChosen")
    RunGameTask()
    ShowScreen(m.CategoryScreen) ' show CategoryScreen
end sub

sub ShowSearchScreen(category as string)
    m.SearchScreen = CreateObject("roSGNode", "SearchScreen")
    m.SearchScreen.category = category
    m.SearchScreen.ObserveField("input", "OnSearchTextChanged")
    m.SearchScreen.ObserveField("selectedItem", "OnItemChosen")
    ShowScreen(m.SearchScreen) ' show SearchScreen
end sub

sub ShowDetailsScreen(itemUrl as string)
    m.DetailsScreen = CreateObject("roSGNode", "DetailsScreen")
    m.DetailsScreen.itemUrl = itemUrl
    m.DetailsScreen.ObserveField("playClicked", "OnPlayButtonSelected")
    m.DetailsScreen.ObserveField("isWookiee", "OnWookieeButtonSelected")
    ShowScreen(m.DetailsScreen)
end sub

sub ShowVideoScreen(itemUrl as string)
    m.VideoScreen = CreateObject("roSGNode", "VideoScreen")
    m.VideoScreen.itemUrl = itemUrl
    ShowScreen(m.VideoScreen)
end sub


sub OnCategoryChosen()
    category = m.CategoryScreen.selectedCategory
    m.CategoryScreen.selectedCategory = "" 'reset selected category
    ShowSearchScreen(category)
    RunContentTask(category, "")
end sub

sub OnSearchTextChanged()
    input = m.SearchScreen.input
    category = m.SearchScreen.category
    RunContentTask(category, input)
end sub

sub OnItemChosen()
    itemUrl = m.SearchScreen.selectedItem
    print "On item chosen - Selected item URL: " + itemUrl
    ShowVideoScreen(itemUrl)
    'RunDetailsTask(itemUrl, false)
end sub

sub OnPlayButtonSelected()
    'ShowVideoScreen()
end sub

sub OnWookieeButtonSelected()
    itemUrl = m.DetailsScreen.itemUrl
    isWookiee = m.DetailsScreen.isWookiee 'this will act as a toggle on the details screen
    RunDetailsTask(itemUrl, isWookiee)
end sub
