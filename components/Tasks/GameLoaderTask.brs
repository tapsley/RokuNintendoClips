sub Init()
    m.top.functionName = "GetCategoryContent"
end sub

sub GetCategoryContent()
    
    contentNode = CreateObject("roSGNode", "ContentNode")
    url = "https://www.tapsley.space/api/videos/games"
    
    
    xfer = CreateObject("roURLTransfer")
    xfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    xfer.SetURL(url)
    rsp = xfer.GetToString()

    json = ParseJson(rsp)

    print "response: " + rsp
    if json <> invalid

        value = json.Lookup("items")
        if Type(value) = "roArray" ' if parsed key value having other objects in it       
            for each item in value ' parse items and add them to contentNode
                print "item: " + item
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
    if game = "people"
        item.hdgridposterurl = "pkg:/images/People_Icon.jpg"
        item.hdposterurl = "pkg:/images/People_Icon.jpg"
        item.shortdescriptionline1 = game
    else if game = "planets"
        item.hdgridposterurl = "pkg:/images/Planet_Icon.jpg"
        item.hdposterurl = "pkg:/images/Planet_Icon.jpg"
        item.shortdescriptionline1 = game
    else if game = "starships"
        item.hdgridposterurl = "pkg:/images/Starships_Icon.jpg"
        item.hdposterurl = "pkg:/images/Starships_Icon.jpg"
        item.shortdescriptionline1 = game
    else
        print "else item/ game: " + game
        item.hdgridposterurl = "pkg:/images/People_Icon.jpg"
        item.hdposterurl = "pkg:/images/People_Icon.jpg"
        item.shortdescriptionline1 = game
    end if
    return item
end function