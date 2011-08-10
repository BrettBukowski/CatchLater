class VideosController < ApplicationController
  before_filter :loginRequired, :except => :addToQueue
  
  def new
    @video = Video.new
  end
  
  def create
    @video = Video.new
    @video.url = params[:url]
    @video.type = params[:type]
    @video.source = params[:source]
    @video.webpageUrl = params[:webpageUrl]
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
    @videos = Video.paginate(:page => @page, :per_page => 20)
  end
  
  def addToQueue
    if currentUser
      @video = Video.new
      @video.url = params[:url]
      @video.type = params[:type]
      @video.source = params[:source]
      @video.webpageUrl = params[:webpageUrl]
      @video.user = currentUser
      @video.save
      renderJSON @video.to_json
    else
      header :not_acceptable
    end
  end
end