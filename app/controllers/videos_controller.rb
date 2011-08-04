class VideosController < ApplicationController
  before_filter :loginRequired
  
  def new
    @video = Video.new
  end
  
  def create
    @video = Video.new
    @video.user = currentUser
    if @video.save
      redirect_to root_path
    else
      render :action => :new
    end
  end
  
  def remove
    @video = Video.find_by_id(params[:id])
    @video.destroy
  end
  
  def index
    @page = (params[:page] || 1).to_i
    @videos = Video.paginate(:page => @page, :per_page => 20)
  end
end