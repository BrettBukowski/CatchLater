class VideosController < ApplicationController
  before_filter :loginRequired, :except => :addToQueue
  
  def new
    @video = Video.new
  end
  
  def create
    @video = newVideoFromParams
    @video.user = currentUser
    if @video.save
      redirect_to root_path
    else
      render :action => :new
    end
  end
  
  def destroy
    @video = Video.find_by_id(params[:id])
    @video.destroy
    redirect_to videos_path
  end
  
  def index
    @page = (params[:page] || 1).to_i
    @videos = Video.paginate(:page => @page, :order => 'created_at DESC', :per_page => 6)
  end
  
  def faves
    @page = (params[:page] || 1).to_i
    @videos = Video.paginate(:page => @page, :conditions => {:favorited => true}, :order => 'created_at DESC', :per_page => 6)    
  end
  
  # called from bookmarklet
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