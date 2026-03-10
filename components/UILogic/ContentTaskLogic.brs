sub RunGameTask() as void
    m.gameTask = CreateObject("roSGNode", "GameLoaderTask")
    ' Populate HomeScreen when the game list arrives.
    m.gameTask.ObserveField("content", "OnGameContentLoaded")
    m.gameTask.control = "run"
end sub

sub OnGameContentLoaded()
    if m.HomeScreen <> invalid
        m.HomeScreen.content = m.gameTask.content
    end if
end sub

sub RunContentTask(game as string, query as string)
    m.contentTask = CreateObject("roSGNode", "MainLoaderTask")
    ' Request either global search or game-filtered search.
    m.contentTask.game = game
    m.contentTask.input = query
    ' Route loaded content to whichever screen is visible.
    m.contentTask.ObserveField("content", "OnMainContentLoaded")
    m.contentTask.control = "run"
end sub

sub OnMainContentLoaded()
    if m.SearchScreen <> invalid and m.SearchScreen.visible
        m.SearchScreen.content = m.contentTask.content
    end if

    if m.DetailsScreen <> invalid and m.DetailsScreen.visible
        m.DetailsScreen.content = m.contentTask.content
        m.DetailsScreen.jumpToItem = 0
    end if

    if m.EpisodesScreen <> invalid and m.EpisodesScreen.visible
        wrappedRoot = CreateObject("roSGNode", "ContentNode")
        section = wrappedRoot.CreateChild("ContentNode")
        section.title = "All Clips"
        if m.contentTask.content <> invalid
            for each clip in m.contentTask.content.GetChildren(-1, 0)
                section.AppendChild(clip.Clone(false))
            end for
        end if
        m.EpisodesScreen.content = wrappedRoot
        jumpIndex = 0
        if m.selectedIndex <> invalid and m.selectedIndex.Count() > 1 then
            jumpIndex = m.selectedIndex[1]
        end if
        m.EpisodesScreen.jumpToItem = jumpIndex
    end if
end sub

