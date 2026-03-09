sub init()
  m.top.setFocus(true)
  m.video = m.top.findNode("videoPlayer")
  m.video.observeField("state", "onVideoStateChanged")
  m.video.observeField("errorCode", "onVideoErrorChanged")
  m.video.observeField("errorMsg", "onVideoErrorChanged")
  m.top.observeField("itemUrl", "onItemUrlChanged")

  if m.top.itemUrl <> invalid and m.top.itemUrl <> ""
    setVideo(m.top.itemUrl)
  end if
end sub

sub onItemUrlChanged()
  if m.top.itemUrl <> invalid and m.top.itemUrl <> ""
    print "[VideoScreen] Received URL: " + m.top.itemUrl
    setVideo(m.top.itemUrl)
  end if
end sub

function setVideo(url as String) as void
  videoContent = createObject("RoSGNode", "ContentNode")
  videoContent.url = url
  videoContent.title = "Test Video"
  videoContent.streamformat = "mp4"

  m.video.content = videoContent
  print "[VideoScreen] Playing URL: " + videoContent.url
  m.video.control = "play"
end function

sub onVideoStateChanged()
  if m.video = invalid then return
  print "[VideoScreen] state="; m.video.state; " position="; m.video.position
  if m.video.state = "error"
    print "[VideoScreen] ERROR code="; m.video.errorCode; " msg="; m.video.errorMsg
  end if
end sub

sub onVideoErrorChanged()
  if m.video = invalid then return
  print "[VideoScreen] errorCode="; m.video.errorCode; " errorMsg="; m.video.errorMsg
end sub


function onKeyEvent(key as String, press as Boolean) as Boolean
    handled = false

    if press
        if key = "back" and m.video.control = "play"
            m.video.control = "stop"
            'don't set handle to true yet so we also navigate back to previous screen
        end if
    end if

    return handled
end function