sub Init()
	m.top.functionName = "LoadRandomContent"
end sub

sub LoadRandomContent()
	root = CreateObject("roSGNode", "ContentNode")

	xfer = CreateObject("roURLTransfer")
	xfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
	xfer.SetURL("https://www.tapsley.space/api/videos/random")

	rsp = xfer.GetToString()
	if rsp = invalid or rsp = "" then
		m.top.error = "Empty random API response"
		m.top.content = root
		return
	end if

	json = ParseJson(rsp)
	if Type(json) <> "roAssociativeArray" then
		m.top.error = "Invalid random API response"
		m.top.content = root
		return
	end if

	itemData = json.Lookup("item")
	if Type(itemData) <> "roAssociativeArray" then
		m.top.error = "Missing random item"
		m.top.content = root
		return
	end if

	url = ""
	if itemData.url <> invalid then url = itemData.url
	if url = "" then
		m.top.error = "Random item missing url"
		m.top.content = root
		return
	end if

	title = "Random Clip"
	if itemData.title <> invalid and itemData.title <> "" then title = itemData.title

	description = ""
	if itemData.description <> invalid then description = itemData.description

	poster = "pkg:/images/People_Icon.jpg"
	if itemData.thumbnail <> invalid and itemData.thumbnail <> "" then poster = itemData.thumbnail

	clip = root.CreateChild("ContentNode")
	clip.SetFields({
		title: title
		shortdescriptionline1: title
		shortdescriptionline2: description
		hdposterurl: poster
		hdgridposterurl: poster
		url: url
		streamformat: GuessStreamFormat(url)
	})

	m.top.error = ""
	m.top.content = root
end sub

function GuessStreamFormat(url as String) as String
	lowerUrl = LCase(url)
	if Instr(1, lowerUrl, ".m3u8") > 0 then return "hls"
	if Instr(1, lowerUrl, ".mpd") > 0 then return "dash"
	if Instr(1, lowerUrl, ".ism") > 0 or Instr(1, lowerUrl, "manifest") > 0 then return "ism"
	return "mp4"
end function
