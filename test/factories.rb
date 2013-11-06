FactoryGirl.define do
  sequence :email do |n|
    "person#{n}@banana.co.uk"
  end

  factory :video do
    videoID '12322123'
    webpageUrl 'http://banana.foo.co.uk'
    type 'iframe'
    source 'youtube'
    user
  end

  factory :user do
    email
    password '123'

    factory :user_with_videos do
      ignore do
        videos_count 5
      end

      after :create do |user, evaluator|
        FactoryGirl.create_list(:video, evaluator.videos_count, user: user)
      end
    end
  end
end
