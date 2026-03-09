sub RunGameTask() as void
    m.gameTask = CreateObject("roSGNode", "GameLoaderTask") ' create task for feed retrieving
    ' observe content so we can know when feed content will be parsed
    'just a comment
    m.gameTask.ObserveField("content", "OnGameContentLoaded")
    m.gameTask.control = "run" ' GetCategoryContent(see GameLoaderTask.brs) method is executed
end sub

sub OnGameContentLoaded() ' invoked when game categories are ready
    if m.HomeScreen <> invalid
        m.HomeScreen.content = m.gameTask.content
    end if
end sub

sub RunContentTask(category as string, input as string)
    m.contentTask = CreateObject("roSGNode", "MainLoaderTask") ' create task for feed retrieving
    'set the proper fields
    m.contentTask.game = category
    m.contentTask.input = input
    ' observe content so we can know when feed content will be parsed
    m.contentTask.ObserveField("content", "OnMainContentLoaded")
    m.contentTask.control = "run" ' GetCategoryContent(see MainLoaderTask.brs) method is executed
end sub

sub OnMainContentLoaded() ' invoked when content is ready to be used
    if m.SearchScreen <> invalid and m.SearchScreen.visible
        m.SearchScreen.content = m.contentTask.content ' populate SearchScreen with content
    end if

    if m.DetailsScreen <> invalid and m.DetailsScreen.visible
        m.ignoreNextDetailsButtonSelected = true
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

sub RunDetailsTask(url as string, isWookiee as boolean)
    m.detailsTask = CreateObject("roSGNode", "DetailsTask") ' create task for feed retrieving
    'set the proper fields
    m.detailsTask.url = url
    ' observe content so we can know when feed content will be parsed
    m.detailsTask.ObserveField("content", "OnDetailsContentLoaded")
    m.detailsTask.control = "run" ' GetCategoryContent(see MainLoaderTask.brs) method is executed
end sub

sub OnDetailsContentLoaded() ' invoked when content is ready to be used
    if m.DetailsScreen <> invalid
        m.DetailsScreen.content = m.detailsTask.content 
    end if
end sub