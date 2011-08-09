require 'pp'

class Video
  include MongoMapper::Document
  
  key :url,         String, :required => true
  key :webpageUrl,  String, :required => true
  key :title,       String
  key :type,        String, :required => true
  key :source,      String, :required => true
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
  validates_presence_of :url, :webpageUrl, :type, :source
  validates_format_of :url, :with => URL_REGEX
  validates_format_of :webpageUrl, :with => URL_REGEX
  validates_inclusion_of :source, :in => SUPPORTED_SOURCES, :message => "Sorry, your source %{value} isn't supported"
  
  def self.find_by_id(id)
    first(:conditions => {:id => id})
  end
end