sub Init()
    m.top.functionName = "GetCategoryContent"
end sub

sub GetCategoryContent()
    
    contentNode = CreateObject("roSGNode", "ContentNode")
    url = "https://www.tapsley.space/api/videos/search?game=" + m.top.game + "&q="  + m.top.input

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
        item.hdgridposterurl = "pkg:/images/People_Icon.jpg"
        item.hdposterurl = "pkg:/images/People_Icon.jpg"

        item.shortdescriptionline1 = game.title
        item.shortdescriptionline2 = game.url
    else
        item.hdgridposterurl = "pkg:/images/People_Icon.jpg"
        item.hdposterurl = "pkg:/images/People_Icon.jpg"
        item.shortdescriptionline1 = "Untitled"
        item.shortdescriptionline2 = game.url
    end if
    return item
end function