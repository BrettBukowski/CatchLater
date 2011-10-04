class VideosController < ApplicationController
  before_filter :loginRequired, :except => :addToQueue
  
  def new
    @video = Video.new
  end
  
  def create
    @video = newVideoFromParams
    @video.user = currentUser
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
  
  def toggleFave
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
    @videos = Video.paginate(:page => @page, :order => 'created_at DESC', :per_page => 6)
  end
  
  def faves
    @page = (params[:page] || 1).to_i
    @videos = Video.paginate(:page => @page, :conditions => {:favorited => true}, :order => 'created_at DESC', :per_page => 6)    
  end
  
  # JSONP request made from bookmarklet
  def addToQueue
    if currentUser
      @video = newVideoFromParams
      @video.user = currentUser
      if @video.save
        renderJSON @video.to_json
      else
        renderJSON @video.errors
      end
    else
      renderJSON [:error => "login required"]
    end
  end
  
  private
  def newVideoFromParams
    video = Video.new
    video.type = params[:type]
    video.source = params[:source]
    video.videoID = params[:videoID]
    video.webpageUrl = params[:webpageUrl]
    return video
  end
end