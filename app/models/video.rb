class Video
  include MongoMapper::Document
  
  key :url,     String
  key :content, String
  
  # Relationships
  belongs_to :user
  
  # Validation
  validates_presence_of :url, :content
  URL_REGEX = /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix
  validates_format_of :url, :with => URL_REGEX
  
end