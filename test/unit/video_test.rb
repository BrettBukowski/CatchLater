require 'test_helper'

class VideoTest < ActiveSupport::TestCase
  test "web page url is required" do
    video = Video.new(videoID: '123', type: 'iframe', source: 'youtube')
    assert video.invalid?
    assert video.errors[:webpageUrl].any?
  end
  
  test "web page url must be valid" do
    video = Video.new(videoID: '123', type: 'iframe', source: 'youtube', webpageUrl: 'abc')
    assert video.invalid?
    assert video.errors[:webpageUrl].any?
  end
  
  test "source is required" do
    video = Video.new(videoID: '123', type: 'iframe', webpageUrl: 'http://sdfe.ds')
    assert video.invalid?
    assert video.errors[:source].any?
  end
  
  test "source must be officially supported" do
    video = Video.new(videoID: '123', type: 'iframe', source: 'i', webpageUrl: 'http://sdfe.ds')
    assert video.invalid?
    assert video.errors[:source].any?
    ['youtube', 'vimeo', 'ted', 'npr', 'gamespot'].each do |src|
      video = build(:video, source: src)
      assert video.valid?
    end
  end
  
  test "type is required" do
    video = Video.new(videoID: '123', source: 'youtube', webpageUrl: 'http://sdfe.ds')
    assert video.invalid?
    assert video.errors[:type].any?
  end
  
  test "type must be normal" do
    video = Video.new(videoID: '123', type: 'wat', source: 'youtube', webpageUrl: 'http://sdfe.ds')
    assert video.invalid?
    assert video.errors[:type].any?
    ['iframe', 'object', 'embed', 'video'].each do |type|
      video = build(:video, type: type)
      assert video.valid?
    end
  end
  
  test "video id is required" do
    video = Video.new(source: 'youtube', webpageUrl: 'http://sdfe.ds')
    assert video.invalid?
    assert video.errors[:videoID].any?
  end
end