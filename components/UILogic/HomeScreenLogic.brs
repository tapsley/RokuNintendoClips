sub ShowHomeScreen()
    m.HomeScreen = CreateObject("roSGNode", "HomeScreen")
    m.HomeScreen.ObserveField("selectedGame", "OnGameChosen")
    m.HomeScreen.ObserveField("searchRequested", "OnHomeSearchChosen")
    RunGameTask()
    print "Home screen created"
    ShowScreen(m.HomeScreen) ' show HomeScreen
end sub

sub OnGameChosen()
    game = m.HomeScreen.selectedGame
    gameGrid = m.HomeScreen.FindNode("gameGrid")
    if gameGrid <> invalid and m.selectedIndex <> invalid and m.selectedIndex.Count() > 0 then
        m.selectedIndex[0] = gameGrid.itemSelected
    end if

    m.currentGame = game
    m.HomeScreen.selectedGame = "" 'reset selected game
    'ShowSearchScreen(game)
    ShowDetailsScreen() 'show details screen with no content while we load results
    RunContentTask(game, "")
end sub

sub OnHomeSearchChosen()
    if m.HomeScreen = invalid then return
    ShowSearchScreen()
end sub