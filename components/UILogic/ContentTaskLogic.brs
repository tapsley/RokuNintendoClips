sub RunGameTask() as void
    m.gameTask = CreateObject("roSGNode", "GameLoaderTask") ' create task for feed retrieving
    ' observe content so we can know when feed content will be parsed
    'just a comment
    m.gameTask.ObserveField("content", "OnGameContentLoaded")
    m.gameTask.control = "run" ' GetCategoryContent(see GameLoaderTask.brs) method is executed
end sub

sub OnGameContentLoaded() ' invoked when game categories are ready
    if m.CategoryScreen <> invalid
        m.CategoryScreen.content = m.gameTask.content
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
    if m.SearchScreen <> invalid
        m.SearchScreen.content = m.contentTask.content ' populate SearchScreen with content
    end if
end sub

sub RunDetailsTask(url as string, isWookiee as boolean)
    m.detailsTask = CreateObject("roSGNode", "DetailsTask") ' create task for feed retrieving
    'set the proper fields
    m.detailsTask.url = url
    m.detailsTask.isWookiee = isWookiee
    ' observe content so we can know when feed content will be parsed
    m.detailsTask.ObserveField("content", "OnDetailsContentLoaded")
    m.detailsTask.control = "run" ' GetCategoryContent(see MainLoaderTask.brs) method is executed
end sub

sub OnDetailsContentLoaded() ' invoked when content is ready to be used
    if m.DetailsScreen <> invalid
        m.DetailsScreen.content = m.detailsTask.content 
    end if
end sub