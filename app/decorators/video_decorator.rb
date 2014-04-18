class VideoDecorator < Draper::Decorator
  delegate_all

  # URLs to use for iframe src
  VIDEO_EMBEDS = {
    dailymotion: 'http://www.dailymotion.com/embed/video/%s',
    gamespot:    'http://www.gamespot.com/videos/embed/%s/',
    videobam:    'http://videobam.com/widget/%s',
    liveleak:    'http://www.liveleak.com/ll_embed?f=%s',
    youtube:     '//www.youtube.com/embed/%s',
    mixergy:     '//fast.wistia.com/embed/iframe/%s',
    vimeo:       '//player.vimeo.com/video/%s',
    blip:        'http://blip.tv/play/%s.html',
    fora:        '//fora.tv/embed?id=%s&amp;type=c',
    npr:         'http://www.npr.org/templates/event/embeddedVideo.php?storyId=%s',
    ted:         'http://embed.ted.com/talks/%s.html',
    mtv:         'http://media.mtvnservices.com/mgid:uma:video:mtv.com:%s/',
    nbc:         'http://www.nbc.com/assets/video/widget/widget.html?vid=%s',
    ign:         'http://widgets.ign.com/video/embed/content.html?url=http://www.ign.com/videos/%s',
  }
  # List of canonical URLs for videos (if there is one)
  VIDEO_URLS = {
    dailymotion: 'http://www.dailymotion.com/video/%s',
    videobam:    'http://videobam.com/%s',
    youtube:     'http://www.youtube.com/watch?v=%s',
    vimeo:       'http://vimeo.com/%s',
    npr:         'http://www.npr.org/templates/event/embeddedVideo.php?storyId=%s',
    ted:         'https://www.ted.com/talks/%s',
    mtv:         'http://www.mtvu.com/video/?vid=%s',
    nbc:         'http://www.nbc.com/assets/video/widget/widget.html?vid=%s',
    ign:         'http://www.ign.com/videos/%s',
  }

  def embed_url
    VIDEO_EMBEDS[object.source.to_sym] % videoID
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

  # Backwards compatibility for old-style TED videos.
  def video_url
    "http://video.ted.com/#{videoID}"
  end

  def embed?
    object.source == 'ted' && videoID.end_with?('.mp4')
  end

  def poster
    "/assets/tedPoster.png" if object.source == 'ted'
  end
end
