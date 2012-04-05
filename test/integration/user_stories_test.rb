require 'test_helper'

class UserStoriesTest < ActionDispatch::IntegrationTest
  test "creating an account natively" do
    visit "/signin"
    
    user = build(:user)
    
    within 'form#new_user' do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Sign Up'
    end
    
    assert_equal videos_path, current_path
  end
  
  test "creating an account using twitter" do
    # TK
  end
  
  test "creating an account using facebook" do
    # TK
  end
  
  test "logging in natively" do
    user = create(:user)
    
    visit "/signin"
    
    within "form[action='#{session_path}']" do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Sign In'
    end
    
    assert_equal videos_path, current_path
  end
  
  test "logging in using twitter" do
    # TK
  end
  
  test "logging in using facebook" do
    # TK
  end
  
  test "resetting a password" do
    visit "/signin"
    find_link('Forgot password?').click

    user = create(:user)    
    within "form[action='/users/send_password_reset']" do
      fill_in 'Email', with: user.email
      click_button 'Send It'
    end
    
    assert_equal forgot_password_users_path, current_path
    
    user = User.first(conditions: {email: user.email})
    assert user.resetPasswordCode
    assert user.resetPasswordCodeExpires
    assert !ActionMailer::Base.deliveries.empty?
  end
  
  test "adding a video" do
    user = create(:user)
  
    post_via_redirect "/session", email: user.email, password: user.password
    assert_equal videos_path, path
    
    get "/videos/bookmark", webpageUrl: 'https://www.youtube.com/watch?v=y9K18CGEeiI',
      videoID: 'y9K18CGEeiI', type: 'object', source: 'youtube'
    assert_response :success
    
    assert_equal 1, User.find(user.id).videos.size
  end
  
  test "favoriting a video" do
    user = create(:user_with_videos, videos_count: 3)

    visit "/signin"
    within "form[action='#{session_path}']" do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Sign In'
    end

    assert_equal videos_path, current_path
    assert page.has_selector? '.video'
    video = user.videos.last

    # Favorite
    find("##{video.id}").click_link('Favorite')
    assert Video.find(video.id).favorited

    # Un-favorite    
    visit "/videos/faves"
    find("##{video.id}").click_link('Favorite')
    assert !Video.find(video.id).favorited    
  end
  
  test "tagging a video" do
    
  end
  
  test "deleting a video" do
    
  end
  
  test "changing password" do
    
  end
  
  test "deleting account" do
    
  end
end