class VideosController < ApplicationController
  before_filter :login_required, :except => :addToQueue
  
  def new
    @video = Video.new
  end
  
  def create
    @video = new_video_from_params
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
  
  def destroy
    @video = Video.find_by_id(params[:id])
    @video.destroy
    respond_to do |format|
      format.html { redirect_to videos_path }
      format.js
      format.json { head :ok }
    end
  end
  
  def index
    @page = (params[:page] || 1).to_i
    @videos = Video.paginate(page: @page, conditions: {favorited: false}, order: 'created_at DESC', per_page: 3)
    get_tags_for_current_user
    respond_to do |format|
      format.js
      format.html
    end
  end
  
  def faves
    @page = (params[:page] || 1).to_i
    @videos = Video.paginate(page: @page, conditions: {favorited: true}, order: 'created_at DESC', per_page: 3)   
    get_tags_for_current_user 
    respond_to do |format|
      format.js
      format.html
    end
  end
  
  def set_tags
    if params[:id].present?
      @video = Video.find_by_id(params[:id])
      @video.tags = params[:tags].strip.split(',').uniq
      @video.save
      invalidate_tags_for_current_user
      render json: @video.tags
    else
      render json: 'oh no'
    end
  end
  
  def tags
    get_tags_for_current_user
  end
  
  def tagged
    @tag = params[:with]
    @page = (params[:page] || 1).to_i
    @videos = Video.paginate(page: @page, conditions: {tags: @tag}, order: 'created_at DESC', per_page: 3)
    get_tags_for_current_user
    respond_to do |format|
      format.js
      format.html
    end
  end
  
  # JSONP request made from bookmarklet
  def add_to_queue
    if current_user
      @video = new_video_from_params
      @video.user = current_user
      if @video.save
        render_jsonp @video.to_json
      else
        render_jsonp @video.errors
      end
    else
      render_jsonp [error: "login required"]
    end
  end
  
  private
  def new_video_from_params
    video = Video.new
    video.type = params[:type]
    video.source = params[:source]
    video.videoID = params[:videoID]
    video.webpageUrl = params[:webpageUrl]
    return video
  end
  
  def get_tags_for_current_user
    unless fragment_exist?("#{current_user.id}:tags")
      require 'user_video_tags'
      @tags = UserVideoTags.get(current_user.id)
    end
  end
  
  def invalidate_tags_for_current_user
    expire_fragment("#{current_user.id}:tags")
  end
end