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
  SUPPORTED_SOURCES = %w[youtube vimeo ted npr gamespot]
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
  
  def self.for_user(current_user, condition, page_number)
    self.paginate(page: page_number, conditions: condition.merge({user_id: current_user.id}), order: 'created_at DESC', per_page: 3)
  end
  
  VIDEO_EMBEDS = {
    gamespot: 'http://www.gamespot.com/videoembed/%s/&vidSize=560',
    youtube:  'http://www.youtube.com/embed/%s',
    vimeo:    'http://player.vimeo.com/video/%s',
    npr:      'http://www.npr.org/templates/event/embeddedVideo.php?storyId=%s',
    ted:      'http://video.ted.com/%s',
  }

  def embed(iframe = true)
    url = VIDEO_EMBEDS[source.to_sym] % videoID

    return %{<video src='#{url}' poster='/assets/tedPoster.png' controls preload='none'>
           Your browser doesn't support this type of video :(
           </video>} if iframe && source == 'ted'

    if iframe
      "<iframe src='#{url}' allowfullscreen></iframe>"
    else
      url
    end
  end
  
  def link
    if self.source == 'youtube'
      return "http://www.youtube.com/watch?v=#{videoID}"
    elsif self.source == 'vimeo'
      return "http://vimeo.com/#{videoID}"
    elsif self.source == 'npr'
      return "http://www.npr.org/templates/event/embeddedVideo.php?storyId=#{videoID}"
    end
    self.webpageUrl
  end
end