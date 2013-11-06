class VideoDecorator < Draper::Decorator
  delegate_all

  # URLs to use for iframe src
  VIDEO_EMBEDS = {
    dailymotion: 'http://www.dailymotion.com/embed/video/%s',
    gamespot:    'http://www.gamespot.com/videos/embed/%s/',
    videobam:    'http://videobam.com/widget/%s',
    youtube:     '//www.youtube.com/embed/%s',
    mixergy:     '//fast.wistia.com/embed/iframe/%s',
    vimeo:       '//player.vimeo.com/video/%s',
    blip:        'http://blip.tv/play/%s.html',
    fora:        '//fora.tv/embed?id=%s&amp;type=c',
    npr:         'http://www.npr.org/templates/event/embeddedVideo.php?storyId=%s',
    ted:         'http://video.ted.com/%s',
    mtv:         'http://media.mtvnservices.com/mgid:uma:video:mtv.com:%s/',
    nbc:         'http://www.nbc.com/assets/video/widget/widget.html?vid=%s',
  }
  # List of canonical URLs for videos (if there is one)
  VIDEO_URLS = {
    dailymotion: 'http://www.dailymotion.com/video/%s',
    videobam:    'http://videobam.com/%s',
    youtube:     'http://www.youtube.com/watch?v=%s',
    vimeo:       'http://vimeo.com/%s',
    npr:         'http://www.npr.org/templates/event/embeddedVideo.php?storyId=%s',
    mtv:         'http://www.mtvu.com/video/?vid=%s',
    nbc:         'http://www.nbc.com/assets/video/widget/widget.html?vid=%s',
  }

  def embed_url
    VIDEO_EMBEDS[object.source.to_sym] % videoID
  end

  def embed_element
    url = VIDEO_EMBEDS[object.source.to_sym] % videoID

    # Yeahh... Special case for TED vids. But at least it's HTML5 ;)
    return %{<video src='#{url}' poster='/assets/tedPoster.png' controls preload='none'>
           Your browser doesn't support this type of video :(
           </video>} if object.source == 'ted'

    "<iframe src='#{url}' allowfullscreen></iframe>"
  end

  def link
    url = VIDEO_URLS[object.source.to_sym]
    if url
      url % videoID
    else
      object.webpageUrl
    end
  end

  def source
    object.source
  end
end
