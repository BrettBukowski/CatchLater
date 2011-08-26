class Video
  include MongoMapper::Document
  
  # key :url,         String, :required => true
  key :videoID,     String, :required => true
  key :webpageUrl,  String, :required => true
  key :type,        String, :required => true
  key :source,      String, :required => true
  key :title,       String
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
  validates_presence_of :webpageUrl, :type, :source, :videoID # :url
  # validates_format_of :url, :with => URL_REGEX
  validates_format_of :webpageUrl, :with => URL_REGEX
  validates_inclusion_of :source, :in => SUPPORTED_SOURCES, :message => "Sorry, your source %{value} isn't supported"
  
  def self.find_by_id(id)
    first(:conditions => {:id => id})
  end
  
  def embed
    if self.type == "iframe"
      "<iframe src='#{url}' width='560' height='349' frameborder='0' allowfullscreen></iframe>"
    elsif self.source == 'ted'
      "<iframe src='http://video.ted.com/#{id}' width='520' height='300' frameborder='0' allowfullscreen></iframe>"
    end
  end
end