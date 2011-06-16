class Video
  include MongoMapper::Document
  
  key :id, String
  key :url, String
  key :title, String
  key :content, String
  key :added, Time
  
  key :userId, ObjectId
  
  # Relationships
  belongs_to :user
  
  # Validation
  validates_presence_of :url, :content
  URL_REGEX = /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix
  validates_format_of :url, :with => URL_REGEX
  
  def self.find_by_id(id)
    first(:conditions => {:id => id})
  end
end