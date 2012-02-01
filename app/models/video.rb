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
  SUPPORTED_SOURCES = %w[youtube vimeo ted blip adultswim]
  TYPES = %w[iframe video object embed]

  validates :webpageUrl, :type, :source, :videoID, presence: true
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

  def embed
    if self.source == 'youtube'
      url = "http://www.youtube.com/embed/#{videoID}"
    elsif self.source == 'vimeo'
      url = "http://player.vimeo.com/video/#{videoID}"
    elsif self.source == 'ted'
      poster = "http://images.ted.com/images/ted/tedindex/embed-posters/" +
          self.videoID.gsub('_', '-').gsub(/-[A-Za-z0-9]+\.mp4/, '.embed_thumbnail.jpg').split('/').last
      return %{<video src='http://video.ted.com/#{videoID}' poster='#{poster}' controls preload='none'>
              Your browser doesn't support this type of video :(
              </video>}
    end
    return "<iframe src='#{url}' allowfullscreen></iframe>"
  end
  
  def link
    if self.source == 'youtube'
      return "http://www.youtube.com/watch?v=#{videoID}"
    elsif self.source == 'vimeo'
      return "http://vimeo.com/#{videoID}"
    end
  end
end