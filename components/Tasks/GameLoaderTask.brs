sub Init()
    m.top.functionName = "LoadGamesContent"
end sub

sub LoadGamesContent()
    
    contentNode = CreateObject("roSGNode", "ContentNode")
    url = "https://www.tapsley.space/api/videos/games"
    
    
    xfer = CreateObject("roURLTransfer")
    xfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    xfer.SetURL(url)
    rsp = xfer.GetToString()

    json = ParseJson(rsp)

    if json <> invalid

        imageByGame = CreateObject("roAssociativeArray")
        gameImages = json.Lookup("gameImages")
        if Type(gameImages) = "roArray"
            for each imageItem in gameImages
                if Type(imageItem) = "roAssociativeArray"
                    gameName = ""
                    if imageItem.name <> invalid then gameName = LCase(imageItem.name)
                    imageUrl = ""
                    if imageItem.imageUrl <> invalid then imageUrl = imageItem.imageUrl
                    if gameName <> "" and imageUrl <> "" then
                        imageByGame[gameName] = imageUrl
                    end if
                end if
            end for
        end if

        value = json.Lookup("items")
        if Type(value) = "roArray"
            for each item in value
                itemData = GetItemData(item, imageByGame)
                itemContent = contentNode.createChild("ContentNode")
                itemContent.setFields(itemData)
            end for
        end if

    end if

    ' populate content field with root content node.
    m.top.content = contentNode
        
end sub


function GetItemData(game as Object, imageByGame as Object) as Object
    item = {}

    gameName = ""
    if Type(game) = "roString" then
        gameName = game
    else if Type(game) = "roAssociativeArray"
        if game.name <> invalid then
            gameName = game.name
        else if game.game <> invalid then
            gameName = game.game
        end if
    end if

    gameKey = LCase(gameName)
    poster = "pkg:/images/channelPoster_hd.png"

    if imageByGame <> invalid and imageByGame[gameKey] <> invalid and imageByGame[gameKey] <> "" then
        poster = imageByGame[gameKey]
    end if

    item.hdgridposterurl = poster
    item.hdposterurl = poster
    item.shortdescriptionline1 = gameName

    return item
end function