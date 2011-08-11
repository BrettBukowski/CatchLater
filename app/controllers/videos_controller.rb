class VideosController < ApplicationController
  before_filter :loginRequired, :except => :addToQueue
  
  def new
    @video = Video.new
  end
  
  def create
    @video = Video.new do |v|
      v.url = params[:url]
      v.type = params[:type]
      v.source = params[:source]
      v.webpageUrl = params[:webpageUrl]
      v.user = currentUser
    end
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
    @videos = Video.paginate(:page => @page, :order => 'created_at DESC')
  end
  
  def addToQueue
    if currentUser
      @video = Video.new do |v|
        v.url = params[:url]
        v.type = params[:type]
        v.source = params[:source]
        v.webpageUrl = params[:webpageUrl]
        v.user = currentUser
      end
      if @video.save
        renderJSON @video.to_json
      else
        renderJSON @video.errors
      end
    else
      renderJSON [:error => "login required"]
    end
  end
end