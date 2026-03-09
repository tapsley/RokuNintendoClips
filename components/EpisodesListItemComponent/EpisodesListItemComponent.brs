sub Init()
    ' store components to m for populating them with metadata
    m.background = m.top.FindNode("background")
    m.poster = m.top.FindNode("poster")
    m.title = m.top.FindNode("title")
    m.description = m.top.FindNode("description")
    m.info = m.top.FindNode("info")
    ' set font size for title and description Labels
    m.title.font.size = 20
    m.description.font.size = 16
    OnItemFocusChanged()
end sub

sub itemContentChanged() ' invoked when episode data is retrieved
    itemContent = m.top.itemContent ' episode metadata
    if itemContent <> invalid
        ' populate components with metadata
        m.poster.uri = itemContent.hdposterurl
        m.title.text = itemContent.title
        m.description.text = itemContent.shortdescriptionline2
    end if
end sub

sub OnItemFocusChanged()
    if m.background = invalid then return

    if m.top.itemHasFocus = true then
        m.background.color = "0x0D61D3FF"
        m.title.color = "0xFFFFFFFF"
        m.description.color = "0xFFFFFFFF"
        m.info.color = "0xFFFFFFFF"
    else
        m.background.color = "0xFFFFFFFF"
        m.title.color = "0x000000FF"
        m.description.color = "0x000000FF"
        m.info.color = "0x000000FF"
    end if
end sub