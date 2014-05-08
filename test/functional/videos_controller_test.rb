require 'test_helper'

class VideosControllerTest < ActionController::TestCase
  setup do
    @videoParams = {
      videoID: 'y9K18CGEeiI',
      webpageUrl: 'https://www.youtube.com/watch?v=y9K18CGEeiI',
      type: 'object',
      source: 'youtube'
    }
  end

  def logged_in_user
    @user = create(:user_with_videos)
    session[:userId] = @user.id
  end

  def tag_video
    video = Video.first
    video.tags = ['foo', 'bar', 'baz', 'banana']
    video.save
    video
  end

  test "shouldn't get index without a logged in user" do
    get :index
    assert_response 302
  end

  test "should get index with a logged in user" do
    logged_in_user
    get :index
    assert_response :success
  end

  test "new video form" do
    logged_in_user
    get :new
    assert_response :success
    assert_select 'form', 1
    assert_select 'form[action="/videos"]', 1
    assert_select 'input#videoID', 1
    assert_select 'input#webpageUrl', 1
    assert_select 'input#type', 1
    assert_select 'input#source', 1
  end

  test "create new video" do
    logged_in_user
    assert_difference 'Video.count' do
      post :create, video: @videoParams
    end
    assert_redirected_to root_path
  end

  test "favorite video" do
    logged_in_user
    request.env["HTTP_REFERER"] = videos_path
    post :toggle_fave, id: Video.first
    assert_redirected_to videos_path
  end

  test "should delete video" do
    logged_in_user
    assert_difference 'Video.count', -1 do
      delete :destroy, id: Video.first
    end
    assert_redirected_to videos_path
  end

  test "should show favorited videos" do
    logged_in_user
    video = Video.first
    video.favorited = true
    video.save
    get :faves
    assert_response :success
    assert_select "div##{video.id}.video", 1
    assert_select '.video iframe', 1
  end

  test "should be able to set tags" do
    logged_in_user
    post :set_tags, id: Video.first, tags: 'foo,bar,baz,banana'
    assert_response :success
  end

  test "should show video tags" do
    logged_in_user
    tag_video
    get :tags
    assert_response :success
    assert_select '.tagList .tag', 4
  end

  test "should show tagged videos" do
    logged_in_user
    video = tag_video
    get :tagged, with: video.tags.first
    assert_response :success
    assert_select "div##{video.id}.video", 1
    assert_select "input[value='#{video.tags.join(',')}']"
  end

  test "should show feed" do
    user = create(:user_with_videos)
    get :feed, format: :atom, key: user.feedKey
    assert_response :success
    assert_select 'iframe', true
  end

  test "should create video for logged in user" do
    logged_in_user
    assert_difference 'Video.count' do
      get :bookmark, @videoParams.merge({callback: 'banana'})
      assert_response :success
      assert_equal response.header['Content-Type'], 'application/javascript; charset=utf-8'
      assert_match /banana\(\{/, @response.body
    end
  end

  test "shouldn't create video for logged out user" do
    assert_no_difference 'Video.count' do
      get :bookmark, @videoParams.merge({callback: 'banana'})
      assert_response :success
      assert_equal response.header['Content-Type'], 'application/javascript; charset=utf-8'
      assert_match /banana\(\{/, @response.body
    end
  end

  test "should get 404 when trying to access invalid video id" do
    logged_in_user
    get :show, id: 'bananas'
    assert_response 404
  end
end
