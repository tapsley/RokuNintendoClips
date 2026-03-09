sub Init()
    m.top.functionName = "GetDetailsContent"
end sub

sub GetDetailsContent()
    details = []
    url = m.top.url
    isWookiee = m.top.isWookiee
    if isWookiee
        url = url + "?format=wookiee" 'append this to get wookiee translation
    end if
    rsp = GetJson(url)

    contentNode = CreateObject("roSGNode", "ContentNode")

    json = ParseJson(rsp)
    if json <> invalid
        'we want name to appear first
        if isWookiee
            value = json.Lookup("whrascwo")
        else
            value = json.Lookup("name")
        end if
        name = UCase(value)
        item = {}
        details.Push(name)
        item.title = name
        itemContent = contentNode.createChild("ContentNode")
        itemContent.setFields(item)
        for each category in json
            value = json.Lookup(category)
            if Type(value) = "roArray"
                if not isWookiee' ignore arrays if in Wookiee mode
                    'various fields contain arrays, and we need to look up each item
                    item = {}
                    item.title = UCase(category) + ": "
                    itemContent = contentNode.createChild("ContentNode")
                    itemContent.setFields(item)
                    for each starwar in value ' parse items and push them to row
                        url = starwar + "?format=json"
                        rsp2 = GetJson(url)
                        json2 = ParseJson(rsp2)
                        if json2 <> invalid
                            if category = "films"
                                name = json2.Lookup("title")
                            else
                                name = json2.Lookup("name")
                            end if
                        end if
                        item = {}
                        item.title = UCase(name)
                        itemContent = contentNode.createChild("ContentNode")
                        itemContent.setFields(item)'
                    end for
                end if
            else 
                if category <> "created" and category <> "edited" and category <> "url" and category <> "name" ' ignore these fields
                    if category = "homeworld"
                        'get the name of the homeworld from the url
                        url = value + "?format=json"
                        rsp2 = GetJson(url)
                        json2 = ParseJson(rsp2)
                        if json2 <> invalid
                            value = json2.Lookup("name")
                        end if
                    end if
                    
                    detail = UCase(category.Replace("_", " ")) + ": " + UCase(value)
                    item = {}
                    details.Push(detail)
                    item.title = detail
                    itemContent = contentNode.createChild("ContentNode")
                    itemContent.setFields(item)
                end if
            end if
        end for
    end if

    ' populate content field with root content node.
    ' Observer(see OnMainContentLoaded in MainScene.brs) is invoked at that moment
    m.top.content = contentNode

end sub

function GetJson(url as string) as string
    xfer = CreateObject("roURLTransfer")
    xfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    xfer.SetURL(url)
    rsp = xfer.GetToString()
    return rsp
end function