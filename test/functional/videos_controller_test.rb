require 'test_helper'

class VideosControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response 302
  end
end
