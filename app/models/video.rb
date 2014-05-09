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

  belongs_to :user

  URL_REGEX = /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix
  SUPPORTED_SOURCES = %w[youtube vimeo ted npr gamespot mtv dailymotion blip mixergy videobam nbc liveleak ign]
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

  def self.find_by_tag(tag)
    all(tags: ["#{tag}"])
  end

  def self.for_user(current_user, condition = {}, page_number = 1)
    self.paginate(page: page_number || 1, conditions: condition.merge({user_id: current_user.id}), order: 'created_at DESC', per_page: 3)
  end
end
