class Video
  include MongoMapper::Document

  key :videoID,     String, required: true
  key :webpageUrl,  String, required: true
  key :type,        String, required: true
  key :source,      String, required: true
  key :title,       String
  key :tags,        Array
  key :favorited,   Boolean, default: false
  key :user_id,     ObjectId

  timestamps!

  # Relationships
  belongs_to :user

  # Validation
  URL_REGEX = /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix
  # OFFICIAL list of supported video sources
  SUPPORTED_SOURCES = %w[youtube vimeo ted npr gamespot mtv dailymotion]
  # The type of video that's been scraped
  TYPES = %w[iframe video object embed]

  validates :webpageUrl, format: {
    with: URL_REGEX,
    message: "The web page's URL is invalid"
  }
  validates :source, inclusion: {
    in: SUPPORTED_SOURCES,
    message: "Sorry, your source %{value} isn't supported"
  }
  validates :type, inclusion: {
    in: TYPES,
    message: "The type of video isn't supported"
  }

  def self.find_by_id(id)
    first(conditions: {id: id})
  end

  def self.find_by_tag(tag)
    all(tags: ["#{tag}"])
  end
  
  # Retrieves videos for the specified user.
  # current_user: User instance (required)
  # condition: Hash conditions (optional)
  # page_number: Integer (optional)
  def self.for_user(current_user, condition, page_number)
    self.paginate(page: page_number || 1, conditions: condition.merge({user_id: current_user.id}), order: 'created_at DESC', per_page: 3)
  end
  
  VIDEO_EMBEDS = {
    dailymotion: 'http://www.dailymotion.com/embed/video/%s',
    gamespot:    'http://www.gamespot.com/videoembed/%s/&vidSize=560',
    youtube:     'http://www.youtube.com/embed/%s',
    vimeo:       'http://player.vimeo.com/video/%s',
    npr:         'http://www.npr.org/templates/event/embeddedVideo.php?storyId=%s',
    ted:         'http://video.ted.com/%s',
    mtv:         'http://media.mtvnservices.com/mgid:uma:video:mtv.com:%s/',
  }

  # Retrieves the embed URL for the video
  # Returns String
  def embed_url
    VIDEO_EMBEDS[source.to_sym] % videoID
  end
  
  # Retrieves the HTML for the video
  # Returns String
  def embed_element
    url = VIDEO_EMBEDS[source.to_sym] % videoID

    # Yeahh... Special case for TED vids. But at least it's HTML5 ;)
    return %{<video src='#{url}' poster='/assets/tedPoster.png' controls preload='none'>
           Your browser doesn't support this type of video :(
           </video>} if source == 'ted'

    "<iframe src='#{url}' allowfullscreen></iframe>"
  end
  
  VIDEO_URLS = {
    dailymotion: 'http://www.dailymotion.com/video/%s',
    youtube:     'http://www.youtube.com/watch?v=%s',
    vimeo:       'http://vimeo.com/%s',
    npr:         'http://www.npr.org/templates/event/embeddedVideo.php?storyId=%s',
    mtv:         'http://www.mtvu.com/video/?vid=%s',
  }
  
  # Retrieves a link to the video page.
  # If one isn't known, returns the URL
  # of the source web page where the video
  # was added from
  # Returns String
  def link
    url = VIDEO_URLS[source.to_sym]
    if url
      url % videoID
    else
      self.webpageUrl
    end
  end
end