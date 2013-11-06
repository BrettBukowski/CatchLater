require 'test_helper'

class UserStoriesTest < ActionDispatch::IntegrationTest
  test "creating an account natively" do
    visit "/signin"

    create(:video)
    user = build(:user)

    within 'form#new_user' do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Sign Up'
    end

    assert_equal videos_path, current_path
  end

  test "creating an account using twitter" do
    skip("TK - Use mocking library")
  end

  test "creating an account using facebook" do
    skip("TK - Use mocking library")
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
    skip("TK - Use mocking library")
  end

  test "logging in using facebook" do
    skip("TK - Use mocking library")
  end

  test "logging out" do
    user = create(:user)

    visit "/signin"
    within "form[action='#{session_path}']" do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Sign In'
    end

    assert_equal videos_path, current_path

    find('.signout').click

    assert_equal signin_path, current_path

    visit "/videos"

    assert_equal signin_path, current_path
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

  test "set new password using reset code" do
    reset_code = 'bananas'
    create(:video)
    user = create(:user, resetPasswordCode: reset_code, resetPasswordCodeExpires: 1.day.from_now)

    visit "/reset_password?token=#{reset_code}"

    within "form[action='/users/#{user.id}/set_new_password']" do
      fill_in 'New Password', with: 'newpassword'
      click_button 'Save'
    end

    assert_equal videos_path, current_path
  end

  test "password cannot be set if reset code does not match" do
    create(:video)
    user = create(:user, resetPasswordCode: 'sold', resetPasswordCodeExpires: 1.day.from_now)

    visit "/reset_password?token=bananas"

    assert_equal forgot_password_users_path, current_path
  end

  test "password cannot be set if reset token has expired" do
    reset_code = 'bananas'
    create(:video)
    user = create(:user, resetPasswordCode: reset_code, resetPasswordCodeExpires: 1.day.ago)

    visit "/reset_password?token=#{reset_code}"

    assert_equal forgot_password_users_path, current_path
  end

  test "adding a video" do
    create(:video)
    user = create(:user)

    get_via_redirect "/signout"
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
    user = create(:user_with_videos, videos_count: 3)

    visit "/signin"
    within "form[action='#{session_path}']" do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Sign In'
    end

    video = user.videos.last

    within "##{video.id}" do
      fill_in 'Tags', with: 'banana'
      click_button 'Submit'
    end

    assert_equal 'banana', Video.find(video.id).tags.join(' ')
  end

  test "deleting a video" do
    user = create(:user_with_videos, videos_count: 3)

    visit "/signin"
    within "form[action='#{session_path}']" do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Sign In'
    end

    video = user.videos.last
    assert_difference 'Video.count', -1 do
      within "##{video.id}" do
        click_link 'Delete'
      end
    end
  end

  test "changing password" do
    create(:video)
    user = create(:user)

    visit "/signin"
    within "form[action='#{session_path}']" do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Sign In'
    end

    click_link user.email

    assert_equal edit_user_path(user.id), current_path

    within "form#edit_user_#{user.id}" do
      fill_in 'Password', with: 'banana'
      click_button 'Save'
    end

    find('.signout').click

    assert_equal signin_path, current_path

    within "form[action='#{session_path}']" do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: 'banana'
      click_button 'Sign In'
    end

    assert_equal videos_path, current_path
  end

  test "deleting account" do
    user = create(:user_with_videos, videos_count: 3)

    visit "/signin"
    within "form[action='#{session_path}']" do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Sign In'
    end

    click_link user.email

    assert_equal edit_user_path(user.id), current_path

    assert_difference 'User.count', -1 do
      click_link 'Delete your account'
    end
  end
end