sub ShowHomeScreen()
    m.HomeScreen = CreateObject("roSGNode", "HomeScreen")
    m.HomeScreen.ObserveField("selectedGame", "OnGameChosen")
    m.HomeScreen.ObserveField("searchRequested", "OnHomeSearchChosen")
    m.HomeScreen.ObserveField("randomRequested", "OnHomeRandomChosen")
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
    m.HomeScreen.selectedGame = ""
    ' Show details immediately, then populate it when content loads.
    ShowDetailsScreen()
    if m.DetailsScreen <> invalid then
        m.DetailsScreen.gameTitle = ToDisplayGameTitle(game)
    end if
    RunContentTask(game, "")
end sub

sub OnHomeSearchChosen()
    if m.HomeScreen = invalid then return
    ShowSearchScreen()
end sub

sub OnHomeRandomChosen()
    if m.HomeScreen = invalid then return
    StartRandomVideoStream()
end sub

function ToDisplayGameTitle(game as String) as String
    if game = invalid or game = "" then return ""

    words = game.Split(" ")
    formattedWords = []
    for each rawWord in words
        word = rawWord.Trim()
        if word = "" then
            continue for
        end if

        firstChar = UCase(Left(word, 1))
        if Len(word) > 1 then
            formattedWords.Push(firstChar + LCase(Mid(word, 2)))
        else
            formattedWords.Push(firstChar)
        end if
    end for

    return formattedWords.Join(" ")
end function