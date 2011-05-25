class VideoController < ApplicationController
  before_filter :loginRequired
  
  def new
    @video = Video.new
  end
  
  def add
    @video = Video.new
    @video.user = currentUser
    if @story.save
  end
  
  def remove
    @video = Video.find_by_id(params[:id])
    @video.destroy
  end
  
  def index
    
  end
  
end