sub init()
    m.playButton = m.top.FindNode("playButton")
    m.wookieeButton = m.top.FindNode("wookieeButton")
    m.top.isWookiee = false
    m.detailsList = m.top.FindNode("detailsList")
    m.audio = m.top.FindNode("audio")
    m.vector2danimationScroll = m.top.FindNode("CrawlScroll")
    m.vector2danimationScale = m.top.FindNode("CrawlScale")

    'Observe our buttons
    m.playButton.ObserveField("buttonSelected", "OnPlayButtonSelected")
    m.wookieeButton.ObserveField("buttonSelected", "OnWookieeButtonSelected")


    'get title theme audio ready for when content is loaded
    audiocontent = createObject("RoSGNode", "ContentNode")
    audiocontent.url = "pkg:/images/Star_Wars.mp3"
    m.audio.content = audiocontent

    'This will fire when the content has been loaded by the DetailsTask
    m.detailsList.ObserveField("content", "DoCrawl")

    m.playButton.setFocus(true)
end sub

sub DoCrawl()
    m.detailsList.font = "font:ExtraLargeBoldSystemFont"
    m.detailsList.itemSize = [650, 50]
    m.vector2danimationScroll.control = "start" 
    m.vector2danimationScale.control = "start"


    m.audio.control = "play"
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    handled = false

    if press
        if key = "right" and not m.wookieeButton.hasFocus()
            m.wookieeButton.setFocus(true)
            handled = true
        else if key = "left" and not m.playButton.hasFocus()
            m.playButton.setFocus(true)
            handled = true
        else if key = "back"
            m.audio.control = "stop"
            'don't set handle to true yet so we also navigate back to previous screen
        end if
    end if

    return handled
end function

sub OnPlayButtonSelected()
    'toggle this to alert the screenstrack
    m.audio.control = "stop"
    m.top.playClicked = not m.top.playClicked
end sub

sub OnWookieeButtonSelected()
    'cue up a wookiee sound and the title theme to play when content is loaded again
    contentNode = createObject("RoSGNode", "ContentNode")
    audiocontent = contentNode.createChild("ContentNode")
    item={}
    item.url = "pkg:/images/wookiee.mp3"
    audiocontent.setFields(item)
    audiocontent = contentNode.createChild("ContentNode")
    item.url = "pkg:/images/Star_Wars.mp3"
    audiocontent.setFields(item)
    m.audio.content = contentNode
    m.audio.contentIsPlaylist = true

    'toggle this to alert the screenstack
    m.top.isWookiee = not m.top.isWookiee
end sub