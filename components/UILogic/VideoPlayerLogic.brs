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
    m.videoPlayer = CreateObject("roSGNode", "Video")

    if selectedItem <> 0
        childrenClone = CloneChildren(rowContent, selectedItem)
        rowNode = CreateObject("roSGNode", "ContentNode")
        rowNode.Update({ children: childrenClone }, true)
        m.videoPlayer.content = rowNode
    else
        m.videoPlayer.content = rowContent.Clone(true)
    end if

    m.videoPlayer.contentIsPlaylist = true
    ShowScreen(m.videoPlayer)
    m.videoPlayer.control = "play"
    m.videoPlayer.ObserveField("state", "OnVideoPlayerStateChange")
    m.videoPlayer.ObserveField("visible", "OnVideoVisibleChange")
end sub

sub StartRandomVideoStream()
    m.isRandomStream = true
    m.randomTaskPending = false
    RequestNextRandomVideo()
end sub

sub RequestNextRandomVideo()
    if m.isRandomStream <> true then return
    if m.randomTaskPending = true then return

    m.randomTaskPending = true
    m.randomTask = CreateObject("roSGNode", "RandomLoaderTask")
    m.randomTask.ObserveField("content", "OnRandomVideoContentLoaded")
    m.randomTask.control = "run"
end sub

sub OnRandomVideoContentLoaded()
    m.randomTaskPending = false
    if m.isRandomStream <> true then return
    if m.randomTask = invalid then return

    rowNode = m.randomTask.content
    m.randomTask = invalid

    if rowNode = invalid or rowNode.GetChildCount() <= 0 then
        if m.videoPlayer <> invalid then CloseScreen(m.videoPlayer)
        return
    end if

    if m.videoPlayer = invalid or m.videoPlayer.visible = false then
        ShowVideoScreen(rowNode, 0, true)
    else
        m.videoPlayer.content = rowNode
        m.videoPlayer.contentIsPlaylist = true
        m.videoPlayer.control = "play"
    end if
end sub

sub OnVideoPlayerStateChange()
    if m.videoPlayer = invalid then return

    state = m.videoPlayer.state
    if state = "error"
        CloseScreen(m.videoPlayer)
        return
    end if

    if state = "finished"
        if m.isRandomStream = true then
            RequestNextRandomVideo()
            return
        end if

        playlistCount = 0
        if m.videoPlayer.content <> invalid then
            playlistCount = m.videoPlayer.content.GetChildCount()
        end if

        currentIndex = m.videoPlayer.contentIndex
        isLastItem = playlistCount <= 0 or currentIndex >= (playlistCount - 1)
        if isLastItem then CloseScreen(m.videoPlayer)
    end if
end sub

sub OnVideoVisibleChange()
    if m.videoPlayer.visible = false and m.top.visible = true
        m.isRandomStream = false
        m.randomTaskPending = false
        m.randomTask = invalid
        currentIndex = m.videoPlayer.contentIndex
        m.videoPlayer.control = "stop"
        m.videoPlayer.content = invalid

        screen = GetCurrentScreen()
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
            if screen.HasField("jumpToItem") then
                screen.jumpToItem = newIndex
            end if
            screen.SetFocus(true)
        end if
    end if
end sub