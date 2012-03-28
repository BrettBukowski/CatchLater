class VideosController < ApplicationController
  # Ensure the user's logged in; #add_to_queue sends its own
  # response to unauthenticated users
  before_filter :login_required, :except => :add_to_queue
  
  # New view.
  # Renders the view
  def new
    @video = Video.new
  end
  
  # Creates a new view from the supplied post params.
  # Responds to HTML, JSON
  def create
    @video = Video.new(params)
    @video.user = current_user
    respond_to do |format|
      if @video.save
        format.html { redirect_to root_path }
        format.json { render json: @video }
      else
        format.html { render :action => :new }
        format.json { render json: @video.errors }
      end
    end
  end
  
  # Toggles the specified video's 'favorited'
  # field. Flips its current state rather than
  # accepting a state to set.
  # Requires POST params: id
  # Responds to HTML, JS, JSON
  def toggle_fave
    @video = Video.find_by_id(params[:id])
    @video.favorited = !@video.favorited
    respond_to do |format|
      if @video.save
        format.html { redirect_to :back }
        format.js
        format.json { render json: @video }
      end
    end
  end
  
  # Destroys the specified video.
  # Requires DELETE params: id
  # Responds to HTML, JS, JSON
  def destroy
    @video = Video.find_by_id(params[:id])
    @video.destroy
    respond_to do |format|
      format.html { redirect_to videos_path }
      format.js
      format.json { head :ok }
    end
  end
  
  # Renders all non-favorited videos.
  # Optional GET params: page
  # Responds to HTML, JS
  def index
    @page = (params[:page] || 1).to_i
    @videos = Video.for_user(current_user, {favorited: false}, @page)
    get_tags_for_current_user
    respond_to do |format|
      format.js
      format.html
    end
  end
  
  # Renders all favorited videos.
  # Optional GET params: page
  # Responds to HTML, JS
  def faves
    @page = (params[:page] || 1).to_i
    @videos = Video.for_user(current_user, {favorited: true}, @page)
    get_tags_for_current_user 
    respond_to do |format|
      format.js
      format.html
    end
  end
  
  # Sets tags on the specified video.
  # Tags are simply set, rather than
  # appended, so all tags should always
  # be specified.
  # Required POST params: id, tags
  #  `tags` should be a comma-separated
  #  list of strings.
  # Responds to JSON
  def set_tags
    if params[:id].present?
      @video = Video.find_by_id(params[:id])
      @video.tags = params[:tags].strip.split(',').uniq
      @video.save
      invalidate_tags_for_current_user
      render json: @video.tags
    else
      render json: {error: 'No video specified'}
    end
  end
  
  # Renders all tags for 
  # the user's videos.
  def tags
    get_tags_for_current_user
  end
  
  # Renders all videos tagged with the
  # given string.
  # Required GET params: with
  # Optional GET params: page
  # Responds to JS, HTML
  def tagged
    @tag = params[:with]
    @page = (params[:page] || 1).to_i
    @videos = Video.for_user(current_user, {tags: @tag}, @page)
    get_tags_for_current_user
    respond_to do |format|
      format.js
      format.html
    end
  end
  
  # Renders all videos as an atom feed.
  # Required GET params: key
  def feed
    @videos = Video.all(conditions: {user_id: (User.first(conditions: {feedKey: params[:key]}) || User.new).id})
    respond_to do |format|
      format.atom
    end
  end
  
  # JSONP request made from bookmarklet.
  def add_to_queue
    if current_user
      @video = Video.new(params)
      @video.user = current_user
      if @video.save
        render_jsonp @video.to_json
      else
        render_jsonp @video.errors.to_json
      end
    else
      render_jsonp Hash[login_required: true].to_json
    end
  end
  
  private
  
  # Retrieves the tags for all of the user's videos
  # and sets it as an instance variable.
  # Checks for view fragment caching.
  # TK - replace with Redis
  def get_tags_for_current_user
    unless fragment_exist?("#{current_user.id}:tags")
      require 'user_video_tags'
      @tags = UserVideoTags.get(current_user.id)
    end
  end
  
  # Expires the tag view fragment cache.
  def invalidate_tags_for_current_user
    expire_fragment("#{current_user.id}:tags")
  end
end