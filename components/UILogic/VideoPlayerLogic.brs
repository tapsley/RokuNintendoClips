sub ShowVideoScreen(rowContent as Object, selectedItem as Integer, isSeries = false as Boolean)
    if rowContent = invalid or Type(rowContent) <> "roSGNode" then
        print "[ShowVideoScreen] Invalid row content"
        return
    end if

    childCount = rowContent.GetChildCount()
    if childCount <= 0 then
        print "[ShowVideoScreen] No videos to play"
        return
    end if

    if selectedItem < 0 then
        selectedItem = 0
    else if selectedItem >= childCount then
        selectedItem = childCount - 1
    end if

    m.isSeries = isSeries
    m.videoPlayer = CreateObject("roSGNode", "Video") ' create new instance of video node for each playback
    ' we can't set index of content which should start firstly in playlist mode.
    ' for cases when user select second, third etc. item in the row we use the following workaround
    if selectedItem <> 0 ' check if user select any but first item of the row
        childrenClone = CloneChildren(rowContent, selectedItem)
        ' create new parent node for our cloned items
        rowNode = CreateObject("roSGNode", "ContentNode")
        rowNode.Update({ children: childrenClone }, true)
        m.videoPlayer.content = rowNode ' set node with children to video node content
    else
        ' if playback must start from first item we clone all row node
        m.videoPlayer.content = rowContent.Clone(true)
    end if
    m.videoPlayer.contentIsPlaylist = true ' enable video playlist (a sequence of videos to be played)
    ShowScreen(m.videoPlayer) ' show video screen
    m.videoPlayer.control = "play" ' start playback
    m.videoPlayer.ObserveField("state", "OnVideoPlayerStateChange")
    m.videoPlayer.ObserveField("visible", "OnVideoVisibleChange")
end sub

sub OnVideoPlayerStateChange() ' invoked when video state is changed
    if m.videoPlayer = invalid then return

    state = m.videoPlayer.state
    if state = "error"
        CloseScreen(m.videoPlayer)
        return
    end if

    if state = "finished"
        playlistCount = 0
        if m.videoPlayer.content <> invalid then
            playlistCount = m.videoPlayer.content.GetChildCount()
        end if

        currentIndex = m.videoPlayer.contentIndex
        isLastItem = playlistCount <= 0 or currentIndex >= (playlistCount - 1)

        ' In playlist mode, wait until the final clip is finished before closing.
        if isLastItem then
            CloseScreen(m.videoPlayer)
        end if
    end if
end sub

sub OnVideoVisibleChange() ' invoked when video node visibility is changed
    if m.videoPlayer.visible = false and m.top.visible = true
        ' the index of the video in the video playlist that is currently playing.
        currentIndex = m.videoPlayer.contentIndex
        m.videoPlayer.control = "stop" ' stop playback
        'clear video player content, for proper start of next video player
        m.videoPlayer.content = invalid
        screen = GetCurrentScreen()
        screen.SetFocus(true) ' return focus to details screen
        newIndex = 0
        if m.selectedIndex <> invalid and m.selectedIndex.Count() > 1
            newIndex = m.selectedIndex[1]
        end if
        if m.isSeries = true
           m.isSeries = false
        else
           newIndex += currentIndex
        end if
        if screen <> invalid then
            ' navigate to the last played item for supported screens.
            if screen.HasField("jumpToItem") then
                screen.jumpToItem = newIndex
            end if
            screen.SetFocus(true)
        end if
    end if
end sub