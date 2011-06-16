class VideosController < ApplicationController
  before_filter :loginRequired
  
  def new
    @video = Video.new
  end
  
  def add
    @video = Video.new
    @video.user = currentUser
    @video.save
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