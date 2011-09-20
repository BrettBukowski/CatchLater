class Video
  include MongoMapper::Document

  key :videoID,     String, :required => true
  key :webpageUrl,  String, :required => true
  key :type,        String, :required => true
  key :source,      String, :required => true
  key :title,       String
  key :tags,        Array
  key :user_id,     ObjectId

  timestamps!

  # Relationships
  belongs_to :user

  # Validation
  URL_REGEX = /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix
  SUPPORTED_SOURCES = [
    'youtube',
    'vimeo',
    'ted',
    'blip',
    'adultswim'
  ]
  TYPES = [
    'iframe',
    'video',
    'object',
    'embed'
  ]
  validates_presence_of :webpageUrl, :type, :source, :videoID
  validates_format_of :webpageUrl, :with => URL_REGEX
  validates_inclusion_of :source, :in => SUPPORTED_SOURCES, :message => "Sorry, your source %{value} isn't supported"

  def self.find_by_id(id)
    first(:conditions => {:id => id})
  end

  def self.find_by_tag(tag)
    all(:tags => ["#{tag}"])
  end

  def embed
    if self.source == 'youtube'
      url = "http://www.youtube.com/embed/#{videoID}"
    elsif self.source == 'vimeo'
      url = "http://player.vimeo.com/video/#{videoID}"
    elsif self.source == 'ted'
      poster = "http://images.ted.com/images/ted/tedindex/embed-posters/" +
          self.videoID.gsub(/-[A-Za-z0-9]+\.mp4/, '-embed.jpg').split('/').last
      return "<video src='http://video.ted.com/#{videoID}' poster='#{poster}' controls preload='none'>
              Your browser doesn't support this type of video :(
              </video>"
    end
    return "<iframe src='#{url}' allowfullscreen></iframe>"
  end
end