sub Init()
    m.itemsList = m.top.findNode("itemsGrid")
    m.loadingIcon = m.top.findNode("loadingIndicator")
    m.loadingIcon.visible = true
    m.keyboard = m.top.findNode("keyboard")
    m.keyboard.textEditBox.hintText = "Search for something"

    m.keyboard.ObserveField("text", "OnTextChanged")
    m.itemsList.ObserveField("content", "OnContentChanged")
    m.itemsList.ObserveField("itemSelected", "ItemSelected")
    m.top.setFocus(true)
end sub

sub OnContentChanged()
    'When the content is finished loading, hide the loading icon
    m.loadingIcon.visible = false
end sub

function OnTextChanged()
    'When any text is input, search based on that text and display content
    m.top.input = m.keyboard.text 'this will alert the screen stack with the updated input
    m.loadingIcon.visible = true
end function

function ItemSelected()
    'When item is selected, take user to the details page for that item
    itemIndex = m.itemsList.itemSelected
    itemUrl = m.itemsList.content.getChild(itemIndex).shortdescriptionline2
    print "Selected item URL: " + itemUrl
    'This will signal the screenstack to open details screen
    m.top.selectedItem = itemUrl
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
    handled = false

    if press
        if key = "right" and not m.itemsList.hasFocus()
            m.itemsList.setFocus(true)
            handled = true
        else if key = "left" and not m.keyboard.hasFocus()
            m.keyboard.setFocus(true)
            handled = true
        end if
    end if

    return handled
end function