sub Init()
    m.top.functionName = "GetCategoryContent"
end sub

sub GetCategoryContent()
    
    contentNode = CreateObject("roSGNode", "ContentNode")
    query = m.top.input
    if query = invalid then query = ""

    game = m.top.game
    if game = invalid then game = ""

    url = "https://www.tapsley.space/api/videos/search?q=" + query
    if game <> "" then
        url = "https://www.tapsley.space/api/videos/search?game=" + game + "&q=" + query
    end if

    xfer = CreateObject("roURLTransfer")
    xfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    xfer.SetURL(url)
    rsp = xfer.GetToString()

    json = ParseJson(rsp)
    if json <> invalid

        value = json.Lookup("items")
        if Type(value) <> "roArray"
            value = json.Lookup("results")
        end if

        if Type(value) = "roArray" ' if parsed key value having other objects in it
            for each item in value ' parse items and add them to contentNode
                itemData = GetItemData(item)
                itemContent = contentNode.createChild("ContentNode")
                itemContent.setFields(itemData)
            end for
        end if
    end if

    ' populate content field with root content node.
    m.top.content = contentNode
        
end sub


function GetItemData(game as Object) as Object
    item = {}
    if Type(game) = "roAssociativeArray"
        videoUrl = ""
        if game.url <> invalid then
            videoUrl = game.url
        end if

        item.hdgridposterurl = "pkg:/images/People_Icon.jpg"
        item.hdposterurl = "pkg:/images/People_Icon.jpg"
        item.title = game.title
        item.shortdescriptionline1 = game.title
        item.shortdescriptionline2 = game.description
        item.url = videoUrl
        item.streamformat = GuessStreamFormat(videoUrl)
    else
        videoUrl = ""
        if game.url <> invalid then
            videoUrl = game.url
        end if

        item.hdgridposterurl = "pkg:/images/People_Icon.jpg"
        item.hdposterurl = "pkg:/images/People_Icon.jpg"
        item.title = "Untitled"
        item.shortdescriptionline1 = "Untitled"
        item.shortdescriptionline2 = game.description
        item.url = videoUrl
        item.streamformat = GuessStreamFormat(videoUrl)
    end if
    return item
end function

function GuessStreamFormat(url as String) as String
    lowerUrl = LCase(url)

    if Instr(1, lowerUrl, ".m3u8") > 0 then
        return "hls"
    else if Instr(1, lowerUrl, ".mpd") > 0 then
        return "dash"
    else if Instr(1, lowerUrl, ".ism") > 0 or Instr(1, lowerUrl, "manifest") > 0 then
        return "ism"
    end if

    return "mp4"
end function